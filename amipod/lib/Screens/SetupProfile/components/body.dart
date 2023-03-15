import 'package:dipity/Screens/CreatePin/components/create_pin_screen.dart';
import 'package:dipity/Screens/SetupProfile/components/background.dart';
import 'package:flutter/material.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String firstName = "";
  String lastName = "";
  final _profileFormKey = GlobalKey<FormState>();

  void _onCreateProfile(BuildContext context) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    print(firstName);
    print(lastName);
    // Save an String value to 'firstName' and 'lastName keys.
    await prefs.setString(firstNameKey, firstName);
    await prefs.setString(lastNameKey, lastName);
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
          Text("Your profile will be visible only to any connections you make.",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),

          Form(
            key: _profileFormKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 100),
                TextFormField(
                  style: TextStyle(color: primaryColor, fontSize: 20),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      labelText: "First Name",
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      firstName = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                    style: TextStyle(color: primaryColor, fontSize: 20),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        labelText: "Last Name",
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    }),
                SizedBox(height: 300),
                SizedBox(
                  width: size.width - 100,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primaryColor),
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_profileFormKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saving Name')),
                        );
                        _onCreateProfile(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreatePin()),
                        );
                      }
                    },
                    child: const Text('Create Profile',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                )
              ],
            ),
          ),

          // TextButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const CreatePin()),
          //     );
          //     ;
          //   },
          //   child: Text('Create Profile'),
          //   // TODO: Add style to button
          // ),
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
