import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
import 'package:amipod/Screens/Home/components/background.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:amipod/Screens/Home/components/add_button.dart';

class ConnectionsView extends StatefulWidget {
  final int currentIndex;
  final Function getAllContacts;

  const ConnectionsView({
    Key? key,
    required this.currentIndex,
    required this.getAllContacts,
  }) : super(key: key);
  @override
  _ConnectionsViewState createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends State<ConnectionsView> {
  PermissionStatus contactsStatus = PermissionStatus.denied;
  List<Contact> _contacts = [];
  List<ConnectedContact> connectedContacts = [];
  List<UnconnectedContact> unconnectedContacts = [];

  List<String> addOptions = ['New Connection', 'New Pod'];

  List<LatLng> testUSLocations = [
    LatLng(30.386308848515, -82.674663546642),
    LatLng(30.2304846, -82.0428185),
    LatLng(38.922063, -76.9965217),
    LatLng(43.4265187, -72.3217558)
  ];
  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts());
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          ;
    if (contacts != null) {
      _getAllContacts(contacts);
    }
  }

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    GeoCode geoCode = GeoCode();
    // Address address =
    //     await geoCode.reverseGeocoding(latitude: lat, longitude: lang);

    // return "${address.streetAddress}; ${address.city}; ${address.countryName}; ${address.postal}";
    return "test st; Testville; US; 33071";
  }

  Future<ContactsMap> _updateConnectedContacts(List<Contact> contacts) async {
    List<ConnectedContact> connected = [];
    List<UnconnectedContact> unconnected = [];

    // Check for if connected goes here

    // Dummy code for creating connectedContact list
    int howMany = 3;

    for (var i = 0; i < howMany; i++) {
      var latlong = testUSLocations[i];

      var address = await _getAddress(latlong.latitude, latlong.longitude);

      var addressParts = address.toString().split(";");

      var conCon = ConnectedContact(
          name: contacts[i].displayName!,
          initials: contacts[i].initials(),
          avatar: contacts[i].avatar,
          phone: contacts[i].phones![0].value!,
          location: testUSLocations[i],
          street: addressParts[0],
          city: addressParts[1]);

      contacts.removeAt(i);
      connected.add(conCon);
    }
    for (var i = 0; i < contacts.length; i++) {
      var unconCon = UnconnectedContact(
        name: contacts[i].displayName!,
        initials: contacts[i].initials(),
        avatar: contacts[i].avatar,
        phone: contacts[i].phones![0].value!,
      );

      unconnected.add(unconCon);
    }

    var allContacts =
        ContactsMap(connected: connected, unconnected: unconnected);
    return allContacts;

    // connected = contacts.
  }

  void _getAllContacts(List<Contact> contacts) async {
    // Lazy load thumbnails after rendering initial contacts.

    //TODO: Function to check if contact is connected or not goes here

    var mapContacts = await _updateConnectedContacts(contacts);

    print(mapContacts.connected!.length);
    print(mapContacts.unconnected!.length);
    widget.getAllContacts(mapContacts);

    setState(() {
      _contacts = contacts;
      connectedContacts = mapContacts.connected!;
      unconnectedContacts = mapContacts.unconnected!;
    });
  }

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
          child: connectedContacts != null
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: connectedContacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    ConnectedContact c = connectedContacts.elementAt(index);

                    return Card(
                      elevation: 6,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () {},
                        leading: (c.avatar != null && c.avatar?.isEmpty == true)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(c.avatar!))
                            : CircleAvatar(child: Text(c.initials)),
                        title: Text(c.name),
                      ),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
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
          child: unconnectedContacts != null
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: unconnectedContacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    UnconnectedContact c = unconnectedContacts.elementAt(index);

                    return Card(
                      elevation: 6,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () {},
                        leading: (c.avatar != null && c.avatar?.isEmpty == true)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(c.avatar!))
                            : CircleAvatar(child: Text(c.initials)),
                        title: Text(c.name),
                      ),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ]),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Spacer(),
          AddButtonWidget(
            currentIndex: widget.currentIndex,
            addButtonOptions: addOptions,
          )
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
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}
