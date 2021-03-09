package com.example.app_to_phone_flutter

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallEventListener
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoCallMember
import com.nexmo.client.NexmoCallMemberStatus
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoMediaActionState
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus
import com.nexmo.client.request_listener.NexmoRequestListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var client: NexmoClient
    private var onGoingCall: NexmoCall? = null

    private val callEventListener = object : NexmoCallEventListener {
        override fun onMemberStatusUpdated(callMemberStatus: NexmoCallMemberStatus, callMember: NexmoCallMember) {
            if (callMemberStatus == NexmoCallMemberStatus.COMPLETED || callMemberStatus == NexmoCallMemberStatus.CANCELLED) {
                onGoingCall = null
                notifyFlutter(SdkState.LOGGED_IN)
            }
        }

        override fun onMuteChanged(mediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {}

        override fun onEarmuffChanged(mediaActionState: NexmoMediaActionState, callMember: NexmoCallMember) {}

        override fun onDTMF(dtmf: String, callMember: NexmoCallMember) {}
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initClient()
        addFlutterChannelListener()
    }

    private fun initClient() {
        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            when (connectionStatus) {
                ConnectionStatus.CONNECTED -> notifyFlutter(SdkState.LOGGED_IN)
                ConnectionStatus.DISCONNECTED -> notifyFlutter(SdkState.LOGGED_OUT)
                ConnectionStatus.CONNECTING -> notifyFlutter(SdkState.WAIT)
                ConnectionStatus.UNKNOWN -> notifyFlutter(SdkState.ERROR)
            }
        }
    }

    private fun addFlutterChannelListener() {
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, "com.vonage").setMethodCallHandler { call, result ->

            when (call.method) {
                "loginUser" -> {
                    val token = requireNotNull(call.argument<String>("token"))
                    loginUser(token)
                    result.success("")
                }
                "makeCall" -> {
                    makeCall()
                    result.success("")
                }
                "endCall" -> {
                    endCall()
                    result.success("")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun loginUser(token: String) {
        client.login(token)
    }

    @SuppressLint("MissingPermission")
    private fun makeCall() {
        notifyFlutter(SdkState.WAIT)

        // Callee number is ignored because it is specified in NCCO config
        client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall = call
                onGoingCall?.addCallEventListener(callEventListener)
                notifyFlutter(SdkState.ON_CALL)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(SdkState.ERROR)
            }
        })
    }

    private fun endCall() {
        notifyFlutter(SdkState.WAIT)

        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall?.removeCallEventListener(callEventListener)
                onGoingCall = null
                notifyFlutter(SdkState.LOGGED_IN)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(SdkState.ERROR)
            }
        })
    }

    private fun notifyFlutter(state: SdkState) {
        Handler(Looper.getMainLooper()).post {
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, "com.vonage")
                .invokeMethod("updateState", state.toString())
        }
    }
}

enum class SdkState {
    LOGGED_OUT,
    LOGGED_IN,
    WAIT,
    ON_CALL,
    ERROR
}