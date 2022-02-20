import 'package:flutter/material.dart';

Widget addPanelForm(ScrollController sc, String option) {
  return ListView(
    padding: const EdgeInsets.only(left: 8.0),
    controller: sc,
    children: <Widget>[
      SizedBox(
        height: 12.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
          ),
        ],
      ),
      SizedBox(
        height: 18.0,
      ),
      SizedBox(
        height: 36.0,
      ),
      SizedBox(
        height: 36.0,
      ),
      Container(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(option,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
            SizedBox(
              height: 12.0,
            ),
          ],
        ),
      ),
      SizedBox(
        height: 36.0,
      ),
      SizedBox(
        height: 24,
      ),
    ],
  );
}
