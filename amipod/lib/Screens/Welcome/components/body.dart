import 'package:dipity/Screens/RegisterPhoneNumber/register_phone_number.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Screens/Welcome/components/background.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          SizedBox(
            height: 280,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0, left: 0.0),
            child: Text("Reconnect.\nStay Connected.",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 40)),
          ),
          SizedBox(height: 300),
          SizedBox(
            width: size.width - 100,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterPhoneNumber()),
                );
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          )
        ]));
  }
}
