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
          Padding(
            padding: const EdgeInsets.only(top: 70.0, left: 0.0),
            child: Text("Create Your Profile",
                style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    fontSize: 40)),
          ),
          child,
        ]));
  }
}
