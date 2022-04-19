import 'dart:convert' show base64Url, base64UrlEncode;
import 'package:amipod/HiveModels/contact_model.dart';
import 'package:amipod/HiveModels/pod_model.dart';
import 'package:amipod/Screens/Home/components/connections_view.dart';
import 'package:amipod/Screens/Home/components/events_view.dart';
import 'package:amipod/Screens/Home/components/home_view.dart';
import 'package:amipod/Screens/Home/components/reminders_view.dart';
import 'package:amipod/Screens/Home/components/map.dart';
import 'package:amipod/Screens/Login/login_screen.dart';
import 'package:amipod/Services/encryption.dart';
import 'package:amipod/Services/hive_api.dart';
import 'package:amipod/Services/secure_storage.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
// import 'package:geocode/geocode.dart';
import 'package:amipod/Screens/Home/components/add_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uuid/uuid.dart';

import 'components/add_panel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static int connectionsIndex = 1;
  bool displayMap = false;
  List<Widget> pageList = [];
  List<Contact> allContacts = [];
  List<LatLng> allContactLocations = []; // Will need to be a widget later

  List<ConnectedContact> connectedContacts = [];
  List<ContactModel> connections = [];

  List<UnconnectedContact> unconnectedContacts = [];
  List<ContactModel> contacts = [];

  List<Pod> allPods = [];
  List<PodModel> pods = [];

  String addOptionSelected = '';

  List<List<String>> addOptions = [
    [],
    [newConnectionText, newPodText],
    [newEventText],
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

  PanelController _pc = new PanelController();

  SecureStorage storage = SecureStorage();
  EncryptionManager encrypter = EncryptionManager();

  HiveAPI hiveApi = HiveAPI();

  late Box connectionsBox;
  late Box contactsBox;
  late Box podsBox;

  bool _isAddButtonVisible = true;

  void checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> allValues = await storage.readAllSecureData();
    var userPhone = allValues[userPhoneNumberKeyName];

    var userId;

    String encryptContactsKey;
    String encryptConnectionsKey;
    String encryptPodsKey;
    String encryptRemindersKey;

    Box tempContactsBox;
    Box tempConnectionsBox;
    Box tempPodsBox;
    Box tempRemindersBox;

    // Check status of user Id
    if (allValues[idKeyName] == null) {
      var userRawId = 'dipity_userid:$userPhone';
      userId = encrypter.encryptData(userRawId);
      await storage.writeSecureData(idKeyName, userId);
    } else {
      userId = allValues[idKeyName];
    }

    // Check status of Contacts Hive Box
    if (allValues[unconnectedContactsStorageKeyName] == null) {
      var contactsKey = Hive.generateSecureKey();
      encryptContactsKey = base64UrlEncode(contactsKey);

      await storage.writeSecureData(
          unconnectedContactsStorageKeyName, encryptContactsKey);

      tempContactsBox = await hiveApi.createContactsBox(contactsKey);
    } else {
      encryptContactsKey = allValues[unconnectedContactsStorageKeyName]!;
      tempContactsBox = hiveApi.openContactsBox();
    }

    // Check status of Connections Hive Box
    if (allValues[connectionsStorageKeyName] == null) {
      var connectionsKey = Hive.generateSecureKey();
      encryptConnectionsKey = base64UrlEncode(connectionsKey);

      await storage.writeSecureData(
          connectionsStorageKeyName, encryptConnectionsKey);

      tempConnectionsBox = await hiveApi.createConnectionsBox(connectionsKey);
    } else {
      encryptConnectionsKey = allValues[connectionsStorageKeyName]!;
      tempConnectionsBox = hiveApi.openConnectionsBox();
    }

    // Check status of Pods Hive Box
    if (allValues[podsStorageKeyName] == null) {
      var podsKey = Hive.generateSecureKey();
      encryptPodsKey = base64UrlEncode(podsKey);

      await storage.writeSecureData(podsStorageKeyName, encryptPodsKey);

      tempPodsBox = await hiveApi.createPodBox(podsKey);
    } else {
      encryptPodsKey = allValues[podsStorageKeyName]!;
      tempPodsBox = hiveApi.openPodsBox();
    }

    setState(() {
      connectionsBox = tempConnectionsBox;
      contactsBox = tempContactsBox;
      podsBox = tempPodsBox;
      // remindersBox = tempRemindersBox;
    });

    addPageLists();
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getLocationPermission();
    if (permissionStatus == PermissionStatus.granted) {
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

  void _getAllContacts(ContactsMap mapContacts) async {
    setState(() {
      connectedContacts = mapContacts.connected!;
      unconnectedContacts = mapContacts.unconnected!;
    });

    updateContacts();
  }

  void _getAllPods(Map<String, Pod> podsCreated) {
    if ((podsCreated.isEmpty & allPods.isEmpty) == false) {
      setState(() {
        allPods = allPods;
      });
    }
  }

  void addPageLists() {
    pageList.add(HomeView(currentIndex: _selectedIndex));
    pageList.add(ConnectionsView(
      currentIndex: _selectedIndex,
      getAllContacts: _getAllContacts,
      getAllPods: _getAllPods,
      contactsBox: contactsBox,
      connectionsBox: connectionsBox,
      podsBox: podsBox,
    ));
    pageList.add(EventsView(currentIndex: _selectedIndex));
    pageList.add(RemindersView(currentIndex: _selectedIndex));
  }

  @override
  void initState() {
    updateSharedPreferences();
    checkUserStatus();
    super.initState();
    _askPermissions();
  }

  void updateSharedPreferences() {
    updateLoginState(true);
  }

  Future<bool> updateLoginState(bool login) async {
    final prefs = await SharedPreferences.getInstance();

    // Save an String value to 'firstName' and 'lastName keys.

    if (login) {
      await prefs.setBool(LoggedInKey, true);
    } else {
      await prefs.setBool(LoggedInKey, false);
    }
    return login;
  }

  bool onConnectionsPage(int index) {
    return (connectionsIndex == index);
  }

  bool _getAddButtonStatus() {
    return (_selectedIndex != 0) && _isAddButtonVisible;
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

  void updateContacts() {
    if (contactsBox.isEmpty) {
      addAllContacts();
    } else {
      hiveApi.addMissingContacts(
          encrypter, contactsBox, connectionsBox, unconnectedContacts);
    }
  }

  void addAllContacts() {
    for (var element in unconnectedContacts) {
      hiveApi.createAndAddContact(encrypter, contactsBox, element);
    }
  }

  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
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
                Hive.close();
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
          preferredSize: Size.fromHeight(50.0),
          child: Column(children: <Widget>[
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      /* Clear the search field */
                    },
                  ),
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none),
            ),
            Row(
              children: pageSearchTags[_selectedIndex]
                  .map((tagModel) => tagChip(
                        tagModel: tagModel,
                        action: 'Remove',
                      ))
                  .toSet()
                  .toList(),
            )
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
        color: Colors.deepOrange,
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
            ? MapView(contacts: connectedContacts)
            : IndexedStack(
                index: _selectedIndex,
                children: pageList,
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
                BottomNavigationBarItem(
                  backgroundColor: backgroundColor,
                  icon: Icon(Icons.people),
                  label: 'Connections',
                ),
                BottomNavigationBarItem(
                  backgroundColor: backgroundColor,
                  icon: Icon(Icons.calendar_today),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  backgroundColor: backgroundColor,
                  icon: Icon(Icons.alarm),
                  label: 'Reminders',
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
