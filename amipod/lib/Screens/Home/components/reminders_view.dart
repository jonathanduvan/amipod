import 'package:flutter/material.dart';
import 'package:amipod/Screens/Home/components/background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:amipod/Screens/Home/components/add_button.dart';

class RemindersView extends StatefulWidget {
  final int currentIndex;
  const RemindersView({Key? key, required this.currentIndex}) : super(key: key);
  @override
  _RemindersViewState createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  PermissionStatus contactsStatus = PermissionStatus.denied;
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen

    return Background(
        child: ListView(
            padding: const EdgeInsets.only(top: 10.0),
            children: <Widget>[
          Container(
              color: Colors.white,
              width: size.width * .95,
              height: size.height * .40,
              child: Text(
                "No Reminders to Display",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12.0,
                ),
              )
              //   child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: <Widget>[
              //               SafeArea(
              //                 child: checkList(widget.hiveConnections!)
              //                     ? SizedBox(
              //                         height: size.height * .40,
              //                         child: ListView.builder(
              //                           scrollDirection: Axis.vertical,
              //                           shrinkWrap: true,
              //                           itemCount: widget.hiveConnections!.length,
              //                           itemBuilder: (BuildContext context, int index) {
              //                             ConnectionModel c =
              //                                 widget.hiveConnections!.elementAt(index);

              //                             return Card(
              //                               elevation: 6,
              //                               color: dipityBlack,
              //                               margin: EdgeInsets.all(10),
              //                               child: ListTile(
              //                                 onTap: () {},
              //                                 leading: (c.avatar != null &&
              //                                         c.avatar?.isEmpty == true)
              //                                     ? CircleAvatar(
              //                                         backgroundImage:
              //                                             MemoryImage(c.avatar!))
              //                                     : CircleAvatar(
              //                                         child: Text(
              //                                         c.initials,
              //                                         style: TextStyle(
              //                                             color: Colors.black),
              //                                       )),
              //                                 title: Text(c.name),
              //                               ),
              //                             );
              //                           },
              //                         ))
              //                     : Center(
              //                         child: checkTimer()
              //                             ? Text(
              //                                 "No Connections to Display",
              //                                 style: TextStyle(
              //                                   fontWeight: FontWeight.normal,
              //                                   fontSize: 12.0,
              //                                 ),
              //                               )
              //                             : CircularProgressIndicator(),
              //                       ),
              //               ),
              //             ])
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
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}
