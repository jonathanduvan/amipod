import 'dart:async';

import 'package:amipod/HiveModels/connection_model.dart';
import 'package:amipod/HiveModels/contact_model.dart';
import 'package:amipod/HiveModels/pod_model.dart';
import 'package:amipod/Services/hive_api.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
import 'package:amipod/Screens/Home/components/background.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:amipod/Screens/Home/components/add_button.dart';

class ConnectionsView extends StatefulWidget {
  final int currentIndex;

  final Box contactsBox;
  final Box connectionsBox;
  final Box podsBox;

  final Iterable<dynamic>? hiveContacts;
  final Iterable<dynamic>? hiveConnections;
  final Iterable<dynamic>? hivePods;

  final String searchText;
  const ConnectionsView(
      {Key? key,
      required this.currentIndex,
      required this.contactsBox,
      required this.connectionsBox,
      required this.podsBox,
      this.hiveContacts,
      this.hiveConnections,
      this.hivePods,
      required this.searchText})
      : super(key: key);
  @override
  State<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<ConnectionsView> {
  PermissionStatus contactsStatus = PermissionStatus.denied;
  List<ContactModel> contacts = [];
  List<ConnectionModel> connections = [];
  List<PodModel> pods = [];

  HiveAPI hiveApi = HiveAPI();

  int _start = 10;
  late Timer _timer;

  bool checkTimer() {
    return _start == 0;
  }

  void _startTimer() {
    Timer(const Duration(seconds: 7), () {
      setState(() {
        _start = 0;
      });
    });
  }

  List<dynamic> searchPodList(Iterable<dynamic> infoList) {
    List<dynamic> searchedPods = [];
    List<PodModel> pods = [];
    for (PodModel pod in infoList) {
      String data = pod.name;

      if (data.toLowerCase().contains(widget.searchText.toLowerCase())) {
        searchedPods.add(pod);
      }
    }
    return searchedPods;
  }

  bool checkList(Iterable<dynamic> infoList) {
    if (infoList.isNotEmpty) {
      if (widget.searchText != '') {
        var firstEle = infoList.first;

        if (firstEle is ContactModel) {
          searchPodList(infoList);
        } else if (firstEle is ConnectionModel) {
          // searchConnectionList(infoList);
        } else {
          // searchContactList(infoList);
        }
      }

      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: ListView(padding: const EdgeInsets.only(top: 10.0), children: <
            Widget>[
      SizedBox(
        height: 36.0,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Pods",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        SafeArea(
          child: checkList(widget.hivePods!)
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: widget.hivePods!.length,
                  itemBuilder: (BuildContext context, int index) {
                    PodModel c = widget.hivePods!.elementAt(index);
                    return Card(
                      color: dipityBlack,
                      elevation: 6,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () {},
                        leading: (c.avatar != null && c.avatar?.isEmpty == true)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(c.avatar!))
                            : CircleAvatar(
                                child: Text(
                                  c.name[0],
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor: podOrange),
                        title:
                            Text(c.name, style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    "No Pods to Display",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0,
                    ),
                  ),
                ),
        ),
      ]),
      SizedBox(
        height: 36.0,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Connections",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        SafeArea(
          child: checkList(widget.hiveConnections!)
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: widget.hiveConnections!.length,
                  itemBuilder: (BuildContext context, int index) {
                    ConnectionModel c =
                        widget.hiveConnections!.elementAt(index);

                    return Card(
                      elevation: 6,
                      color: dipityBlack,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () {},
                        leading: (c.avatar != null && c.avatar?.isEmpty == true)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(c.avatar!))
                            : CircleAvatar(
                                child: Text(
                                c.initials,
                                style: TextStyle(color: Colors.black),
                              )),
                        title: Text(c.name),
                      ),
                    );
                  },
                )
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
      ]),
      SizedBox(
        height: 36.0,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Contacts",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        SafeArea(
          child: checkList(widget.hiveContacts!)
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: widget.hiveContacts!.length,
                  itemBuilder: (BuildContext context, int index) {
                    ContactModel c = widget.hiveContacts!.elementAt(index);
                    return Card(
                      elevation: 6,
                      margin: EdgeInsets.all(10),
                      color: dipityBlack,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white, width: .5),
                      ),
                      child: ListTile(
                        onTap: () {},
                        leading: (c.avatar != null && c.avatar?.isEmpty == true)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(c.avatar!))
                            : CircleAvatar(
                                child: Text(
                                  c.initials,
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor: primaryColor,
                              ),
                        title:
                            Text(c.name, style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                )
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
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Spacer(),
        ],
      ),
    ]));
  }
}

/// Permission widget containing information about the passed [Permission]
class PermissionWidget extends StatefulWidget {
  /// Constructs a [PermissionWidget] for the supplied [Permission]
  const PermissionWidget(this._permission);

  final Permission _permission;
  @override
  _PermissionState createState() => _PermissionState(_permission);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission);

  final Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.limited:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        _permission.toString(),
        style: Theme.of(context).textTheme.bodyText1,
      ),
      subtitle: Text(
        _permissionStatus.toString(),
        style: TextStyle(color: getPermissionColor()),
      ),
      trailing: (_permission is PermissionWithService)
          ? IconButton(
              icon: const Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
                checkServiceStatus(
                    context, _permission as PermissionWithService);
              })
          : null,
      onTap: () {
        requestPermission(_permission);
      },
    );
  }

  void checkServiceStatus(
      BuildContext context, PermissionWithService permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.serviceStatus).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      _permissionStatus = status;
    });
  }
}
