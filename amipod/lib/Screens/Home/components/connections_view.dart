import 'dart:async';

import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Screens/Home/components/background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dipity/Screens/Home/components/popup.dart';

import 'package:provider/provider.dart';

const List<Widget> lists = <Widget>[
  Text('Connections'),
  Text('Contacts'),
];

class ConnectionsView extends StatefulWidget {
  final Function blockContact;
  final Function blockConnection;
  final Function inviteContact;
  final String searchText;
  final Function onSelect;
  const ConnectionsView(
      {Key? key,
      required this.blockContact,
      required this.blockConnection,
      required this.inviteContact,
      required this.onSelect,
      required this.searchText})
      : super(key: key);
  @override
  State<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<ConnectionsView> {
  PermissionStatus contactsStatus = PermissionStatus.denied;
  List<dynamic> displayContacts = [];
  Iterable<dynamic> displayConnections = [];
  Iterable<dynamic> displayPods = [];

  final List<bool> _selectedLists = <bool>[true, false];

  HiveAPI hiveApi = HiveAPI();

  int _start = 10;
  String page = 'Connections';

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .updateConnections();

    _startTimer();
  }

  bool checkTimer() {
    return mounted;
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _start = 0;
        });
      }
    });
  }

  searchPodList(Iterable<dynamic> infoList) {
    List<PodModel> searchedPods = [];
    List<PodModel> pods = [];
    for (PodModel pod in infoList) {
      String data = pod.name;

      if (data.toLowerCase().contains(widget.searchText.toLowerCase())) {
        searchedPods.add(pod);
      } else {
        bool inPod = false;
        if (pod.connections != null) {
          List podConns = pod.connections!.toList();
          for (ConnectionModel connection in podConns) {
            if (connection.name
                .toLowerCase()
                .contains(widget.searchText.toLowerCase())) {
              searchedPods.add(pod);
              inPod = true;
              break;
            }
            ;
          }
        }
        if ((pod.contacts != null) && (inPod == false)) {
          List podConns = pod.contacts!.toList();
          for (ContactModel contact in podConns) {
            if (contact.name
                .toLowerCase()
                .contains(widget.searchText.toLowerCase())) {
              searchedPods.add(pod);
              inPod = true;
              break;
            }
            ;
          }
        }
      }
    }

    setState(() {
      displayPods = searchedPods;
    });
  }

  searchContactList(Iterable<dynamic> infoList) {
    List<ContactModel> searchedContacts = [];
    for (ContactModel contact in infoList) {
      String data = contact.name;
      if (data.toLowerCase().contains(widget.searchText.toLowerCase())) {
        searchedContacts.add(contact);
      }
    }

    setState(() {
      displayContacts = searchedContacts;
    });
  }

  searchConnectionList(Iterable<dynamic> infoList) {
    List<ConnectionModel> searchedConnections = [];
    for (ConnectionModel contact in infoList) {
      String data = contact.name;

      if (data.toLowerCase().contains(widget.searchText.toLowerCase())) {
        searchedConnections.add(contact);
      }
    }

    setState(() {
      displayConnections = searchedConnections;
    });
  }

  List<Widget> createPodList(Iterable<dynamic> hivePods) {
    List<Widget> listings = [];

    for (PodModel element in hivePods) {
      listings.add(PodCard(
          flavorColor: primaryColor,
          flavor: element.name,
          pod: element,
          onSelect: widget.onSelect));
    }

    return listings;
  }

  bool checkList(Iterable<dynamic> infoList, String type) {
    bool passCheck = true;
    if (infoList.isNotEmpty) {
      if (widget.searchText != '') {
        if (type == 'pod') {
          searchPodList(infoList);
        } else if (type == 'contact') {
          searchContactList(infoList);
        } else if (type == 'connection') {
          searchConnectionList(infoList);
        }
      } else {
        if (type == 'pod') {
          setState(() {
            displayPods = infoList;
          });
        } else if (type == 'contact') {
          setState(() {
            displayContacts = infoList.toList();
          });
        } else if (type == 'connection') {
          setState(() {
            displayConnections = infoList;
          });
        }
      }
    } else {
      if (type == 'connection') {
        print(infoList.toList());
      }
      passCheck = false;
    }

    return passCheck;
  }

  confirmBlockContact(ContactModel c) async {
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .blockContact(c.id);
    Navigator.of(context).pop();
    Provider.of<ConnectionsContactsModel>(context, listen: false).contacts;
  }

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    Box connectionsBox = context.select<ConnectionsContactsModel, Box>(
        (ccModel) => ccModel.connectionsBox);
    Box contactsBox = context.select<ConnectionsContactsModel, Box>(
        (ccModel) => ccModel.contactsBox);
    Provider.of<ConnectionsContactsModel>(context, listen: true).connections;
    Provider.of<ConnectionsContactsModel>(context, listen: true).contacts;
    List<dynamic> hiveContacts =
        context.select<ConnectionsContactsModel, List<dynamic>>(
            (ccModel) => ccModel.hiveContacts);

    Iterable<dynamic> hiveConnections =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hiveConnections);
    Iterable<dynamic> hivePods =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hivePods);

    return Background(
        child: ListView(
            padding: const EdgeInsets.only(top: 10.0),
            children: <Widget>[
          SizedBox(
            height: 15.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Pods',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 25)),
              ],
            ),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SafeArea(
                  child: checkList(hivePods, 'pod')
                      ? Container(
                          height: size.height * .15,
                          width: size.width * .80,
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: createPodList(displayPods)),
                            ),
                          ))
                      : Container(
                          width: size.width * .95,
                          child: Center(
                            child: Text(
                              "No Pods to Display",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12.0,
                              ),
                            ),
                          )),
                ),
              ]),
          SizedBox(
            height: 36.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ToggleButtons(
                direction: Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedLists.length; i++) {
                      _selectedLists[i] = i == index;
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: primaryColor,
                selectedColor: backgroundColor,
                fillColor: primaryColor,
                color: backgroundColor,
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 100.0,
                ),
                isSelected: _selectedLists,
                children: lists,
              ),
            ],
          ),
          Container(
            color: Colors.white,
            width: size.width * .95,
            height: size.height * .50,
            child: _selectedLists[0] == true
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        SafeArea(
                          child: checkList(hiveConnections, 'connection')
                              ? SizedBox(
                                  height: size.height * .45,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: displayConnections.length,
                                    itemBuilder:
                                        (BuildContext itemContext, int index) {
                                      ConnectionModel c =
                                          displayConnections.elementAt(index);

                                      return Card(
                                        elevation: 6,
                                        color: backgroundColor,
                                        margin: EdgeInsets.all(10),
                                        child: ListTile(
                                          onTap: () {
                                            widget.onSelect(c.id, 'connection');
                                          },
                                          leading: (c.avatar != null &&
                                                  c.avatar?.isEmpty == true)
                                              ? CircleAvatar(
                                                  backgroundImage:
                                                      MemoryImage(c.avatar!))
                                              : CircleAvatar(
                                                  backgroundColor: primaryColor,
                                                  child: Text(
                                                    c.initials,
                                                    style: TextStyle(
                                                        color: backgroundColor),
                                                  )),
                                          title: Text(c.name,
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          subtitle: Text(
                                              c.city ?? 'Not Available',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 14)),
                                        ),
                                      );
                                    },
                                  ))
                              : Center(
                                  child: checkTimer()
                                      ? Text(
                                          "No Connections to Display",
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12.0,
                                          ),
                                        )
                                      : CircularProgressIndicator(),
                                ),
                        ),
                      ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        SafeArea(
                          child: checkList(hiveContacts, 'contact')
                              ? Container(
                                  color: Colors.white,
                                  width: size.width * .95,
                                  height: size.height * .45,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: displayContacts.length,
                                    itemBuilder:
                                        (BuildContext itemContext, int index) {
                                      ContactModel c =
                                          displayContacts.elementAt(index);
                                      List<PopupMenuEntry> options = [
                                        PopupMenuItem(
                                          value: 'invite',
                                          child: Text('Invite',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor)),
                                          onTap: () {},
                                        ),
                                        const PopupMenuItem(
                                          value: 'block',
                                          child: Text('Block',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red)),
                                        )
                                      ];
                                      return Card(
                                        elevation: 6,
                                        margin: EdgeInsets.all(10),
                                        color: backgroundColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.white, width: .5),
                                        ),
                                        child: ListTile(
                                          leading: (c.avatar != null &&
                                                  c.avatar?.isEmpty == true)
                                              ? CircleAvatar(
                                                  backgroundImage:
                                                      MemoryImage(c.avatar!))
                                              : CircleAvatar(
                                                  child: Text(
                                                    c.initials,
                                                    style: TextStyle(
                                                        color: backgroundColor),
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                ),
                                          trailing: PopupMenuButton(
                                            child: Container(
                                              // padding: EdgeInsets.all(15),
                                              // decoration: ShapeDecoration(
                                              //   color: primaryColor,
                                              //   shape: CircleBorder(),
                                              // ),
                                              child: const Icon(
                                                Icons.more_horiz,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            onSelected: (value) async {
                                              switch (value) {
                                                case 'block':
                                                  String title =
                                                      'Block ${c.name} ?';
                                                  String content =
                                                      'If you decide to change your mind, go to Profile -> Block List';

                                                  return showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                        diaContext) {
                                                      return showAlertDialog(
                                                          context,
                                                          title,
                                                          content,
                                                          () =>
                                                              confirmBlockContact(
                                                                  c));
                                                    },
                                                  );
                                                case 'invite':
                                                  return widget
                                                      .inviteContact(c.phone);
                                                default:
                                                  throw UnimplementedError();
                                              }
                                            },
                                            itemBuilder: (context) => options,
                                          ),
                                          title: Text(c.name,
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      );
                                    },
                                  ))
                              : Center(
                                  child: checkTimer()
                                      ? Text(
                                          "No Contacts to Display",
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12.0,
                                          ),
                                        )
                                      : CircularProgressIndicator()),
                        ),
                      ]),
          ),
        ]));
  }
}

class PodCard extends StatelessWidget {
  const PodCard(
      {this.flavorColor = primaryColor,
      this.flavor = 'Flavor Name',
      required this.pod,
      required this.onSelect});
  final Color flavorColor;
  final String flavor;
  final PodModel pod;
  final Function onSelect;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => {onSelect(pod.id, 'pod')},
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffeeeeee), width: 2.0),
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.white10,
                blurRadius: 4,
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          margin: EdgeInsets.all(8),
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: SvgPicture.asset(
                'assets/images/dipity.svg',
                width: 80,
                height: 80,
              )),
              Text(
                flavor,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    color: Colors.white),
              ),
            ],
          ),
        ));
  }
}
