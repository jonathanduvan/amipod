import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final List<LatLng> locations;
  const MapView({Key? key, required this.locations}) : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  PermissionStatus contactsStatus = PermissionStatus.denied;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 0.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 0.0,
      target: LatLng(37.42405349950475, -122.08643931895493),
      zoom: 9.0);
  @override
  void initState() {
    super.initState();
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void _createMarkers(List<LatLng> locations) {
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

    print('markers length');
    print(_markers.length);
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _createMarkers(widget.locations);
          _controller.complete(controller);
        },
        onCameraMove: (position) {},
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }
}
