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
        width: double.infinity,
        child: Stack(alignment: Alignment.topCenter, children: <Widget>[
          Positioned(
              child: Image.asset("assets/images/fake_logo.png",
                  width: size.width * 0.4)),
          child,
        ]));
  }
}
