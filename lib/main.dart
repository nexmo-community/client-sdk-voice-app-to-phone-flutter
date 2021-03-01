import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: LoginWidget(title: 'app-to-phone-flutter'),
    );
  }
}

class LoginWidget extends StatefulWidget {
  LoginWidget({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  SdkState _sdkState = SdkState.LOGGED_OUT;
  static const platformMethodChannel = const MethodChannel('com.vonage');

  _LoginWidgetState() {
    platformMethodChannel.setMethodCallHandler(myUtilsHandler);
  }

  Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          setState(() {
            var arguments = 'SdkState.${methodCall.arguments}';
            _sdkState = SdkState.values.firstWhere((v) {return v.toString() == arguments;}
            );

            print(_sdkState);
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _loginUser() async {
    String token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTQ2MDYyNzcsImp0aSI6IjQzZGZlZmYwLTdhOTQtMTFlYi04NzkzLWZkYzQwM2RiOGExNiIsImV4cCI6MTYxNDY5MjY3NywiYWNsIjp7InBhdGhzIjp7Ii8qL3VzZXJzLyoqIjp7fSwiLyovY29udmVyc2F0aW9ucy8qKiI6e30sIi8qL3Nlc3Npb25zLyoqIjp7fSwiLyovZGV2aWNlcy8qKiI6e30sIi8qL2ltYWdlLyoqIjp7fSwiLyovbWVkaWEvKioiOnt9LCIvKi9hcHBsaWNhdGlvbnMvKioiOnt9LCIvKi9wdXNoLyoqIjp7fSwiLyova25vY2tpbmcvKioiOnt9LCIvKi9sZWdzLyoqIjp7fX19LCJzdWIiOiJBbGljZSIsImFwcGxpY2F0aW9uX2lkIjoiMTczYjg5N2EtNjlkMi00NjMyLTg4NjAtZTk2M2M2ZTkyNmY2In0.XXQNJEQYg4Aco7W9QVnKB87E6ChKO-_lgEHexNHq3ty5NaRAHTTkHviI9xfHk7Eo1J7HPLGRq53f_z6OsF8tdkp7K1RIH50pxmJ7Qvf4eVfgD7za0xdVYN8UynSM3hWL6v3Q9W811sYHeYRSofURPukBcnrmypwP8FLq7ALazC4Km1aJMW6DPlP03HCv5HRBd5H1v3haR3G8GvlwNJ0mQRKAJi7fQfqAmvOPVrEGJ2XBv8gZ443Ypdl2J2Osh5FtoXizDv08dNR39G2PzbtF9TGV8Ehq0WX9fvu1sQ4mBHI6fPNEMmxPQPQqncAW-FMBzEPDvZfMOo5OPNcbhJS2tg";

    try {
      await platformMethodChannel
          .invokeMethod('loginUser', <String, dynamic>{'token': token});
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _makeCall() async {
    try {
      await requestPermissions();

      await platformMethodChannel
          .invokeMethod('makeCall');
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone
    ].request();
  }

  Future<void> _endCall() async {
    try {
      await platformMethodChannel.invokeMethod('endCall');
    } on PlatformException catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 64),
            _buildConnectionButtons()
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionButtons() {
    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () { _loginUser(); },
          child: Text("LOGIN AS ALICE")
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return ElevatedButton(
          onPressed: () { _makeCall(); },
          child: Text("MAKE PHONE CALL")
      );
    } else if (_sdkState == SdkState.WAIT) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.ON_CALL) {
      return ElevatedButton(
          onPressed: () { _endCall(); },
          child: Text("END CALL")
      );
    } else {
      return Center(
        child: Text("ERROR")
      );
    }
  }
}

enum SdkState {
  LOGGED_OUT,
  LOGGED_IN,
  WAIT,
  ON_CALL,
  ERROR
}