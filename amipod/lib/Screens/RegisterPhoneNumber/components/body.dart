import 'dart:ffi';
import 'package:amipod/Screens/ValidationCodeInput/components/validation_code_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:amipod/Screens/RegisterPhoneNumber/components/background.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:amipod/Services/secure_storage.dart';

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String _dropdownValue =
      'United States'; // TODO: Use geolocale of phone to determine country to replace the default value

  String phoneNumber = "";
  SecureStorage storage = SecureStorage();

  final _RegisterPhoneFormKey = GlobalKey<FormState>();

  void _handleCountryDropdownChanged(String newValue) {
    setState(() {
      _dropdownValue = newValue;
    });
  }

  void _onSubmitPhoneNumber(BuildContext context) async {
    var uuid = Uuid();
    var currEncryptKey = await storage.readSecureData(encryptionKeyName);
    var countryCode = countryCodes[_dropdownValue];
    var fullNumber = '+$countryCode$phoneNumber';
    print(fullNumber);
    // Handle creating encryption key if null
    if (currEncryptKey == null) {
      print('new encryption string');
      var newEncyptKey = uuid.v1();
      await storage.writeSecureData(encryptionKeyName, newEncyptKey);
    }
    await storage.writeSecureData(userPhoneNumberKeyName, phoneNumber);
  }

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
      Text("We'll text you a verification code. Carrier rates may apply.",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      CountryDropdown(
          dropdownValue: _dropdownValue,
          onChanged: _handleCountryDropdownChanged),
      Form(
        key: _RegisterPhoneFormKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(labelText: "Phone Number"),
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                } else if (value.length != 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_RegisterPhoneFormKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Phone Number')),
                  );
                  _onSubmitPhoneNumber(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ValidationCodeInput()),
                  );
                }
              },
              child: const Text('Send Verification Code'),
            ),
          ],
        ),
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
