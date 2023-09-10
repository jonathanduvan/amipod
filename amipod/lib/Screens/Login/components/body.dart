import 'package:dipity/RegistrationScreens/registration.dart';
import 'package:dipity/Screens/Login/components/background.dart';
import 'package:dipity/Screens/Home/home_screen.dart';
import 'package:dipity/Services/encryption.dart';
import 'package:dipity/Services/secure_storage.dart';
import 'package:dipity/Services/user_management.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:dipity/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  UserManagement userManagement = UserManagement();
  late SharedPreferences prefs;

  var currEncryptKey;
  var pinCryptFormatHash;

  Box? podsBox;
  Box? connectionsBox;
  Box? contactsBox;

  @override
  void initState() {
    getEncryptionValues().then((result) {
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

  void loginToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  reRegisterAccount() async {
    await userManagement.deleteUser();
    prefs = await SharedPreferences.getInstance();

    await prefs.clear();
    await storage.deleteAll();

    await podsBox?.clear();
    await connectionsBox?.clear();
    await contactsBox?.clear();

    await SystemNavigator.pop();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const RegistrationPages()));
  }

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          SizedBox(
            height: 80,
          ),
          Text("Log in using your PIN.",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(
            height: 20,
          ),
          Center(
            child: SvgPicture.asset('assets/images/dipity.svg',
                width: 150, height: 150, fit: BoxFit.contain),
          ),
          Form(
            key: _pinNumberFormKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: (size.width - 100) > 0 ? (size.width - 100) : 0,
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Brightness.dark,
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
                  // width: size.width - 100,
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
                        loginToProfile();
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
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Forgot your pin? Re-register",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                    TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero, // Set this
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onPressed: reRegisterAccount,
                        child: Text(
                          "here",
                        ))
                  ],
                )
              ],
            ),
          ),
        ]));
  }
}
