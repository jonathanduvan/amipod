import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:amipod/Screens/RegisterPhoneNumber/components/background.dart';
import 'package:amipod/constants.dart';

class Body extends StatelessWidget {
  
  String dropdownValue = '';


  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Text("We'll text you a verification code. Carrier rates may apply.",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          DropdownButton(items: countryList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(), onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },)
          TextButton(
            onPressed: () {
              print('click me');
            },
            child: Text('Send Verification Code'),
            // TODO: Add style to button
          ),
        ]));
  }

}





