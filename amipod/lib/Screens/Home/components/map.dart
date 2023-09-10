import 'dart:async';
import 'dart:math';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/Screens/Home/components/viewPanels/view_self.dart';
import 'package:flutter/services.dart';

import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'viewPanels/view_pod.dart';
import 'viewPanels/view_connection.dart';

// import 'package:geocode/geocode.dart';

class MapView extends StatefulWidget {
  final List<double> userPosition;
  final String userLocation;
  final String? selectedConnection;
  final String? selectedPod;
  final Function removeSelection;
  final Function updateSelections;
  final Map<String, ContactModel> selectedContacts;
  final Map<String, ConnectionModel> selectedConnections;
  const MapView(
      {Key? key,
      required this.userPosition,
      required this.userLocation,
      this.selectedConnection,
      this.selectedPod,
      required this.removeSelection,
      required this.updateSelections,
      required this.selectedContacts,
      required this.selectedConnections})
      : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  PermissionStatus contactsStatus = PermissionStatus.denied;
  Set<Marker> _markers = {};
  ConnectionModel? selectedConnection;
  PodModel? selectedPod;
  Iterable<dynamic>? hiveConnections;
  CameraPosition? startingCenter;
  CameraPosition? _cameraPosition;
  double panelMaxHeight = 400.0;
  double _panelHeightClosed = 0.0;

  PanelState panelOpen = PanelState.CLOSED;

  // Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _controller;
  final PanelController _pc = PanelController();
  PanelState panelStartState = PanelState.OPEN;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    hiveConnections = context.read<ConnectionsContactsModel>().hiveConnections;

    startingCenter = CameraPosition(
      target: LatLng(widget.userPosition[0] - .7, widget.userPosition[1]),
      zoom: 7.0,
    );

    if (widget.selectedConnection is String) {
      selectedConnection =
          Provider.of<ConnectionsContactsModel>(context, listen: false)
              .getConnection(widget.selectedConnection!);
      LatLng connectionPos = getLocation(
          double.tryParse(selectedConnection!.long!)!,
          double.tryParse(selectedConnection!.lat!)!,
          4500);
      startingCenter = CameraPosition(
          target: LatLng(connectionPos.latitude - .7, connectionPos.longitude),
          zoom: 7.0);
    } else if (widget.selectedPod is String) {
      selectedPod =
          Provider.of<ConnectionsContactsModel>(context, listen: false)
              .getPod(widget.selectedPod!);
    }

    // Additional code
  }

  void _onTappedMarker(ConnectionModel connection) {
    // _pc.open();
    setState(() {
      selectedConnection = connection;
      // _panelHeightClosed = 100.0;
    });
  }

  void _onTouchedSelf() {
    setState(() {
      selectedConnection = null;
      selectedPod = null;
    });
  }

  void onBlockedConnection() {
    _onTouchedSelf();
  }

  LatLng getLocation(double x0, double y0, int radius) {
    Random random = new Random();

    // Convert radius from meters to degrees
    double radiusInDegrees = radius / 111000;

    double u = random.nextDouble();
    double v = random.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double x = w * cos(t);
    double y = w * sin(t);

    // Adjust the x-coordinate for the shrinking of the east-west distances
    double new_x = x / cos(radians(y0));

    double foundLongitude = new_x + x0;
    double foundLatitude = y + y0;

    return LatLng(foundLatitude, foundLongitude);
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _createConnectionMarkers(Iterable<dynamic> connections) async {
    Set<Marker> newMarkers = {};
    LatLng userPos = LatLng(widget.userPosition[0], widget.userPosition[1]);

    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;

    // Determine if we should use mobile layout or not, 600 here is
    // a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    int shipWidth = 100;
    if (useMobileLayout) {
      shipWidth = 70;
    }

    final Uint8List userShip =
        await getImages('assets/icons/ship-2.png', shipWidth);
    final Uint8List connectionShip =
        await getImages('assets/icons/ship-1.png', shipWidth);

    newMarkers.add(Marker(
      markerId: MarkerId('primary-user'),
      position: userPos,
      icon: BitmapDescriptor.fromBytes(userShip),
      onTap: () {
        _onTouchedSelf();
      },
    ));
    for (ConnectionModel connection in connections) {
      List<Location> locations = await locationFromAddress(connection.city!);
      Location maskedLoc = locations[0];
      // LatLng connectionPos = LatLng(double.tryParse(connection.lat!)!,
      //     double.tryParse(connection.long!)!);
      // LatLng connectionPos = LatLng(maskedLoc.latitude, maskedLoc.longitude);
      LatLng connectionPos = getLocation(double.tryParse(connection.long!)!,
          double.tryParse(connection.lat!)!, 4500);
      newMarkers.add(Marker(
          markerId: MarkerId('connection-${connection.id}'),
          position: connectionPos,
          icon: BitmapDescriptor.fromBytes(connectionShip),
          onTap: () {
            _onTappedMarker(connection);
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

  void closePanel() {
    _pc.close();
  }

  void editMode(bool toggled) {
    if (toggled) {
      _pc.animatePanelToPosition(1.0);
    } else {
      _pc.close();
    }
  }

  onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    _createConnectionMarkers(hiveConnections!);
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    _controller.setMapStyle(value);
  }

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Scaffold(
      body: SlidingUpPanel(
          controller: _pc,
          panelBuilder: (ScrollController sc) => _panel(sc),
          // defaultPanelState: panelStartState,
          borderRadius: radius,
          // minHeight: _panelHeightClosed,
          maxHeight: size.height,
          body: GoogleMap(
            initialCameraPosition: startingCenter!,
            onMapCreated: (GoogleMapController controller) {
              onMapCreated(controller);
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
              height: 6.0,
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
              height: 10.0,
            ),
            selectedConnection is ConnectionModel
                ? ViewConnectionFormPanel(
                    id: selectedConnection!.id,
                    onBlockConnection: onBlockedConnection)
                : Container(),
            (selectedPod is PodModel)
                ? ViewPodFormPanel(
                    id: selectedPod!.id,
                    closePanel: closePanel,
                    editModeToggled: editMode,
                    removeSelection: widget.removeSelection,
                    updateSelections: widget.updateSelections,
                    selectedContacts: widget.selectedContacts,
                    selectedConnections: widget.selectedConnections,
                    onPodDeleted: _onTouchedSelf)
                : Container(),
            (!(selectedConnection is ConnectionModel) &&
                    !(selectedPod is PodModel))
                ? ViewSelfPanel(userLocation: widget.userLocation)
                : Container()
          ],
        ));
  }
}
