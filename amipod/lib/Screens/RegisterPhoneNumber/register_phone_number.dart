import 'package:dipity/Screens/RegisterPhoneNumber/components/body.dart';
import 'package:flutter/material.dart';

class RegisterPhoneNumber extends StatelessWidget {
  final String phoneNumber;
  final Function onSubmitPhoneNumber;
  const RegisterPhoneNumber(
      {Key? key, required this.phoneNumber, required this.onSubmitPhoneNumber})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Body(
            phoneNumber: phoneNumber,
            onSubmitPhoneNumber: onSubmitPhoneNumber));
  }
}
