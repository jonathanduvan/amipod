import 'package:dipity/Screens/ValidationCodeInput/components/validation_code_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Screens/RegisterPhoneNumber/components/background.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:dipity/Services/secure_storage.dart';

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

  final _mobileFormatter = NumberTextInputFormatter();

  final _RegisterPhoneFormKey = GlobalKey<FormState>();

  void _handleCountryDropdownChanged(String newValue) {
    setState(() {
      _dropdownValue = newValue;
    });
  }

  void _onSubmitPhoneNumber(BuildContext context) async {
    var uuid = Uuid();
    var currEncryptKey = await storage.readSecureData(encryptionKeyName);
    var currIVKey = await storage.readSecureData(iVKeyName);
    var countryCode = countryCodes[_dropdownValue];
    var fullNumber = '+$countryCode$phoneNumber';

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
    await storage.writeSecureData(userPhoneNumberKeyName, phoneNumber);
  }

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
      SizedBox(
        height: 200,
      ),
      CountryDropdown(
          dropdownValue: _dropdownValue,
          onChanged: _handleCountryDropdownChanged),
      SizedBox(
        height: 25,
      ),
      Form(
        key: _RegisterPhoneFormKey,
        child: Column(
          children: <Widget>[
            SizedBox(
                width: size.width - 100,
                child: TextFormField(
                  style: TextStyle(color: primaryColor, fontSize: 20),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: InputDecoration(
                      labelText: "Phone Number",
                      focusColor: primaryColor,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor))),
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
                )),
            SizedBox(
              height: 50,
            ),
            SizedBox(
                width: size.width - 50,
                child: Text(
                    "We'll text you a verification code. Carrier rates may apply.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white))),
            SizedBox(
              height: 300,
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
                child: const Text(
                  'Send Verification Code',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            )
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
      icon: const Icon(
        Icons.arrow_downward,
        color: Colors.white,
      ),
      elevation: 16,
      style: const TextStyle(color: primaryColor),
      underline: Container(
        height: 2,
        color: Colors.white,
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

class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = new StringBuffer();
    if (newTextLength >= 1) {
      newText.write('+');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 3) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 2) + ' ');
      if (newValue.selection.end >= 2) selectionIndex += 1;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return new TextEditingValue(
      text: newText.toString(),
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
