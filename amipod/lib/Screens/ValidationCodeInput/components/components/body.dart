import 'package:dipity/Screens/ValidationCodeInput/components/components/background.dart';
import 'package:dipity/Screens/SetupProfile/setup_profile_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/services.dart';

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController textEditingController = TextEditingController();
// TODO: Use geolocale of phone to determine country to replace the default value
  String currentText = "";

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          SizedBox(
            height: 150,
          ),
          Text(
              "Enter the code we sent to: *this is a placeholder for a phone nbr.",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(
            height: 25,
          ),
          SizedBox(
              width: size.width - 50,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeColor: primaryColor,
                    activeFillColor: primaryColor,
                    inactiveColor: Colors.white,
                    inactiveFillColor: Colors.white),
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: true,
                controller: textEditingController,
                onCompleted: (v) {
                  print("Completed");
                },
                onChanged: (value) {
                  print(value);
                  setState(() {
                    currentText = value;
                  });
                },
                beforeTextPaste: (text) {
                  print("Allowing to paste $text");
                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                  return true;
                },
              )),
          SizedBox(height: 300),
          SizedBox(
            width: size.width - 100,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SetupProfileScreen()),
                );
                ;
              },
              child: Text('Verify',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              // TODO: Add style to button
            ),
          )
        ]));
  }
}
