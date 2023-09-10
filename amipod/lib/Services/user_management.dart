import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'hive_api.dart';
import 'secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dipity/Services/database_api.dart';
import 'encryption.dart';

class UserManagement {
  SecureStorage storage = SecureStorage();
  EncryptionManager encrypter = EncryptionManager();

  HiveAPI hiveApi = HiveAPI();
  DatabaseAPI dbApi = DatabaseAPI();

  checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> allValues = await storage.readAllSecureData();
    var userPhone = allValues[userPhoneNumberKeyName];

    var userId;

    // if (hiveApi.areBoxesOpen([contactsBox, connectionsBox, podsBox])) {
    //   return true;
    // }

    // Check status of user Id
    if (allValues[idKeyName] == null) {
      var userRawId = '$userPhone';
      userId = encrypter.encryptData(userRawId);
      await storage.writeSecureData(idKeyName, userId);
    } else {
      userId = allValues[idKeyName];
    }
  }

  Future<String> _getAddressFromLatLng(Position _currentPosition) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      return "${place.locality}, ${place.postalCode}";
    } catch (e) {
      return 'no location available';
    }
  }

  Future<LatLng> maskUserLocation(String readableLocation) async {
    List<Location> locations = await locationFromAddress(readableLocation);
    print('okay the reverse search hits');
    Location maskedLoc = locations[0];
    LatLng connectionPos = LatLng(maskedLoc.latitude, maskedLoc.longitude);
    return connectionPos;
  }

  Future<Map> updateUserLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    bool uncharted = (prefs.getBool(isUnchartedModeKey)) ?? false;

    var currKey = await storage.readSecureData(idKeyName);
    String readableLocation = await _getAddressFromLatLng(position);
    print(readableLocation);
    String encryptedLat = encrypter.encryptData('lat:${position.latitude}');
    String encryptedLong = encrypter.encryptData('long:${position.longitude}');
    String encryptedReadableLocation = encrypter.encryptData(readableLocation);

    LatLng maskedLoc = await maskUserLocation(readableLocation);

    final encryptedLocation = {
      "position": [encryptedLat, encryptedLong],
      "location": encryptedReadableLocation,
    };
    final location = {
      "position": [maskedLoc.latitude, maskedLoc.longitude],
      "location": readableLocation
    };

    encryptedLocation['uncharted'] = uncharted;

    dbApi.setUser(currKey, encryptedLocation);
    return location;
  }

  updateUnchartedMode(bool mode) async {
    var currKey = await storage.readSecureData(idKeyName);
    Map<String, dynamic> update = {'uncharted': mode};

    dbApi.setUnchartedMode(currKey, update);
  }

  deleteUser() async {
    var currKey = await storage.readSecureData(idKeyName);
    storage.readSecureData(idKeyName).then((value) => dbApi.deleteUser(value));
  }

  verifyPhoneNumber(String phone, Function onCodeSent,
      Function onUserAuthorized, BuildContext context) {
    dbApi.verifyPhoneNumber(phone, onCodeSent, onUserAuthorized, context);
  }

  authorizeUser(String smsCode, String verificationId, int? resendToken,
      BuildContext context, Function onUserAuthorized) async {
    try {
      await dbApi.autherizeUser(
          smsCode, verificationId, resendToken, context, onUserAuthorized);
    } catch (err) {
      print('user management caught');
    }
  }
}
