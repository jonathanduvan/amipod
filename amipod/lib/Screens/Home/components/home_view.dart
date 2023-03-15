import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dipity/Screens/Home/components/background.dart';
import 'package:contacts_service/contacts_service.dart';

class HomeView extends StatefulWidget {
  final int currentIndex;
  const HomeView({Key? key, required this.currentIndex}) : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
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
          Text('${widget.currentIndex} is the current page'),
        ]));
  }
}
