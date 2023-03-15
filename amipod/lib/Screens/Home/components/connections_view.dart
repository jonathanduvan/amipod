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
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dipity/Screens/Home/components/add_button.dart';

import 'package:provider/provider.dart';

const List<Widget> lists = <Widget>[
  Text('Connections'),
  Text('Contacts'),
];

class ConnectionsView extends StatefulWidget {
  final int currentIndex;

  // final Box contactsBox;
  // final Box connectionsBox;
  // final Box podsBox;

  // final Iterable<dynamic>? hiveContacts;
  // final Iterable<dynamic>? hiveConnections;
  // final Iterable<dynamic>? hivePods;

  final String searchText;
  const ConnectionsView(
      {Key? key,
      required this.currentIndex,
      // required this.contactsBox,
      // required this.connectionsBox,
      // required this.podsBox,
      // this.hiveContacts,
      // this.hiveConnections,
      // this.hivePods,
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

  final List<bool> _selectedLists = <bool>[true, false];

  HiveAPI hiveApi = HiveAPI();

  int _start = 10;
  String page = 'Connections';
  late Timer _timer;

  bool checkTimer() {
    return _start == 0;
  }

  void _startTimer() {
    Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _start = 0;
        });
      }
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

  List<Widget> createPodList(Iterable<dynamic> hivePods) {
    List<Widget> listings = [];

    hivePods.forEach((element) {
      print(element);
      listings
          .add(IceCreamCard(flavorColor: primaryColor, flavor: element.name));
    });

    return listings;
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
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .updateConnections();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen

    Box? contactsBox = context.select<ConnectionsContactsModel, Box?>(
        (ccModel) => ccModel.contactsBox);
    Box? connectionsBox = context.select<ConnectionsContactsModel, Box?>(
        (ccModel) => ccModel.connectionsBox);
    Box? podsBox = context
        .select<ConnectionsContactsModel, Box?>((ccModel) => ccModel.podsBox);

    Iterable<dynamic> hiveContacts =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hiveContacts);
    Iterable<dynamic> hiveConnections =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hiveConnections);
    Iterable<dynamic> hivePods =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hivePods);

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
          child: checkList(hivePods)
              ? Container(
                  height: size.height * .15,
                  width: size.width * .80,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: createPodList(hivePods)),
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
        height: size.height * .40,
        child: _selectedLists[0] == true
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                Widget>[
                SafeArea(
                  child: checkList(hiveConnections)
                      ? SizedBox(
                          height: size.height * .40,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: hiveConnections.length,
                            itemBuilder: (BuildContext context, int index) {
                              ConnectionModel c =
                                  hiveConnections.elementAt(index);

                              return Card(
                                elevation: 6,
                                color: backgroundColor,
                                margin: EdgeInsets.all(10),
                                child: ListTile(
                                  onTap: () {},
                                  leading: (c.avatar != null &&
                                          c.avatar?.isEmpty == true)
                                      ? CircleAvatar(
                                          backgroundImage:
                                              MemoryImage(c.avatar!))
                                      : CircleAvatar(
                                          child: Text(
                                          c.initials,
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  title: Text(c.name,
                                      style: TextStyle(color: Colors.white)),
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
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                Widget>[
                SafeArea(
                  child: checkList(hiveContacts)
                      ? Container(
                          color: Colors.white,
                          width: size.width * .95,
                          height: size.height * .40,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: hiveContacts.length,
                            itemBuilder: (BuildContext context, int index) {
                              ContactModel c = hiveContacts.elementAt(index);
                              return Card(
                                elevation: 6,
                                margin: EdgeInsets.all(10),
                                color: backgroundColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.white, width: .5),
                                ),
                                child: ListTile(
                                  onTap: () {},
                                  leading: (c.avatar != null &&
                                          c.avatar?.isEmpty == true)
                                      ? CircleAvatar(
                                          backgroundImage:
                                              MemoryImage(c.avatar!))
                                      : CircleAvatar(
                                          child: Text(
                                            c.initials,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          backgroundColor: primaryColor,
                                        ),
                                  title: Text(c.name,
                                      style: TextStyle(color: Colors.white)),
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

class IceCreamCard extends StatelessWidget {
  const IceCreamCard({
    this.flavorColor = primaryColor,
    this.flavor = 'Flavor Name',
  });
  final Color flavorColor;
  final String flavor;
  @override
  Widget build(BuildContext context) {
    return Container(
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
      height: 200,
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
          SizedBox(
            height: 10.0,
          ),
          Text(
            flavor,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
