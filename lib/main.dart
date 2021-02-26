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
  // int _counter = 0;

  String _connectionState = "";
  static const platformMethodChannel = const MethodChannel('com.vonage');

  Future<void> _loginUser() async {
    String token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9"
        ".eyJpYXQiOjE2MTQxNzIxNzksImp0aSI6IjhjZjY4MzMwLTc2YTEtMTFlYi1iNDhlLTNiMzM1ZDU0MjlmNyIsImV4cCI6MTYxNDI1ODU3OCwiYWNsIjp7InBhdGhzIjp7Ii8qL3VzZXJzLyoqIjp7fSwiLyovY29udmVyc2F0aW9ucy8qKiI6e30sIi8qL3Nlc3Npb25zLyoqIjp7fSwiLyovZGV2aWNlcy8qKiI6e30sIi8qL2ltYWdlLyoqIjp7fSwiLyovbWVkaWEvKioiOnt9LCIvKi9hcHBsaWNhdGlvbnMvKioiOnt9LCIvKi9wdXNoLyoqIjp7fSwiLyova25vY2tpbmcvKioiOnt9LCIvKi9sZWdzLyoqIjp7fX19LCJzdWIiOiJBbGljZSIsImFwcGxpY2F0aW9uX2lkIjoiMTczYjg5N2EtNjlkMi00NjMyLTg4NjAtZTk2M2M2ZTkyNmY2In0.BEJFOglit9K9OJ8gVTKE1JY7m5w1HZKEzC8BoleC9gTDBeeXFPmhe1BtfWhc27ov0IM2a5NNkRLDRDHDEzgKJfitFJ-eTm16Rclj-rexX3QOQizFGVqc3ZVkrOdCfMnRG5vMAO30g5EnDTVW8iiT1otmv_sPofrMSQ4boSOu5l98UsPDa62pK7wlfCvwrScRxFrS4a6GNv9vm6Vm4-0REo6ftGxEhBlB5o3Drc4IkDSo9fyJHlwBrYkyAIMV5uvaDpysoCjmBNrUFS29wmCa9afhmJJ5y70TwiLXvTMbBIjigbIhpCNpXtRqik6OBnaIGC0QzV2CaJS21FvLyE1Ztw";

    try {
      await platformMethodChannel.invokeMethod(
          'loginUser',
          <String, dynamic>{'token': token}
      );
    } on PlatformException catch (e) {

    }
  }

  Future<void> _makeCall() async {
    try {
      await platformMethodChannel.invokeMethod('makeCall');
    } on PlatformException catch (e) {
    }
  }

  Future<void> _endCall() async {
    try {
      await platformMethodChannel.invokeMethod('endCall');
    } on PlatformException catch (e) {
    }
  }

  void _incrementCounter() {
    setState(() {
      // _counter++;
    });
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
            RaisedButton(
                onPressed: _loginUser,
                child: const Text('Login', style: TextStyle(fontSize: 18)),
            ),
            Text(
              '$_connectionState',
                style: TextStyle(fontSize: 18)
            )
          ],
        ),
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
