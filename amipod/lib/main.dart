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
          primaryColor: primaryColor, scaffoldBackgroundColor: primaryColor),
      home: WelcomeScreen(),
    );
  }
}
