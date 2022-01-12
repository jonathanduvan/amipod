import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
import 'package:amipod/Screens/Welcome/components/background.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Text("Reconnect. Stay Connected.",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
        ]));
  }
}
