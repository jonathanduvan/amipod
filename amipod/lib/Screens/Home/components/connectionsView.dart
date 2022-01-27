import 'dart:ffi';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:amipod/Screens/Home/components/background.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/services.dart';

class ConnectionsView extends StatefulWidget {
  final int currentIndex;
  const ConnectionsView({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  _ConnectionsViewState createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<ConnectionsView> {
  Widget build(BuildContext context) {
    print(widget.currentIndex);
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Go To Start'),
            // TODO: Add style to button
          ),
          Text('${widget.currentIndex} is the current page')
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
