import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        height: size.height,
        width: size.width,
        child: Stack(alignment: Alignment.topCenter, children: <Widget>[
          Positioned(child: Text('Enter Your PIN')),
          child,
        ]));
  }
}
