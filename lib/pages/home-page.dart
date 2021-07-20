import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:affogato/constants.dart';
import 'package:affogato/Widgets/wavyheader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:affogato/routes.dart';

bool _gateBusy = false;

var alertStyle = AlertStyle(
    animationType: AnimationType.grow,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.w400),
    animationDuration: Duration(milliseconds: 350),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
      side: BorderSide(
        color: ThemeData.dark().primaryColor,
      ),
    ),
    titleStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
    backgroundColor: ThemeData.dark().primaryColor);

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
            centerTitle: true,
            brightness: Brightness.light,
            backgroundColorStart: Color(0xFF00F260),
            backgroundColorEnd: Color(0xFF0575E6),
            title: Text(
              APP_TITLE,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w400),
            )),
        body: Column(
          children: <Widget>[WavyHeader(), GateWidget()],
        ));
  }
}

class GateWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GateWidgetState();
}

class GateWidgetState extends State<GateWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: <Widget>[
        Visibility(
          visible: !_gateBusy,
          replacement: Image.asset(
            "images/pacman.gif",
            height: 125.0,
            width: 125.0,
          ),
          child: Container(
            height: 125.0,
            width: 125.0,
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.topCenter,
            child: GradientButton(
              child: _gateBusy
                  ? Text("Opening Gate",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w600))
                  : Text("Open Gate",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
              callback: _gateBusy ? () {} : _openGate,
              gradient:
                  _gateBusy ? Gradients.backToFuture : Gradients.rainbowBlue,
              increaseHeightBy: 35,
              increaseWidthBy: double.maxFinite,
            ),
          ),
        ),
      ],
    ));
  }

  _openGate() async {
    setState(() {
      _gateBusy = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _email = await prefs.get(EMAIL);
      String _serialNumber = await prefs.get(SERIAL_NUMBER);

      // set up POST request arguments
      String url = 'http://affogato.avochoc.com/user-open';
      Map<String, String> headers = {
        "Accept": "application/json",
        "Content-type": "application/json"
      };
      String body = '{"email": "$_email", "serial_number": "$_serialNumber"}';
      print(
          "POST REQUEST: \n post-url: $url \n post-headers: $headers \n post-body: $body");
      final response = await post(url, headers: headers, body: body);
      //Everything here is after request is done
      print("RESPONSE STATUS CODE: " + response.statusCode.toString());
      print("RESPONSE: ${response.toString()}");
      if (response.statusCode == 200) {
        _waitForGateToOpenAndClose(30);
      } else if (response.statusCode == 403) {
        setState(() {
          _gateBusy = false;
        });

        Alert(
          context: context,
          title: "Pepe Hands!",
          desc:
              "Seems like you are having problems signing into Affogato. Please go see Dave to enable your account and try Signing in again.",
          image: Image.asset("images/whoops.gif"),
          style: alertStyle,
          buttons: [
            DialogButton(
              height: 50,
              radius: BorderRadius.all(Radius.circular(30)),
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: (){
                _logOut();
                Navigator.pushReplacementNamed(context, ROUTE_SIGN_IN);
              },
              gradient: LinearGradient(
                  colors: [Color(0xFF00F260), Color(0xFF0575E6)]),
            )
          ],
        ).show();
      }
    } catch (e) {
      print("Exception e");
      setState(() {
        _gateBusy = false;
      });
    }
  }

  _logOut() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(EMAIL);
    await prefs.remove(SERIAL_NUMBER);
  }

  _waitForGateToOpenAndClose(int seconds) {
    Alert(
      context: context,
      title: "Opening Gate",
      desc: "Please wait while our Gate Keeper opens up the gate.",
      image: Image.asset("images/gates.png"),
      style: alertStyle,
      buttons: [
        DialogButton(
          height: 50,
          radius: BorderRadius.all(Radius.circular(30)),
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient:
              LinearGradient(colors: [Color(0xFF00F260), Color(0xFF0575E6)]),
        )
      ],
    ).show();
    Future.delayed(Duration(seconds: seconds), () {
      setState(() {
        _gateBusy = false;
      });
    });
  }


}
