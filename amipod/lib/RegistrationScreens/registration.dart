import 'dart:convert' show base64Decode, base64Url, base64UrlEncode;
import 'dart:io';
import 'package:dipity/Screens/CreatePin/components/create_pin_screen.dart';
import 'package:dipity/Screens/RegisterPhoneNumber/register_phone_number.dart';
import 'package:dipity/Screens/ValidationCodeInput/components/validation_code_input_screen.dart';
import 'package:dipity/Services/secure_storage.dart';
import 'package:dipity/Services/user_management.dart';

import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// import 'package:geocode/geocode.dart';

class RegistrationPages extends StatefulWidget {
  const RegistrationPages({Key? key}) : super(key: key);

  @override
  RegistrationPagesState createState() => RegistrationPagesState();
}

class RegistrationPagesState extends State<RegistrationPages> {
  bool codeSent = false;

  String phoneNumber = "";
  String smsCode = "";
  String verificationId = "";
  int? resendToken;

  late Function authorizeUser;

  SecureStorage storage = SecureStorage();
  UserManagement userManagement = UserManagement();

  void _onSubmitPhoneNumber(
      BuildContext context, String countryCode, String phone) async {
    var uuid = const Uuid();
    var currEncryptKey = await storage.readSecureData(encryptionKeyName);
    var currIVKey = await storage.readSecureData(iVKeyName);
    // var countryCode = countryCodes[_dropdownValue];
    var fullNumber = '+1$phone';
    print('full number: $fullNumber');

    // Handle creating encryption key if null
    if (currEncryptKey == null) {
      var newEncyptKey = uuid.v1();
      await storage.writeSecureData(encryptionKeyName, newEncyptKey);
    }
    // // Handle creating IV key if null
    // if (currIVKey == null) {
    //   var currIVKey = IV.fromLength(16);
    //   await storage.writeSecureData(currIVKey, currIVKey);
    // }
    await storage.writeSecureData(userPhoneNumberKeyName, fullNumber);

    userManagement.verifyPhoneNumber(
        fullNumber, onCodeSent, goToCreatePin, context);
  }

  onResendCode(String fullNumber, BuildContext context) {
    userManagement.verifyPhoneNumber(
        fullNumber, onCodeSent, goToCreatePin, context);
  }

  onReturnToPhone() {
    setState(() {
      codeSent = false;
      verificationId = '';
      resendToken = null;
      phoneNumber = '';
    });
  }

  onCodeSent(String phone, String verifId, int? token, Function smsAuth) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        'A code has been sent to your phone.',
        style: TextStyle(color: backgroundColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.green,
    ));

    setState(() {
      codeSent = true;
      verificationId = verifId;
      resendToken = token;
      authorizeUser = smsAuth;
      phoneNumber = phone;
    });
  }

  goToCreatePin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePin()),
    );
  }

  onAuthorizeUser(String smsCode, BuildContext context) async {
    UserManagement userManagement = UserManagement();
    print("here is the verification id: $verificationId");

    try {
      await userManagement.authorizeUser(
          smsCode, verificationId, resendToken, context, goToCreatePin);
    } catch (error) {
      print('nope it was registration lololol');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (codeSent) {
      return ValidationCodeInput(
        phone: phoneNumber,
        verificationId: verificationId,
        resendToken: resendToken,
        onAuthorizeUser: onAuthorizeUser,
        onResendCode: onResendCode,
        onInputPhone: onReturnToPhone,
      );
    } else {
      return RegisterPhoneNumber(
          phoneNumber: phoneNumber, onSubmitPhoneNumber: _onSubmitPhoneNumber);
    }
  }
}
