import 'package:flutter/material.dart';
import 'package:amipod/Screens/Welcome/welcome_screen.dart';
import 'package:amipod/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amipod',
      theme: ThemeData(
          primaryColor: primaryColor, scaffoldBackgroundColor: backgroundColor),
      home:
          WelcomeScreen(), // TODO: Add check for if user has an account and has logged in on the phone before
    );
  }
}
