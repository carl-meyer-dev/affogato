import 'package:flutter/material.dart';
import 'package:affogato/pages/sign-in-page.dart';
import 'package:affogato/routes.dart';
import 'package:affogato/pages/home-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

SharedPreferences prefs;
String _email;
String _serialNumber;
bool _loggedIn;

void main() async {

  prefs = await SharedPreferences.getInstance();
  _email = await prefs.get(EMAIL);
  _serialNumber = await prefs.get(SERIAL_NUMBER);

  _loggedIn = _email != null && _serialNumber != null;

  print("Email : $_email \n Serial Number : $_serialNumber \n LoggedIn : $_loggedIn");

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan
      ),
      routes: {
        ROUTE_SIGN_IN : (context) => SignInPage(),
        ROUTE_HOME : (context) => HomePage()
      },
      home: _loggedIn ? HomePage() : SignInPage(),
    );
  }


}

