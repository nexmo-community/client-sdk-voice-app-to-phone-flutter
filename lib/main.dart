import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    String token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTQzNDE0MzQsImp0aSI6ImExMTBjNjEwLTc4MmItMTFlYi1hNmQyLTg5NmQ2NGRjMDJlOSIsImV4cCI6MTYxNDQyNzgzNCwiYWNsIjp7InBhdGhzIjp7Ii8qL3VzZXJzLyoqIjp7fSwiLyovY29udmVyc2F0aW9ucy8qKiI6e30sIi8qL3Nlc3Npb25zLyoqIjp7fSwiLyovZGV2aWNlcy8qKiI6e30sIi8qL2ltYWdlLyoqIjp7fSwiLyovbWVkaWEvKioiOnt9LCIvKi9hcHBsaWNhdGlvbnMvKioiOnt9LCIvKi9wdXNoLyoqIjp7fSwiLyova25vY2tpbmcvKioiOnt9LCIvKi9sZWdzLyoqIjp7fX19LCJzdWIiOiJBbGljZSIsImFwcGxpY2F0aW9uX2lkIjoiMTczYjg5N2EtNjlkMi00NjMyLTg4NjAtZTk2M2M2ZTkyNmY2In0.fCgJDRf48Pz-RIzl0OMyUJ4stG8lTlwUxCYMnMjUsP0AXaRBP_D3PqnhABZYh3cSsET0d3ZZhoAkKXUM4X1rdjB3baiKEidC069fBD8IFUQg5mA6_n6vnxl7fFv1btitrASo1i9kdjjtyig2-vgUj-zELyGeKhvsQAXptYflckAMycyiWSF9-R-HN9ewcjIXzxwt-wa7atgKWZ2hYBp6g47Jv4keZh4S8qUudKb7SgkuleeSP_J4r3eNx1tq9VQICwOVxgy5ONFqaBjLkk7inE0rm7yKxT4SzXGx17YcON6sE3r5Uz19w7VxMN5aoceJJxcLdgjYOssrTDsIyc0GoA";

    try {
      await platformMethodChannel
          .invokeMethod('loginUser', <String, dynamic>{'token': token});
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _makeCall() async {
    try {
      await platformMethodChannel
          .invokeMethod('makeCall');
    } on PlatformException catch (e) {
      print(e);
    }
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