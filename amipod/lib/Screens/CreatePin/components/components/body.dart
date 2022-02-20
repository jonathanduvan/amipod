import 'dart:ffi';
import 'package:amipod/Screens/CreatePin/components/components/background.dart';
import 'package:amipod/Screens/Home/home_screen.dart';
import 'package:amipod/Services/encryption.dart';
import 'package:amipod/Services/secure_storage.dart';
import 'package:crypt/crypt.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

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

  void _onSubmitPinNumber(BuildContext context) async {
    var uuid = Uuid();
    var currEncryptKey = await storage.readSecureData(encryptionKeyName);
    final encrypter = EncryptionManager(encryptionString: currEncryptKey);
    encrypter.createEncryptionKey();
    print('current encrypt key');
    print(encrypter.encryptionKey.toString());
    var encryptedPinNumber =
        await encrypter.encryptData(userPinKeyName, pinNumber);

    print(encryptedPinNumber);
    // await storage.writeSecureData(userPinKeyName, encryptedPinNumber);
  }

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Text(
              'Creating a PIN is required to restore your encrypted information, and can be used as a way to quickly log back in.'),
          Form(
            key: _pinNumberFormKey,
            child: Column(
              children: <Widget>[
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.blue.shade50,
                  enableActiveFill: true,
                  controller: textEditingController,
                  onCompleted: (v) {
                    print("Completed");
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please a valid pin';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      pinNumber = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_pinNumberFormKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Pin Number')),
                      );
                      _onSubmitPinNumber(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    }
                  },
                  child: const Text('Create Pin'),
                ),
              ],
            ),
          ),
        ]));
  }
}
