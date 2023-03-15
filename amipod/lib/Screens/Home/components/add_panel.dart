import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/Services/encryption.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

Widget addPanelForm(ScrollController sc, String option) {
  var podForm = 'New Pod';
  var reminderForm = 'New Reminder';
  late Widget form;
  if (option == podForm) {
    form = createPodForm(option: podForm);
  } else if (option == reminderForm) {
    form = createPodForm(option: reminderForm);
  }

  if (option == "") {
    return ListView();
  }

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
      form,
      SizedBox(
        height: 36.0,
      ),
      SizedBox(
        height: 24,
      ),
    ],
  );
}

class createPodForm extends StatefulWidget {
  final String option;
  const createPodForm({Key? panelKey, required this.option})
      : super(key: panelKey);

  @override
  State<createPodForm> createState() => _createPodForm();
}

class _createPodForm extends State<createPodForm> {
  final _profileFormKey = GlobalKey<FormState>();
  Map<String, ContactModel> selectedContacts = {};
  String title = '';
  bool isChecked = false;

  HiveAPI hiveApi = HiveAPI(); // TODO: call function for addpods

  bool checkList(Iterable<dynamic> infoList) {
    if (infoList.isNotEmpty) {
      return true;
    } else {
      return false;
    }
    ;
  }

  bool isContactInPod(String id) {
    return selectedContacts.containsKey(id);
  }

  bool createPod() {
    var newPod = Provider.of<ConnectionsContactsModel>(context, listen: false)
        .addPod(selectedContacts, title);

    if (newPod is PodModel) {
      return true;
    }
    return false;
  }

  void addToPod(ContactModel contact) {
    if (isContactInPod(contact.id)) {
      setState(() {
        selectedContacts.remove(contact.id);
      });
    } else {
      setState(() {
        selectedContacts[contact.id] = contact;
      });
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    Iterable<dynamic> hiveContacts =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hiveContacts);
    Iterable<dynamic> hiveConnections =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hiveConnections);
    Iterable<dynamic> hivePods =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hivePods);

    return Container(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      height: 1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('New Pod',
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 30)),
          Form(
            key: _profileFormKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                TextFormField(
                  style: TextStyle(color: podOrange, fontSize: 20),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      labelText: "Pod Name",
                      focusColor: primaryColor,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: podOrange)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid pod name.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Text('Add Pod Members',
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w300,
                  fontSize: 22)),
          SizedBox(
            height: 20,
          ),
          selectedContacts.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: selectedContacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    ContactModel c = selectedContacts.values.toList()[index];
                    return Text(c.name,
                        style: TextStyle(
                            color: podOrange,
                            fontWeight: FontWeight.w300,
                            fontSize: 18));
                  },
                )
              : Text(
                  "No Contacts to Display",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                  ),
                ),
          SizedBox(height: 20),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            Container(
              width: 400,
              height: 300,
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      top: BorderSide(
                        color: primaryColor,
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: primaryColor,
                        width: 1,
                      )),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ]),
              child: SafeArea(
                child: checkList(hiveContacts)
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: hiveContacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          ContactModel c = hiveContacts.elementAt(index);

                          return Card(
                            elevation: 6,
                            margin: EdgeInsets.all(10),
                            color: Colors.black54,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white, width: .5),
                            ),
                            child: ListTile(
                              onTap: () {},
                              leading: (c.avatar != null &&
                                      c.avatar?.isEmpty == true)
                                  ? CircleAvatar(
                                      backgroundImage: MemoryImage(c.avatar!))
                                  : CircleAvatar(child: Text(c.initials)),
                              trailing: Checkbox(
                                checkColor: Colors.white,
                                fillColor:
                                    MaterialStateProperty.resolveWith(getColor),
                                value: isContactInPod(c.id),
                                onChanged: (bool? value) {
                                  addToPod(c);
                                  isChecked = value!;
                                },
                              ),
                              title: Text(c.name,
                                  style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                        "No Contacts to Display",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      )),
              ),
            ),
          ]),
          SizedBox(
            height: 50,
          ),
          Center(
              child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: primaryColor),
              onPressed: () {
                bool podCreated = createPod();
                if (podCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New Pod Created!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('There was an issue creating your Pod')),
                  );
                }
              },
              child: const Text('Create Pod',
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
