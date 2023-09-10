import 'package:contacts_service/contacts_service.dart';
import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ViewSelfPanel extends StatelessWidget {
  final String userLocation;
  const ViewSelfPanel({Key? key, required this.userLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(userLocation);
    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      height: 1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('You',
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 30)),
          Text(userLocation,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ],
      ),
    );
  }
}
