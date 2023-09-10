import 'dart:convert' show base64Decode, base64Url, base64UrlEncode;
import 'dart:io';
import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/Screens/Home/components/connections_view.dart';
import 'package:dipity/Screens/Home/components/events_view.dart';
import 'package:dipity/Screens/Home/components/home_view.dart';
import 'package:dipity/Screens/Home/components/search_bar.dart';
import 'package:dipity/Screens/Home/components/viewPanels/view_blocked_contacts.dart';
import 'package:dipity/Services/notificationManager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dipity/Screens/Home/components/reminders_view.dart';
import 'package:dipity/Screens/Home/components/map.dart';
import 'package:dipity/Screens/Login/login_screen.dart';
import 'package:dipity/Screens/Welcome/welcome_screen.dart';
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
import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'components/add_pod_panel.dart';
import 'components/add_reminder_panel.dart';

import 'components/popup.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  int indexStackindex = 0;
  bool displayMap = false;

  List<double> userPosition = [];
  String userLocation = 'Not Available';
  final searchTextController = TextEditingController();

  String addOptionSelected = '';

  String? selectedID;
  String? selectedType;

  String? selectedConnection;
  String? selectedPod;

  bool unchartedMode = false;

  String searchText = '';
  Map<String, ContactModel> searchedContacts = {};
  Map<String, ConnectionModel> searchedConnections = {};

  dynamic checkInPerson = {};

  Map<String, String> allValues = {};

  String firstName = 'Menu';
  String lastName = ' ';
  String userPhone = '';

  bool _IsAddSearching = false;

  Iterable<dynamic>? hiveContacts;
  Iterable<dynamic>? hiveConnections;

  Box? podsBox;
  Box? connectionsBox;
  Box? contactsBox;

  late SharedPreferences prefs;

  List<String> addOptions = [newPodText, newReminderText];

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

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    userManagement.checkUserStatus();
    updateLoginState(true);
    _askPermissions();

    // Provider.of<ConnectionsContactsModel>(context, listen: true).connections;
    pullUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hiveConnections = context.read<ConnectionsContactsModel>().hiveConnections;
    hiveContacts = context.read<ConnectionsContactsModel>().hiveContacts;
    podsBox = context.read<ConnectionsContactsModel>().podsBox;
    connectionsBox = context.read<ConnectionsContactsModel>().connectionsBox;
    contactsBox = context.read<ConnectionsContactsModel>().contactsBox;

    // Iterable<dynamic> hivePods =
    //     context.select<ConnectionsContactsModel, Iterable<dynamic>>(
    //         (ccModel) => ccModel.hivePods);
  }

  onSelect(String id, String type) {
    if (type == 'connection') {
      setState(() {
        selectedConnection = id;
        selectedPod = null;
        displayMap = true;
        addOptionSelected = 'view $type';
      });
    } else if (type == 'pod') {
      var pod = Provider.of<ConnectionsContactsModel>(context, listen: false)
          .getPod(id);
      List connections = pod.connections?.toList();
      List contacts = pod.contacts?.toList();

      Map<String, ContactModel> searchedConts = {};
      Map<String, ConnectionModel> searchedConns = {};

      if (connections.isNotEmpty) {
        for (ConnectionModel conn in connections) {
          searchedConns[conn.id] = conn;
        }
      }
      if (contacts.isNotEmpty) {
        for (ContactModel conn in contacts) {
          searchedConts[conn.id] = conn;
        }
      }

      setState(() {
        selectedPod = id;
        selectedConnection = null;
        displayMap = true;
        searchedConnections = searchedConns;
        searchedContacts = searchedConts;
        addOptionSelected = 'view $type';
      });
    }

    hideAddButton();
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getLocationPermission();
    if (permissionStatus == PermissionStatus.granted) {
      updateUserLocation();
      refreshContacts();
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
    // _pc.open();

    int newIndex = 0;
    if (option == newReminderText) {
      newIndex = 3;
    } else if (option == newPodText) {
      newIndex = 2;
    }
    setState(() {
      addOptionSelected = option;
      _isAddButtonVisible = false;
      indexStackindex = newIndex;
    });
  }

  void _closePanel() {
    // _pc.close();
    clearAllSelections();

    setState(() {
      _isAddButtonVisible = true;
      _IsAddSearching = false;
      indexStackindex = 0;
      _selectedIndex = 0;
      searchedContacts = {};
      searchedConnections = {};
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      indexStackindex = index;
      _isAddButtonVisible = true;
      _IsAddSearching = false;
    });
  }

  void _onDisplayMapPage() {
    setState(() {
      displayMap = !displayMap;
      _isAddButtonVisible = !_isAddButtonVisible;
      selectedConnection = null;
      selectedPod = null;
    });
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var rawContacts = (await ContactsService.getContacts());
    print('is this the contacts issue?');
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

  List seperatePhoneAndDialCode(String rawNumber) {
    Map<String, String> foundedCountry = {};
    for (var country in Countries.allCountries) {
      String dialCode = country["dial_code"].toString();
      if (rawNumber.contains(dialCode)) {
        foundedCountry = country;
      }
    }

    if (foundedCountry.isNotEmpty) {
      var dialCode = rawNumber.substring(
        0,
        foundedCountry["dial_code"]!.length,
      );
      var newPhoneNumber = rawNumber.substring(
        foundedCountry["dial_code"]!.length,
      );

      List sepPhoneDial = [dialCode, newPhoneNumber];
      return (sepPhoneDial);
    }
    return ([]);
  }

  Future<ContactsMap> _updateConnectedContacts(List<Contact> contacts) async {
    List<ConnectedContact> connected = [];
    List<UnconnectedContact> unconnected = [];

    // Check for if connected goes here

    // var address = await _getAddress(latlong.latitude, latlong.longitude);

    // var addressParts = address.toString().split(";");

    for (var currContacts in contacts) {
      if ((currContacts.displayName != null) &&
          (currContacts.phones!.isNotEmpty)) {
        String name = currContacts.displayName!;

        String rawPhone = currContacts.phones![0].value!;
        String defaultDialCode = '+1';
        if (rawPhone.contains('+')) {
          List separatedPhone = seperatePhoneAndDialCode(rawPhone);
          defaultDialCode = separatedPhone[0];

          rawPhone = separatedPhone[1];
        }

        String cleanedPhone =
            defaultDialCode + rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

        var unconCon = UnconnectedContact(
          name: currContacts.displayName!,
          initials: currContacts.initials(),
          avatar: currContacts.avatar,
          phone: cleanedPhone,
        );

        unconnected.add(unconCon);
      }
    }

    var allContacts =
        ContactsMap(connected: connected, unconnected: unconnected);
    print('the raew contacts length is: ${allContacts.unconnected?.length}');
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
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .blockedContacts;
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .blockedConnections;
    Provider.of<ConnectionsContactsModel>(context, listen: false).pods;
  }

  void pullUserInfo() async {
    allValues = await storage.readAllSecureData();
    prefs = await SharedPreferences.getInstance();

    getHeader();
  }

  Future<bool> updateLoginState(bool login) async {
    prefs = await SharedPreferences.getInstance();

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
    return _isAddButtonVisible;
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

  clearText() {
    searchTextController.clear();
    setState(() {
      searchText = '';
    });
  }

  getHeader() {
    bool uncharted = prefs.getBool(isUnchartedModeKey) != null
        ? prefs.getBool(isUnchartedModeKey)!
        : false;
    setState(() {
      // firstName = prefs.get(firstNameKey).toString();

      // lastName = prefs.get(lastNameKey).toString();
      userPhone = allValues[userPhoneNumberKeyName]!;
      unchartedMode = uncharted;
    });
  }

  Widget displaySearchResults() {
    if (_IsAddSearching) {
      return Align(alignment: Alignment.topCenter, child: searchList());
    } else {
      return const SizedBox.shrink();
    }
  }

  void addToPod(dynamic contact) {
    if (contact is ConnectionModel) {
      ConnectionModel conn = contact;

      setState(() {
        searchedConnections[conn.id] = conn;
      });
    } else {
      ContactModel conn = contact;
      setState(() {
        searchedContacts[conn.id] = conn;
      });
    }
  }

  addToCheckIn(dynamic contact) {
    setState(() {
      checkInPerson = contact;
    });
  }

  void clearAllSelections() {
    searchedConnections.clear();
    searchedContacts.clear();
  }

  void removeSelection(String id) {
    setState(() {
      searchedContacts.remove(id);
      searchedConnections.remove(id);
      checkInPerson = {};
    });
  }

  void updateSelections() {}

  ListView searchList() {
    List<dynamic> results = _buildSearchList();

    return ListView.builder(
      itemCount: _buildSearchList().isEmpty ? 0 : results.length,
      itemBuilder: (context, int index) {
        var c = results.elementAt(index);
        bool isConnect = c is ConnectionModel;

        return Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                border:
                    Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
            child: ListTile(
              onTap: () {
                if (indexStackindex == 3) {
                  addToCheckIn(c);
                } else {
                  addToPod(c);
                }
              },
              leading: CircleAvatar(
                  backgroundColor: isConnect ? primaryColor : Colors.grey[100],
                  child: Text(
                    c.initials,
                    style: TextStyle(color: backgroundColor),
                  )),
              title: Text(c.name, style: TextStyle(color: Colors.white)),
            ));
      },
    );
  }

  List _buildSearchList() {
    List<ConnectionModel> searchedConnectionsList = [];
    List<ContactModel> searchedContactsList = [];

    bool creatingCheckins = (indexStackindex == 3);
    bool checkInPersonSelected =
        (checkInPerson is ConnectionModel) || (checkInPerson is ContactModel);

    if (searchText != '') {
      for (ConnectionModel connection in hiveConnections!) {
        String data = connection.name;

        if (creatingCheckins) {
          if ((data.toLowerCase().contains(searchText.toLowerCase())) &&
              ((!checkInPersonSelected) ||
                  (checkInPerson.id == connection.id))) {
            searchedConnectionsList.add(connection);
          }
        } else {
          if ((data.toLowerCase().contains(searchText.toLowerCase())) &&
              !(searchedConnections.containsKey(connection.id))) {
            searchedConnectionsList.add(connection);
          }
        }
      }
      for (ContactModel contact in hiveContacts!) {
        String data = contact.name;
        if (creatingCheckins) {
          if ((data.toLowerCase().contains(searchText.toLowerCase())) &&
              (!(checkInPersonSelected) || (checkInPerson.id != contact.id))) {
            searchedContactsList.add(contact);
          }
        } else {
          if ((data.toLowerCase().contains(searchText.toLowerCase())) &&
              !(searchedContacts.containsKey(contact.id))) {
            searchedContactsList.add(contact);
          }
        }
      }

      List<dynamic> searchResults = [
        ...searchedConnectionsList,
        ...searchedContactsList
      ];
      return searchResults;
    } else {
      return [];
    }
  }

  String cleanNumber() {
    if (userPhone != '') {
      String cleanedNumber = userPhone
          .substring(2, userPhone.length)
          .replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'),
              (Match m) => "(${m[1]}) ${m[2]}-${m[3]}");
      ;
      return (userPhone.substring(0, 2) + ' ' + cleanedNumber);
    }
    return userPhone;
  }

  deleteAccount() async {
    await userManagement.deleteUser();
    await prefs.clear();
    await storage.deleteAll();

    await podsBox?.clear();
    await connectionsBox?.clear();
    await contactsBox?.clear();

    await SystemNavigator.pop();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()));
  }

  viewBlockedList() {
    setState(() {
      indexStackindex = 3;
      _isAddButtonVisible = false;
    });
  }

  blockContact(ContactModel c) {
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .blockContact(c.id);
    List<dynamic> hiveContacts =
        context.select<ConnectionsContactsModel, List<dynamic>>(
            (ccModel) => ccModel.hiveContacts);

    Navigator.of(context).pop();
  }

  unblockContact(String id, bool isConnect) {
    if (isConnect) {
      Provider.of<ConnectionsContactsModel>(context, listen: false)
          .unblockConnection(id);
    } else {
      Provider.of<ConnectionsContactsModel>(context, listen: false)
          .unblockContact(id);
    }

    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .blockedContacts;
    Provider.of<ConnectionsContactsModel>(context, listen: false)
        .blockedConnections;
    Provider.of<ConnectionsContactsModel>(context, listen: false).contacts;
    Provider.of<ConnectionsContactsModel>(context, listen: false).connections;
  }

  blockConnection(String id) {}

  inviteContact(String phone) async {
    String content =
        'Connect with me on Dipity! Check out the site here: https://www.dipity.org/';
    final separator = Platform.isIOS ? '&' : '?';
    Uri sms =
        Uri.parse('sms:$phone${separator}body=${Uri.encodeFull(content)}');

    if (await launchUrl(sms)) {
      //app opened
    } else {
      final snackBar = SnackBar(content: Text('Could not open messages app.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //app is not opened
    }
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: whiteBackground,
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                color: backgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cleanNumber(),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    userLocation,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w200),
                  ),
                ],
              ),
            ),
            // ListTile(
            //   title: const Text('Profile'),
            //   onTap: () {
            //     // Update the state of the app.
            //     // ...
            //   },
            // ),
            ListTile(
              title:
                  const Text('Uncharted Mode', style: TextStyle(fontSize: 20)),
              subtitle: const Text('Stop all location updates'),
              trailing: Switch(
                // This bool value toggles the switch.
                value: unchartedMode,
                activeColor: primaryColor,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  prefs.setBool(isUnchartedModeKey, value);
                  userManagement.updateUnchartedMode(value);

                  setState(() {
                    unchartedMode = value;
                  });
                },
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Block List', style: TextStyle(fontSize: 20)),
              subtitle: const Text('View blocked connections and contacts'),
              trailing: Icon(Icons.arrow_right),
              onTap: () {
                viewBlockedList();

                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            ListTile(
              title: const Text('Logout', style: TextStyle(fontSize: 20)),
              onTap: () {
                updateLoginState(false).then((value) =>
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Login())));
                // Update the state of the app.
                // ...
              },
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              title: const Text('Delete Account',
                  style: TextStyle(fontSize: 15, color: Colors.red)),
              onTap: () {
                String title = 'Delete Account?';
                String content =
                    "If you need a break, Uncharted Mode stops sending and receiving location updates to connections. If not, just re-register if you decide to come back!";
                showDialog(
                  context: context,
                  builder: (BuildContext diaContext) {
                    return showAlertDialog(
                        context, title, content, deleteAccount);
                  },
                );
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
              // NotificationManager.createNewNotification(
              //     'testing the notifications');

              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Column(children: <Widget>[
            TextField(
              style: TextStyle(color: Colors.white),
              controller: searchTextController,
              keyboardType: TextInputType.name,
              keyboardAppearance: Brightness.dark,
              cursorColor: primaryColor,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: primaryColor),
                    onPressed: () {
                      /* Clear the search field */
                      clearText();
                    },
                  ),
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none),
              onTap: () {
                if ((indexStackindex == 2) && !(_IsAddSearching)) {
                  _IsAddSearching = true;
                } else if ((indexStackindex == 3) && !(_IsAddSearching)) {
                  _IsAddSearching = true;
                } else if ((displayMap)) {
                  _IsAddSearching = true;
                }
              },
              onEditingComplete: () {
                if (_IsAddSearching) {
                  _IsAddSearching = false;
                  searchText = '';
                }
                FocusManager.instance.primaryFocus?.unfocus();
                searchTextController.clear();
              },
              onChanged: (value) {
                if (searchText != value) {
                  setState(() {
                    searchText = value;
                  });
                }
              },
            ),
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
            addButtonOptions: addOptions,
            onAddPressed: _onPanelOpened,
          )),
      body: displayMap
          ? Stack(children: [
              MapView(
                  userPosition: userPosition,
                  userLocation: userLocation,
                  selectedConnection: selectedConnection,
                  selectedPod: selectedPod,
                  removeSelection: removeSelection,
                  updateSelections: updateSelections,
                  selectedConnections: searchedConnections,
                  selectedContacts: searchedContacts),
              displaySearchResults()
            ])
          : Stack(
              children: [
                IndexedStack(
                  index: indexStackindex,
                  children: [
                    ConnectionsView(
                        blockContact: blockContact,
                        blockConnection: blockConnection,
                        inviteContact: inviteContact,
                        searchText: searchText,
                        onSelect: onSelect),
                    // EventsView(currentIndex: _selectedIndex),
                    RemindersView(currentIndex: indexStackindex),
                    CreatePodForm(
                        option: addOptionSelected,
                        closePanel: _closePanel,
                        removeSelection: removeSelection,
                        searchResults: displaySearchResults(),
                        selectedConnections: searchedConnections,
                        selectedContacts: searchedContacts),
                    CreateReminderForm(
                        option: addOptionSelected,
                        closePanel: _closePanel,
                        removeSelection: removeSelection,
                        checkInPerson: checkInPerson),
                    BlockedContactsView(
                        option: addOptionSelected,
                        closePanel: _closePanel,
                        removeSelection: unblockContact,
                        searchResults: displaySearchResults(),
                        selectedConnections: searchedConnections,
                        selectedContacts: searchedContacts)
                  ],
                ),
                displaySearchResults(),
              ],
            ),
      bottomNavigationBar: displayMap
          ? Container(height: 0)
          // : Container(
          //     height: 0,
          //   ),
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  backgroundColor: backgroundColor,
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
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
