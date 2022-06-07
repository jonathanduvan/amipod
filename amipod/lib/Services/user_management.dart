import 'dart:convert';

import 'package:amipod/constants.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';

import 'hive_api.dart';
import 'secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'encryption.dart';

class UserManagement {
  List<LatLng> testUSLocations = [
    LatLng(30.386308848515, -82.674663546642),
    LatLng(30.2304846, -82.0428185),
    LatLng(38.922063, -76.9965217),
    LatLng(43.4265187, -72.3217558)
  ];
  SecureStorage storage = SecureStorage();
  EncryptionManager encrypter = EncryptionManager();

  HiveAPI hiveApi = HiveAPI();

  Future<List<Box>> checkUserStatus() async {
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

    // if (hiveApi.areBoxesOpen([contactsBox, connectionsBox, podsBox])) {
    //   return true;
    // }

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
      var contactsKey = base64Decode(encryptContactsKey);
      tempContactsBox = await hiveApi.openContactsBox(contactsKey);
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
      var connectionsKey = base64Decode(encryptConnectionsKey);
      tempConnectionsBox = await hiveApi.openConnectionsBox(connectionsKey);
    }

    // Check status of Pods Hive Box
    if (allValues[podsStorageKeyName] == null) {
      var podsKey = Hive.generateSecureKey();
      encryptPodsKey = base64UrlEncode(podsKey);

      await storage.writeSecureData(podsStorageKeyName, encryptPodsKey);

      tempPodsBox = await hiveApi.createPodsBox(podsKey);
    } else {
      encryptPodsKey = allValues[podsStorageKeyName]!;
      var podsKey = base64Decode(encryptPodsKey);
      tempPodsBox = await hiveApi.openPodsBox(podsKey);
    }

    tempConnectionsBox;
    tempContactsBox;
    tempPodsBox;

    List<Box> boxes = [tempContactsBox, tempConnectionsBox, tempPodsBox];
    return boxes;
  }
  // remindersBox = tempRemindersBox;

  // refreshContacts();
  // _getAllPods();

}

//   Future<void> refreshContacts() async {
//     // Load without thumbnails initially.
//     await Future.delayed(Duration(seconds: 6));
//     var rawContacts = (await ContactsService.getContacts());
// //      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
// //          ;

//     if (rawContacts != null) {
//       getAllContacts(rawContacts);
//     }
//   }

//   Future<String> getAddress(double? lat, double? lang) async {
//     if (lat == null || lang == null) return "";
//     // GeoCode geoCode = GeoCode();
//     // Address address =
//     //     await geoCode.reverseGeocoding(latitude: lat, longitude: lang);

//     // return "${address.streetAddress}; ${address.city}; ${address.countryName}; ${address.postal}";
//     return "test st; Testville; US; 33071";
//   }

//   Future<ContactsMap> updateConnectedContacts(List<Contact> contacts) async {
//     List<ConnectedContact> connected = [];
//     List<UnconnectedContact> unconnected = [];

//     // Check for if connected goes here

//     // Dummy code for creating connectedContact list
//     int howMany = 0;

//     for (var i = 0; i < howMany; i++) {
//       var latlong = testUSLocations[i];

//       var address = await getAddress(latlong.latitude, latlong.longitude);

//       var addressParts = address.toString().split(";");

//       var conCon = ConnectedContact(
//           name: contacts[i].displayName!,
//           initials: contacts[i].initials(),
//           avatar: contacts[i].avatar,
//           phone: contacts[i].phones![0].value!,
//           location: testUSLocations[i],
//           street: addressParts[0],
//           city: addressParts[1]);

//       contacts.removeAt(i);
//       connected.add(conCon);
//     }
//     for (var i = 0; i < contacts.length; i++) {
//       var unconCon = UnconnectedContact(
//         name: contacts[i].displayName!,
//         initials: contacts[i].initials(),
//         avatar: contacts[i].avatar,
//         phone: contacts[i].phones![0].value!,
//       );

//       unconnected.add(unconCon);
//     }

//     var allContacts =
//         ContactsMap(connected: connected, unconnected: unconnected);
//     return allContacts;

//     // connected = contacts.
//   }

//   void getAllContacts(List<Contact> contacts) async {
//     // Lazy load thumbnails after rendering initial contacts.
//     //TODO: Function to check if contact is connected or not goes here
//     var mapContacts = await _updateConnectedContacts(contacts);

//     if (hiveApi.areBoxesOpen([contactsBox, connectionsBox, podsBox])) {
//       var hiveCons = hiveApi.getAllContacts(contactsBox);
//       var hiveConnects = hiveApi.getAllConnections(connectionsBox);
//       hiveContacts = hiveCons;

//       connectedContacts = mapContacts.connected!;
//       unconnectedContacts = mapContacts.unconnected!;
//       hiveContacts = hiveCons;
//       hiveConnections = hiveConnects;

//       updateContacts();
//     }
//   }

//   void updateContacts(
//       Box contactsBox, Box connectionsBox, List<UnconnectedContact> contacts) {
//     if (contactsBox.isEmpty) {
//       print("i'm empty like my soul");
//       addAllContacts();
//     } else {
//       hiveApi.addMissingContacts(
//           encrypter, contactsBox, connectionsBox, contacts);
//     }
//   }

//   void addAllContacts(Box contactsBox, List<UnconnectedContact> contacts) {
//     for (var element in contacts) {
//       hiveApi.createAndAddContact(encrypter, contactsBox, element);
//     }
//   }

//   void _getAllPods(Box podsBox) {
//     var podsCreated = hiveApi.getAllPods(podsBox);

//     if ((podsCreated.isEmpty) == false) {
//       setState(() {
//         hivePods = podsCreated;
//       });
//     }
//   }
