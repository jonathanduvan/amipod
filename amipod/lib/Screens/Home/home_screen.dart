import 'dart:convert' show base64Decode, base64Url, base64UrlEncode;
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/Screens/Home/components/connections_view.dart';
import 'package:dipity/Screens/Home/components/events_view.dart';
import 'package:dipity/Screens/Home/components/home_view.dart';
import 'package:dipity/Screens/Home/components/reminders_view.dart';
import 'package:dipity/Screens/Home/components/map.dart';
import 'package:dipity/Screens/Login/login_screen.dart';
import 'package:dipity/Services/encryption.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:dipity/Services/secure_storage.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dipity/Services/user_management.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
// import 'package:geocode/geocode.dart';
import 'package:dipity/Screens/Home/components/add_button.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'components/add_panel.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool displayMap = false;

  List<double> userPosition = [];
  String userLocation = 'Not Available';

  String addOptionSelected = '';
  String searchText = '';

  List<List<String>> addOptions = [
    // [],
    [newPodText],
    // [newEventText],
    [newReminderText]
  ];
  List<LatLng> testUSLocations = [
    LatLng(30.386308848515, -82.674663546642),
    LatLng(30.2304846, -82.0428185),
    LatLng(38.922063, -76.9965217),
    LatLng(43.4265187, -72.3217558)
  ];

  List<List> pageSearchTags = [
    connectionTags,
    connectionTags,
    connectionTags,
    connectionTags
  ]; // TODO: Update to tags for other pages

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  double _panelHeightClosed = 0.0;
  double _panelHeightOpen = 0.0;

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  final PanelController _pc = PanelController();

  SecureStorage storage = SecureStorage();
  EncryptionManager encrypter = EncryptionManager();

  HiveAPI hiveApi = HiveAPI();
  UserManagement userManagement = UserManagement();

  bool _isAddButtonVisible = true;

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getLocationPermission();
    print(permissionStatus);
    if (permissionStatus == PermissionStatus.granted) {
      updateUserLocation();
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar = SnackBar(
          content: Text(
              'Location permission denied. Please open the Settings app to allow access.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<PermissionStatus> _getLocationPermission() async {
    PermissionStatus permission = await Permission.location.status;
    if (permission == PermissionStatus.denied) {
      PermissionStatus permissionStatus = await Permission.location.request();
      return permissionStatus;
    }
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.location.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void updateUserLocation() async {
    Position currPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.lowest);
    bool servicestatus = await Geolocator.isLocationServiceEnabled();
    // Position currPosition = Position(longitude: longitude, latitude: latitude, timestamp: timestamp, accuracy: accuracy, altitude: altitude, heading: heading, speed: speed, speedAccuracy: speedAccuracy)
    if (servicestatus) {
      print("GPS service is enabled");
    } else {
      print("GPS service is disabled.");
    }
    print('okay am i updatring location');
    print(currPosition);
    userManagement.updateUserLocation(currPosition).then((currLocation) {
      print('updated user location');
      print(currLocation['position']);
      setState(() {
        userPosition = currLocation['position'];
        userLocation = currLocation['location'];
      });
    });
  }

  void _onPanelOpened(option) {
    _pc.open();
    setState(() {
      addOptionSelected = option;
    });
  }

  void _closePanel() {
    _pc.close();
  }

  void _onItemTapped(int index) {
    if (_pc.isAttached & _pc.isPanelOpen) {
      _closePanel();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDisplayMapPage() {
    setState(() {
      displayMap = !displayMap;
    });
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    await Future.delayed(Duration(seconds: 6));
    var rawContacts = (await ContactsService.getContacts());
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          ;

    if (rawContacts != null) {
      // Update logic to work with provider and hive entirely
      _getAllContacts(rawContacts);
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

    // var address = await _getAddress(latlong.latitude, latlong.longitude);

    // var addressParts = address.toString().split(";");

    for (var i = 0; i < contacts.length; i++) {
      var currContacts = contacts[i];
      if ((currContacts.displayName != null) &&
          (currContacts.phones!.isNotEmpty)) {
        String name = currContacts.displayName!;
        if (name.contains('Andrew Crutchfield')) {
          print(currContacts.phones![0].value!);
        }
        var unconCon = UnconnectedContact(
          name: currContacts.displayName!,
          initials: currContacts.initials(),
          avatar: currContacts.avatar,
          phone: currContacts.phones![0].value!,
        );

        unconnected.add(unconCon);
      }
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
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .updateContacts(mapContacts.unconnected!);
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .updateConnections();
    Provider.of<ConnectionsContactsModel>(context, listen: false).contacts;
    Provider.of<ConnectionsContactsModel>(context, listen: false).connections;
    Provider.of<ConnectionsContactsModel>(context, listen: false).pods;
  }

  @override
  void initState() {
    super.initState();
    updateLoginState(true);
    refreshContacts();
    _askPermissions();
  }

  Future<bool> updateLoginState(bool login) async {
    final prefs = await SharedPreferences.getInstance();

    // Save an String value to 'firstName' and 'lastName keys.

    if (login) {
      await prefs.setBool(loggedInKey, true);
    } else {
      await prefs.setBool(loggedInKey, false);
    }
    return login;
  }

  bool onConnectionsPage(int index) {
    return true;
  }

  bool _getAddButtonStatus() {
    return true;
  }

  void displayAddButton() {
    setState(() {
      _isAddButtonVisible = true;
    });
  }

  void hideAddButton() {
    setState(() {
      _isAddButtonVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height;

    Box? contactsBox = context.select<ConnectionsContactsModel, Box?>(
        (ccModel) => ccModel.contactsBox);
    Box? connectionsBox = context.select<ConnectionsContactsModel, Box?>(
        (ccModel) => ccModel.connectionsBox);
    Box? podsBox = context
        .select<ConnectionsContactsModel, Box?>((ccModel) => ccModel.podsBox);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: backgroundColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                updateLoginState(false).then((value) =>
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        ModalRoute.withName("/WelcomeScreen")));
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Column(children: <Widget>[
            // TextField(
            //   style: TextStyle(color: Colors.white),
            //   decoration: InputDecoration(
            //       prefixIcon: Icon(Icons.search),
            //       suffixIcon: IconButton(
            //         icon: Icon(Icons.clear),
            //         onPressed: () {
            //           /* Clear the search field */
            //         },
            //       ),
            //       hintText: 'Search...',
            //       hintStyle: TextStyle(color: Colors.white),
            //       border: InputBorder.none),
            //   onChanged: (value) {
            //     print(value);
            //     setState(() {
            //       searchText = value;
            //     });
            //   },
            // ),
            // Row(
            //   children: pageSearchTags[_selectedIndex]
            //       .map((tagModel) => tagChip(
            //             tagModel: tagModel,
            //             action: 'Remove',
            //           ))
            //       .toSet()
            //       .toList(),
            // )
          ]),
        ),
        actions: <Widget>[
          onConnectionsPage(_selectedIndex)
              ? IconButton(
                  icon: Icon(
                    displayMap ? Icons.list : Icons.map_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _onDisplayMapPage();
                  },
                )
              : Container(),
        ],
      ),
      floatingActionButton: Visibility(
          visible: (_getAddButtonStatus()),
          child: AddButtonWidget(
            currentIndex: _selectedIndex,
            addButtonOptions: addOptions[_selectedIndex],
            onAddPressed: _onPanelOpened,
          )),
      body: SlidingUpPanel(
        controller: _pc,
        color: Colors.black87,
        panelBuilder: (ScrollController sc) => _addPanel(sc),
        borderRadius: radius,
        onPanelClosed: () {
          displayAddButton();
        },
        onPanelOpened: () {
          hideAddButton();
        },
        defaultPanelState: PanelState.CLOSED,
        maxHeight: _panelHeightOpen,
        minHeight: _panelHeightClosed,
        body: displayMap
            ? MapView(
                userPosition: userPosition,
              )
            : IndexedStack(
                index: _selectedIndex,
                children: [
                  // HomeView(currentIndex: _selectedIndex),
                  ConnectionsView(
                      currentIndex: _selectedIndex, searchText: searchText),
                  // EventsView(currentIndex: _selectedIndex),
                  RemindersView(currentIndex: _selectedIndex)
                ],
              ),
      ),
      bottomNavigationBar: displayMap
          ? Container(height: 0)
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  backgroundColor: backgroundColor,
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                // BottomNavigationBarItem(
                //   backgroundColor: backgroundColor,
                //   icon: Icon(Icons.people),
                //   label: 'Connections',
                // ),
                // BottomNavigationBarItem(
                //   backgroundColor: backgroundColor,
                //   icon: Icon(Icons.calendar_today),
                //   label: 'Events',
                // ),
                BottomNavigationBarItem(
                  backgroundColor: backgroundColor,
                  icon: Icon(Icons.alarm),
                  label: 'Check-Ins',
                ),
              ],
              unselectedItemColor: Colors.white,
              backgroundColor: backgroundColor,
              currentIndex: _selectedIndex,
              selectedItemColor: primaryColor,
              onTap: _onItemTapped,
            ),
    );
  }

  Widget _addPanel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: addPanelForm(sc, addOptionSelected));
  }

  Widget tagChip({
    tagModel,
    onTap,
    action,
  }) {
    return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: tagModel
                        .tagColor, //                   <--- border color
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  '${tagModel.title}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
