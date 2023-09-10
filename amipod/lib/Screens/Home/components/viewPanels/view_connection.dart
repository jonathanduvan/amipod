import 'package:contacts_service/contacts_service.dart';
import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/Screens/Home/components/popup.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ViewConnectionFormPanel extends StatefulWidget {
  final String id;
  final Function onBlockConnection;
  const ViewConnectionFormPanel(
      {Key? panelKey, required this.id, required this.onBlockConnection})
      : super(key: panelKey);

  @override
  State<ViewConnectionFormPanel> createState() => ViewConnectionForm();
}

class ViewConnectionForm extends State<ViewConnectionFormPanel> {
  final _profileFormKey = GlobalKey<FormState>();

  final titleTextController = TextEditingController();

  String title = '';
  bool isChecked = false;

  HiveAPI hiveApi = HiveAPI(); // TODO: call function for addpods

  String daysBetween(String fromDate) {
    DateTime from = DateTime.parse(fromDate);
    from = DateTime(from.year, from.month, from.day);
    DateTime to = DateTime.now();

    int diff = (to.difference(from).inHours / 24).round();

    if (diff > 1) {
      return '$diff days ago';
    } else if (diff == 1) {
      return '$diff day ago';
    } else {
      return 'today';
    }
  }

  confirmBlockContact(ConnectionModel c) async {
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .blockConnection(c.id);
    Navigator.of(context).pop();
    Provider.of<ConnectionsContactsModel>(context, listen: false).connections;
    widget.onBlockConnection();
  }

  @override
  Widget build(BuildContext context) {
    // Box connectionsBox = context.select<ConnectionsContactsModel, Box>(
    //     (ccModel) => ccModel.connectionsBox);
    // Provider.of<ConnectionsContactsModel>(context, listen: true).connections;

    ConnectionModel selectedConnection =
        Provider.of<ConnectionsContactsModel>(context, listen: false)
            .getConnection(widget.id);
    print(selectedConnection.blocked);

    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      height: 1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${selectedConnection.name}',
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 25)),
          // Text('${selectedConnection.phone}',
          //     style: const TextStyle(
          //         color: Colors.black,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 22)),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Text('${selectedConnection.city!} -',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17)),
              Text(daysBetween(selectedConnection.last_update!),
                  style: TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontSize: 17)),
            ],
          ),

          SizedBox(
            height: 25,
          ),
          Center(
              child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: podOrange),
              onPressed: () {
                String name = 'Block ${selectedConnection.name} ?';
                String content =
                    'If you decide to change your mind, go to Profile -> Block List';

                showDialog(
                  context: context,
                  builder: (BuildContext diaContext) {
                    return showAlertDialog(context, name, content,
                        () => confirmBlockContact(selectedConnection));
                  },
                );
              },
              child: const Text('Block Connection',
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
