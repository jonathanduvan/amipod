import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height,
        width: double.infinity,
        child: Stack(alignment: Alignment.topCenter, children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 35.0, left: 0.0),
            child: Text("Dipity",
                style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    fontSize: 40)),
          ),
          child,
        ]));
  }
}
