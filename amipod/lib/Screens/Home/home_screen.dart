import 'package:amipod/Screens/Home/components/connections_view.dart';
import 'package:amipod/Screens/Home/components/events_view.dart';
import 'package:amipod/Screens/Home/components/home_view.dart';
import 'package:amipod/Screens/Home/components/reminders_view.dart';
import 'package:amipod/Screens/Home/components/map.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:amipod/Screens/Home/components/add_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  List<UnconnectedContact> unconnectedContacts = [];
  List<Pod> allPods = [];
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
  }

  void _getAllPods(Map<String, Pod> podsCreated) {
    if ((podsCreated.isEmpty & allPods.isEmpty) == false) {
      setState(() {
        allPods = allPods;
      });
    }
  }

  bool _isAddButtonVisible = true;
  @override
  void initState() {
    pageList.add(HomeView(currentIndex: _selectedIndex));
    pageList.add(ConnectionsView(
        currentIndex: _selectedIndex,
        getAllContacts: _getAllContacts,
        getAllPods: _getAllPods));
    pageList.add(EventsView(currentIndex: _selectedIndex));
    pageList.add(RemindersView(currentIndex: _selectedIndex));

    super.initState();
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

  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            /** Do something */
          },
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
