package com.example.app_to_phone_flutter

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoConnectionState
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    enum class AppState {
        LOGGED_OUT,
        LOGGED_IN,
        ON_CALL,
        ERROR
    }
    
    private val CHANNEL = "com.vonage"

    private lateinit var client: NexmoClient
    var onGoingCall: NexmoCall? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initClient()
        addFlutterChannelListener()
    }

    private fun initClient() {
        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            when (connectionStatus) {
                NexmoConnectionState.CONNECTED -> notifyFlutter(AppState.LOGGED_IN)
                NexmoConnectionState.DISCONNECTED -> notifyFlutter(AppState.LOGGED_OUT)
                NexmoConnectionState.DISCONNECTED -> notifyFlutter(AppState.ERROR)
                NexmoConnectionState.CONNECT_TIMEOUT -> notifyFlutter(AppState.ERROR)
            }
        }
    }

    private fun addFlutterChannelListener() {
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->

            when (call.method) {
                "loginUser" -> {
                    val token = requireNotNull(call.argument<String>("token"))
                    login(token)
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

    private fun login(token: String) {
        client.login(token)
    }

    private fun makeCall() {
        // Callee number is ignored because it is specified in NCCO config
        client.call("IGNORED_NUMBER", NexmoCallHandler.SERVER, object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall = call
                notifyFlutter(AppState.ON_CALL)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(AppState.ERROR)
            }
        })
    }

    private fun endCall() {
        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall = null
                notifyFlutter(AppState.LOGGED_IN)
            }

            override fun onError(apiError: NexmoApiError) {
                notifyFlutter(AppState.ERROR)
            }
        })
    }

    private fun notifyFlutter(state: AppState) {
        Handler(Looper.getMainLooper()).post {
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).invokeMethod("updateState", state
                .toString())
        }
    }
}

