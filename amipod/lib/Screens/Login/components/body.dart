import 'package:amipod/Screens/Login/components/background.dart';
import 'package:amipod/Screens/Home/home_screen.dart';
import 'package:amipod/Services/encryption.dart';
import 'package:amipod/Services/secure_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:amipod/constants.dart';

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController textEditingController = TextEditingController();
// TODO: Use geolocale of phone to determine country to replace the default value
  String pinNumber = "";

  final _pinNumberFormKey = GlobalKey<FormState>();
  SecureStorage storage = SecureStorage();
  late EncryptionManager encrypter;
  var currEncryptKey;
  var pinCryptFormatHash;

  @override
  void initState() {
    // This is the proper place to make the async calls
    // This way they only get called once

    // During development, if you change this code,
    // you will need to do a full restart instead of just a hot reload

    // You can't use async/await here, because
    // We can't mark this method as async because of the @override
    // You could also make and call an async method that does the following
    getEncryptionValues().then((result) {
      // If we need to rebuild the widget with the resulting data,
      // make sure to use `setState`

      print(result[0]);
      var currKey = result[0];
      var pinhash = result[1];

      var encryptObject = EncryptionManager();

      setState(() {
        currEncryptKey = currKey;
        pinCryptFormatHash = pinhash;
        encrypter = encryptObject;
      });
    });
  }

  Future<List<String>> getEncryptionValues() async {
    var currKey = await storage.readSecureData(encryptionKeyName);
    var pinHash = await storage.readSecureData(userPinKeyName);
    List<String> encryptionValues = [currKey, pinHash];

    return encryptionValues;
  }

  bool _checkPinNumber() {
    var enteredPassword = 'pin_number:$pinNumber';
    return encrypter.isPasswordValid(pinCryptFormatHash, enteredPassword);
  }

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
          Text("Log in using your PIN.",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(
            height: 20,
          ),
          Form(
            key: _pinNumberFormKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: size.width - 100,
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: primaryColor,
                      inactiveFillColor: Colors.white,
                      activeColor: primaryColor,
                      inactiveColor: Colors.white,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    enableActiveFill: true,
                    controller: textEditingController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please a valid pin';
                      }
                      if (value.length < 4) {
                        return '';
                      }
                      var passCheck = _checkPinNumber();

                      if (passCheck) {
                        return null;
                      } else {
                        return 'Invalid pin. Please Type in your pin.';
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        pinNumber = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: size.width - 100,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: primaryColor,
                    ),
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_pinNumberFormKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logging in...')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                        );
                      }
                    },
                    child: const Text('Login',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Text("Forgot your pin? Re-register here",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white))
              ],
            ),
          ),
        ]));
  }
}
