import 'dart:async';
import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocode/geocode.dart';

class MapView extends StatefulWidget {
  final List<ConnectedContact> contacts;
  const MapView({Key? key, required this.contacts}) : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  PermissionStatus contactsStatus = PermissionStatus.denied;
  Set<Marker> _markers = {};
  var selectedMarker;

  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 95.0;

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 7.0,
  );

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    GeoCode geoCode = GeoCode();
    Address address =
        await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
    return "${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}";
  }

  void _onTappedMarker(markerObject) {
    if (markerObject.runtimeType == ConnectedContact) {
      setState(() {
        selectedMarker = markerObject;
      });
    }
  }

  void _createConnectionMarkers(List<ConnectedContact> contacts) {
    if (contacts != null) {
      Set<Marker> newMarkers = List.generate(
          contacts.length,
          (i) => Marker(
                markerId: MarkerId('connection-${i}'),
                position: contacts[i].location!,
                onTap: () {
                  _onTappedMarker(contacts[i]);
                },
              )).toSet();

      setState(() {
        _markers.addAll(newMarkers);
      });
    }
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

  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen

    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _createConnectionMarkers(widget.contacts);
          _controller.complete(controller);
        },
        onCameraMove: (position) {},
        markers: _markers,
      ),
    );
  }
}


// Stack(
//         alignment: Alignment.topCenter,
//         children: <Widget>[
//           SlidingUpPanel(
//             maxHeight: _panelHeightOpen,
//             minHeight: _panelHeightClosed,
//             parallaxEnabled: true,
//             parallaxOffset: .5,
//             body: _body(),
//             panelBuilder: (sc) => _panel(sc),
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(18.0),
//                 topRight: Radius.circular(18.0)),
//             onPanelSlide: (double pos) => setState(() {
//               _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
//                   _initFabHeight;
//             }),
//           ),