import 'package:dipity/Screens/ValidationCodeInput/components/components/body.dart';
import 'package:flutter/material.dart';

class ValidationCodeInput extends StatelessWidget {
  String phone;
  String verificationId;
  int? resendToken;
  Function onAuthorizeUser;
  Function onResendCode;
  Function onInputPhone;
  ValidationCodeInput(
      {Key? key,
      required this.phone,
      required this.verificationId,
      this.resendToken,
      required this.onAuthorizeUser,
      required this.onResendCode,
      required this.onInputPhone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Body(
      phone: phone,
      verificationId: verificationId,
      resendToken: resendToken,
      onAuthorizeUser: onAuthorizeUser,
      onInputPhone: onInputPhone,
      onResendCode: onResendCode,
    ));
  }
}
