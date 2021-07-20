import 'package:flutter/material.dart';
import 'package:affogato/constants.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:affogato/Widgets/wavyheader.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:affogato/model/serial_number.dart';
import 'dart:convert';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:affogato/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _formKey = GlobalKey<FormState>();
String _email = "";
String _pinCode = "";
bool _autoValidate = false;
bool _isLoading = false;
String _serialNumber;
SharedPreferences prefs;

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

class SignInPage extends StatelessWidget {
  SignInPage() : super();

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
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.w400),
          )),
      body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: <Widget>[WavyHeader(), SignInForm()],
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignInFormState();
  }
}

class SignInFormState extends State<SignInForm> {
  final emailInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: Colors.cyanAccent),
                    hintText: "Enter Avochoc Email",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.cyanAccent, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    prefixIcon: Icon(
                      Icons.account_circle,
                      size: 35,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  onSaved: (value) {
                    _email = value;
                  },
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Container(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Pin Code',
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(color: Colors.cyanAccent),
                      hintText: "Enter Given Pin Code",
                      border: OutlineInputBorder(
                          borderSide: BorderSide(),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.cyanAccent, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      prefixIcon: Icon(
                        Icons.lock,
                        size: 35,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    onSaved: (String value) {
                      _pinCode = value;
                    },
                    validator: _validatePinCode,
                    obscureText: true,
                  )),
              Visibility(
                visible: !_isLoading,
                replacement: Image.asset(
                  "images/pacman.gif",
                  height: 125.0,
                  width: 125.0,
                ),
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 50),
                  alignment: Alignment.bottomCenter,
                  child: GradientButton(
                    child: Text(
                      "Sign In",
                      style: TextStyle(fontSize: 24),
                    ),
                    callback: _validateInputs,
                    gradient: Gradients.rainbowBlue,
                    increaseHeightBy: 35,
                    increaseWidthBy: double.maxFinite,
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  @override
  void dispose() {
    emailInputController.dispose();
    super.dispose();
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      // The form is empty
      return "Enter email address";
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return 'Email is not valid';
  }

  String _validatePinCode(String value) {
    if (value.isEmpty) {
      // The form is empty
      return "Pin Code is required";
    }
    return null;
  }

  void _validateInputs() {
    final form = _formKey.currentState;
    if (form.validate()) {
      // Text forms was validated.
      form.save();
      setState(() {
        _isLoading = true;
      });

      Timer(Duration(seconds: 1), () => _register(_email, _pinCode));
    } else {
      setState(() => _autoValidate = true);
    }
  }

  _register(String email, String otp) async {
    try {
      // set up POST request arguments
      String url = 'http://affogato.avochoc.com/user-register';
      Map<String, String> headers = {
        "Accept": "application/json",
        "Content-type": "application/json"
      };
      String body = '{"email": "$email", "otp": "$otp"}';
      print(
          "POST REQUEST: \n post-url: $url \n post-headers: $headers \n post-body: $body");
      final response = await post(url, headers: headers, body: body);
      //Everything here is after request is done
      setState(() {
        _isLoading = false;
      });
      print("RESPONSE STATUS CODE: " + response.statusCode.toString());
      print("RESPONSE: ${response.toString()}");
      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        print("Serial Number : " + data['serial_number']);
        _serialNumber = data['serial_number'];
        _signIn();
      } else if (response.statusCode == 403) {
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
              onPressed: () => Navigator.pop(context),
              gradient: LinearGradient(
                  colors: [Color(0xFF00F260), Color(0xFF0575E6)]),
            )
          ],
        ).show();
        return null;
      }
    } catch (e) {
      print("Exception e");
    }
  }

  _signIn() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(EMAIL, _email);
    await prefs.setString(SERIAL_NUMBER, _serialNumber);
    Navigator.pushReplacementNamed(context, ROUTE_HOME);
  }
}
