import 'dart:async';
import 'package:amipod/StateManagement/connections_contacts_model.dart';
import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geocode/geocode.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  PermissionStatus contactsStatus = PermissionStatus.denied;
  Set<Marker> _markers = {};
  ConnectedContact? selectedContact;

  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 0.0;

  PanelState panelOpen = PanelState.CLOSED;

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 7.0,
  );

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }

  void _onTappedMarker(contact) {
    if (contact.runtimeType == ConnectedContact) {
      setState(() {
        selectedContact = contact;
        _panelHeightClosed = 150.0;
      });
    }
  }

  void _createConnectionMarkers(Iterable<dynamic> contacts) {
    Set<Marker> newMarkers = {};

    for (final contact in contacts) {
      newMarkers.add(Marker(
          markerId: MarkerId('connection-$contact.id'),
          position: contact.location,
          onTap: () {
            _onTappedMarker(contact);
          }));
    }
    setState(() {
      _markers.addAll(newMarkers);
    });
  }

  void _createPodMarkers(List<LatLng> locations) {
    if (locations != null) {
      Set<Marker> newMarkers = List.generate(
              locations.length,
              (i) =>
                  Marker(markerId: MarkerId('id-${i}'), position: locations[i]))
          .toSet();

      setState(() {
        _markers.addAll(newMarkers);
      });
    }
  }

  void createMapCenter(Iterable<dynamic> connections) {}

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen

    Iterable<dynamic> hiveConnections =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.hiveConnections);

    CameraPosition startingCenter = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 7.0,
    );
    return Scaffold(
      body: SlidingUpPanel(
          panelBuilder: (ScrollController sc) => _panel(sc),
          borderRadius: radius,
          minHeight: _panelHeightClosed,
          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _createConnectionMarkers(hiveConnections);
              _controller.complete(controller);
            },
            onCameraMove: (position) {},
            markers: _markers,
          )),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          padding: const EdgeInsets.only(left: 8.0),
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            selectedContact != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              selectedContact!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              selectedContact!.city,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0,
                              ),
                            ),
                          ]),
                    ],
                  )
                : Container(),
            SizedBox(
              height: 36.0,
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Images",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("About",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    """Pittsburgh is a city in the state of Pennsylvania in the United States, and is the county seat of Allegheny County. A population of about 302,407 (2018) residents live within the city limits, making it the 66th-largest city in the U.S. The metropolitan population of 2,324,743 is the largest in both the Ohio Valley and Appalachia, the second-largest in Pennsylvania (behind Philadelphia), and the 27th-largest in the U.S.\n\nPittsburgh is located in the southwest of the state, at the confluence of the Allegheny, Monongahela, and Ohio rivers. Pittsburgh is known both as "the Steel City" for its more than 300 steel-related businesses and as the "City of Bridges" for its 446 bridges. The city features 30 skyscrapers, two inclined railways, a pre-revolutionary fortification and the Point State Park at the confluence of the rivers. The city developed as a vital link of the Atlantic coast and Midwest, as the mineral-rich Allegheny Mountains made the area coveted by the French and British empires, Virginians, Whiskey Rebels, and Civil War raiders.\n\nAside from steel, Pittsburgh has led in manufacturing of aluminum, glass, shipbuilding, petroleum, foods, sports, transportation, computing, autos, and electronics. For part of the 20th century, Pittsburgh was behind only New York City and Chicago in corporate headquarters employment; it had the most U.S. stockholders per capita. Deindustrialization in the 1970s and 80s laid off area blue-collar workers as steel and other heavy industries declined, and thousands of downtown white-collar workers also lost jobs when several Pittsburgh-based companies moved out. The population dropped from a peak of 675,000 in 1950 to 370,000 in 1990. However, this rich industrial history left the area with renowned museums, medical centers, parks, research centers, and a diverse cultural district.\n\nAfter the deindustrialization of the mid-20th century, Pittsburgh has transformed into a hub for the health care, education, and technology industries. Pittsburgh is a leader in the health care sector as the home to large medical providers such as University of Pittsburgh Medical Center (UPMC). The area is home to 68 colleges and universities, including research and development leaders Carnegie Mellon University and the University of Pittsburgh. Google, Apple Inc., Bosch, Facebook, Uber, Nokia, Autodesk, Amazon, Microsoft and IBM are among 1,600 technology firms generating \$20.7 billion in annual Pittsburgh payrolls. The area has served as the long-time federal agency headquarters for cyber defense, software engineering, robotics, energy research and the nuclear navy. The nation's eighth-largest bank, eight Fortune 500 companies, and six of the top 300 U.S. law firms make their global headquarters in the area, while RAND Corporation (RAND), BNY Mellon, Nova, FedEx, Bayer, and the National Institute for Occupational Safety and Health (NIOSH) have regional bases that helped Pittsburgh become the sixth-best area for U.S. job growth.
                  """,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ));
  }
}
