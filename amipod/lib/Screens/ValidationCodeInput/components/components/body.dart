import 'package:dipity/Screens/CreatePin/components/create_pin_screen.dart';
import 'package:dipity/Screens/ValidationCodeInput/components/components/background.dart';
import 'package:dipity/Screens/SetupProfile/setup_profile_screen.dart';
import 'package:dipity/Services/user_management.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/services.dart';

class Body extends StatefulWidget {
  String phone;
  String verificationId;
  int? resendToken;
  Function onAuthorizeUser;
  Function onResendCode;
  Function onInputPhone;
  Body(
      {Key? key,
      required this.phone,
      required this.verificationId,
      this.resendToken,
      required this.onAuthorizeUser,
      required this.onResendCode,
      required this.onInputPhone})
      : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController textEditingController = TextEditingController();
// TODO: Use geolocale of phone to determine country to replace the default value
  String smsCode = "";

  String cleanNumber(String userPhone) {
    if (userPhone != '') {
      String cleanedNumber = userPhone
          .substring(2, userPhone.length)
          .replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'),
              (Match m) => "(${m[1]}) ${m[2]}-${m[3]}");
      ;
      return (userPhone.substring(0, 2) + ' ' + cleanedNumber);
    }
    return userPhone;
  }

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          SizedBox(
            height: 130,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Enter the code we sent to:",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(" ${cleanNumber(widget.phone)}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20)),
          SizedBox(
            height: 30,
          ),
          SizedBox(
              width: size.width - 50,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                keyboardAppearance: Brightness.dark,
                pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeColor: primaryColor,
                    activeFillColor: primaryColor,
                    inactiveColor: Colors.white,
                    inactiveFillColor: Colors.white),
                animationDuration: Duration(milliseconds: 200),
                enableActiveFill: true,
                controller: textEditingController,
                onChanged: (value) {
                  setState(() {
                    smsCode = value;
                  });
                },
                beforeTextPaste: (text) {
                  print("Allowing to paste $text");
                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                  return true;
                },
              )),
          SizedBox(
            height: 20,
          ),
          (smsCode == '')
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => {widget.onInputPhone()},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: ShapeDecoration(
                              color: backgroundColor,
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.white70)),
                            ),
                            child: Icon(Icons.undo,
                                color: Colors.white70, size: 30),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Re-type #',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    TextButton(
                        onPressed: () =>
                            {widget.onResendCode(widget.phone, context)},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: const ShapeDecoration(
                                color: backgroundColor,
                                shape: CircleBorder(
                                    side: BorderSide(color: Colors.amber)),
                              ),
                              child: const Icon(Icons.perm_phone_msg,
                                  color: Colors.amber, size: 30),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Re-send SMS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ],
                )
              : const SizedBox(),
          const SizedBox(height: 50),
          SizedBox(
            width: size.width - 100,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                widget.onAuthorizeUser(smsCode, context);
                textEditingController.clear();
                // setState(() {
                //   smsCode = '';
                // });
              },
              child: const Text('Verify',
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
