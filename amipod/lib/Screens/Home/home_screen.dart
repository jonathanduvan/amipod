import 'package:amipod/Screens/Home/components/connections_view.dart';
import 'package:amipod/Screens/Home/components/events_view.dart';
import 'package:amipod/Screens/Home/components/home_view.dart';
import 'package:amipod/Screens/Home/components/reminders_view.dart';
import 'package:amipod/Screens/Home/components/map.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  List<ConnectedContact>? connectedContacts = [];
  List<UnconnectedContact>? unconnectedContacts = [];
  List<Pod> allPods = [];

  List<LatLng> testUSLocations = [
    LatLng(30.386308848515, -82.674663546642),
    LatLng(30.2304846, -82.0428185),
    LatLng(38.922063, -76.9965217),
    LatLng(43.4265187, -72.3217558)
  ];

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDisplayMapPage() {
    setState(() {
      displayMap = !displayMap;
    });
  }

  ContactsMap _updateConnectedContacts(List<Contact> contacts) {
    List<ConnectedContact> connected = [];
    List<UnconnectedContact> unconnected = [];

    // Check for if connected goes here

    // Dummy code for creating connectedContact list
    int howMany = 3;

    for (var i = 0; i < howMany; i++) {
      var conCon = ConnectedContact(
          name: contacts[i].displayName,
          phone: contacts[i].phones?[0].value,
          location: testUSLocations[i]);

      contacts.removeAt(i);
      connected.add(conCon);
    }
    for (var i = 0; i < contacts.length; i++) {
      var unconCon = UnconnectedContact(
          name: contacts[i].displayName, phone: contacts[i].phones?[0].value);

      unconnected.add(unconCon);
    }

    var allContacts =
        ContactsMap(connected: connected, unconnected: unconnected);
    return allContacts;

    // connected = contacts.
  }

  void _getAllContacts(List<Contact> contacts) {
    print('papi got new contacts: ');
    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      print(contact.displayName);
      print(contact.phones?[0].value);
    }

    //TODO: Function to check if contact is connected or not goes here

    var mapContacts = _updateConnectedContacts(contacts);
    print(mapContacts);
    setState(() {
      allContacts = contacts;
      connectedContacts = mapContacts.connected;
      unconnectedContacts = mapContacts.unconnected;
    });
  }

  @override
  void initState() {
    pageList.add(HomeView(currentIndex: _selectedIndex));
    pageList.add(ConnectionsView(
        currentIndex: _selectedIndex, getAllContacts: _getAllContacts));
    pageList.add(EventsView(currentIndex: _selectedIndex));
    pageList.add(RemindersView(currentIndex: _selectedIndex));

    super.initState();
  }

  bool onConnectionsPage(int index) {
    return (connectionsIndex == index);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            /** Do something */
          },
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
              : Container()
        ],
      ),
      body: displayMap
          ? MapView(contacts: connectedContacts!)
          : IndexedStack(
              index: _selectedIndex,
              children: pageList,
            ),
      bottomNavigationBar: displayMap
          ? Container(height: 0)
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Connections',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.alarm),
                  label: 'Reminders',
                ),
              ],
              unselectedItemColor: Colors.black,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
            ),
    );
  }
}
