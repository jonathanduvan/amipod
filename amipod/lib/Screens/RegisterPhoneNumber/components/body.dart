import 'dart:ffi';
import 'package:amipod/Screens/ValidationCodeInput/components/validation_code_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:amipod/Screens/RegisterPhoneNumber/components/background.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/services.dart';

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String _dropdownValue =
      'United States'; // TODO: Use geolocale of phone to determine country to replace the default value

  void _handleCountryDropdownChanged(String newValue) {
    setState(() {
      _dropdownValue = newValue;
    });
  }

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Text("We'll text you a verification code. Carrier rates may apply.",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          CountryDropdown(
              dropdownValue: _dropdownValue,
              onChanged: _handleCountryDropdownChanged),
          TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(labelText: "Phone Number")),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ValidationCodeInput()),
              );
            },
            child: Text('Send Verification Code'),
            // TODO: Add style to button
          ),
        ]));
  }
}

class CountryDropdown extends StatelessWidget {
  const CountryDropdown({
    Key? key,
    required this.dropdownValue,
    required this.onChanged,
  }) : super(key: key);

  final String dropdownValue;
  final ValueChanged<String> onChanged;

  void handleDropdownChange(String newValue) {
    onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      alignment: Alignment.center,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        handleDropdownChange(newValue!);
      },
      items: <String>['India', 'United States', 'Canada']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}