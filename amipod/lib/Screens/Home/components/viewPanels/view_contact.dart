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

class ViewContactFormPanel extends StatefulWidget {
  final String id;
  final Function closePanel;
  const ViewContactFormPanel(
      {Key? panelKey, required this.id, required this.closePanel})
      : super(key: panelKey);

  @override
  State<ViewContactFormPanel> createState() => ViewContactForm();
}

class ViewContactForm extends State<ViewContactFormPanel> {
  final _profileFormKey = GlobalKey<FormState>();

  final titleTextController = TextEditingController();

  String title = '';
  bool isChecked = false;

  HiveAPI hiveApi = HiveAPI(); // TODO: call function for addpods

  @override
  Widget build(BuildContext context) {
    ContactModel selectedContact =
        Provider.of<ConnectionsContactsModel>(context, listen: false)
            .getContact(widget.id);

    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      height: 1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${selectedContact.name}',
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 30)),
          SizedBox(height: 50),
          Text('${selectedContact.phone}',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          SizedBox(
            height: 20,
          ),
          Center(
              child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: podOrange),
              onPressed: () {},
              child: const Text('Remove Contact',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
          ))
        ],
      ),
    );
  }
}
