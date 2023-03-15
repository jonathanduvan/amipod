import 'dart:convert';

import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/Services/database_api.dart';
import 'package:dipity/Services/encryption.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:dipity/Services/secure_storage.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionsContactsModel extends ChangeNotifier {
  Iterable<dynamic> hiveContacts = [];
  Iterable<dynamic> hiveConnections = [];
  Iterable<dynamic> hivePods = [];

  SecureStorage storage = SecureStorage();
  HiveAPI hiveApi = HiveAPI();
  DatabaseAPI dbApi = DatabaseAPI();

  EncryptionManager encrypter = EncryptionManager();

  late Map<String, String> allValues;

  late Box contactsBox;
  late Box connectionsBox;
  late Box podsBox;

  Iterable<dynamic> get contacts {
    hiveContacts = hiveApi.getAllContacts(contactsBox);
    return [...hiveContacts];
  }

  Iterable<dynamic> get connections {
    hiveConnections = hiveApi.getAllConnections(connectionsBox);
    return [...hiveConnections];
  }

  Iterable<dynamic> get pods {
    hivePods = hiveApi.getAllPods(podsBox);
    return [...hivePods];
  }

  Future setAllValues() async {
    allValues = await storage.readAllSecureData();
  }

  Future setContactBox() async {
    if (allValues[unconnectedContactsStorageKeyName] == null) {
      var contactsKey = Hive.generateSecureKey();
      String encryptContactsKey = base64UrlEncode(contactsKey);

      await storage.writeSecureData(
          unconnectedContactsStorageKeyName, encryptContactsKey);

      contactsBox = await hiveApi.createContactsBox(contactsKey);
    } else {
      String encryptContactsKey = allValues[unconnectedContactsStorageKeyName]!;
      var contactsKey = base64Decode(encryptContactsKey);
      contactsBox = await hiveApi.openContactsBox(contactsKey);
    }
  }

  Future setConnectionsBox() async {
    // Check status of Connections Hive Box
    if (allValues[connectionsStorageKeyName] == null) {
      var connectionsKey = Hive.generateSecureKey();
      String encryptConnectionsKey = base64UrlEncode(connectionsKey);

      await storage.writeSecureData(
          connectionsStorageKeyName, encryptConnectionsKey);

      connectionsBox = await hiveApi.createConnectionsBox(connectionsKey);
    } else {
      String encryptConnectionsKey = allValues[connectionsStorageKeyName]!;
      var connectionsKey = base64Decode(encryptConnectionsKey);
      connectionsBox = await hiveApi.openConnectionsBox(connectionsKey);
    }
  }

  Future setPodsBox() async {
    // Check status of Pods Hive Box
    if (allValues[podsStorageKeyName] == null) {
      var podsKey = Hive.generateSecureKey();
      String encryptPodsKey = base64UrlEncode(podsKey);

      await storage.writeSecureData(podsStorageKeyName, encryptPodsKey);

      podsBox = await hiveApi.createPodsBox(podsKey);
    } else {
      String encryptPodsKey = allValues[podsStorageKeyName]!;
      var podsKey = base64Decode(encryptPodsKey);
      podsBox = await hiveApi.openPodsBox(podsKey);
    }
  }

  void setAllBoxes() async {
    await setAllValues();
    await setContactBox();
    await setConnectionsBox();
    await setPodsBox();
  }

  void getAllContacts() async {
    hiveContacts = hiveApi.getAllContacts(contactsBox);
    updateConnections();
    notifyListeners();
  }

  void getAllConnections() async {
    hiveConnections = hiveApi.getAllConnections(connectionsBox);
    notifyListeners();
  }

  void getAllPods() {
    hivePods = hiveApi.getAllPods(podsBox);
    notifyListeners();
  }

  void addAllContacts(List<UnconnectedContact> unconnected) {
    for (var element in unconnected) {
      hiveApi.createAndAddContact(encrypter, contactsBox, element);
    }
  }

  PodModel addPod(Map<String, ContactModel> podContacts, String title) {
    var podCreated = hiveApi.createAndAddPod(
        encrypter, podsBox, contactsBox, connectionsBox, podContacts, title);

    if (podCreated is PodModel) {
      hivePods = hiveApi.getAllPods(podsBox);
      notifyListeners();
    }

    return podCreated;
  }

  // Replace All Functions
  void updateContacts(List<UnconnectedContact> unconnected) {
    print('ok wwe here updating');
    if (contactsBox.isEmpty) {
      print('all is empty');
      addAllContacts(unconnected);
    } else {
      hiveApi.addMissingContacts(
          encrypter, contactsBox, connectionsBox, unconnected);
    }
  }

  List<ConnectedContact> createConnectedContacts(
      List<QueryDocumentSnapshot<Object?>> conns) {
    List<ConnectedContact> connected = [];

    for (var conn in conns) {
      Map<String, dynamic> encryptedData = conn.data() as Map<String, dynamic>;
      if (encryptedData != null) {
        String encryptedName = conn.id;

        try {
          String phone = encrypter.decryptData(encryptedName);

          //TODO: Remove hard coded us code

          if (phone != allValues[idKeyName]) {
            if (phone.contains('dipity_userid:')) {
              phone = phone.replaceAll('dipity_userid:', '');
              phone = '+1$phone';
            }
            String encryptPhone = encrypter.encryptData(phone);
            ContactModel contact = contactsBox.get(encryptPhone);

            String name = contact.name;
            print(name);
            String initials = contact.initials;

            String encryptedLoc = encryptedData['location'];
            List encryptedPos = encryptedData['position'];

            String encryptedLat = encryptedPos[0];
            String encryptedLong = encryptedPos[1];

            String location = encrypter.decryptData(encryptedLoc);
            var lat =
                encrypter.decryptData(encryptedLat).replaceAll('lat:', '');
            var long =
                encrypter.decryptData(encryptedLong).replaceAll('long:', '');
            ;

            LatLng latLng =
                LatLng(double.tryParse(lat)!, double.tryParse(long)!);

            print(phone);
            print(location);
            print(lat);
            print(long);

            ConnectedContact connection = ConnectedContact(
                name: name,
                initials: initials,
                phone: phone,
                city: location,
                location: latLng,
                street: 'not available');

            connected.add(connection);
          }
        } catch (error) {
          print(error);
        }
      }
      // ConnectedContact(city: )
    }
    return connected;
  }

  void updateWithNewConnections(
      Set<List<QueryDocumentSnapshot<Object?>>> newConns) {
    print('getting new connections');
    List<QueryDocumentSnapshot<Object?>> conns = newConns.first;

    if (conns.length > 0) {
      List<ConnectedContact> connected = createConnectedContacts(conns);
      hiveApi.addConnections(encrypter, connectionsBox, connected);
    }
  }

  void updateConnections() {
    List ids = [];

    if (hiveContacts.isNotEmpty) {
      for (var element in hiveContacts) {
        ids.add('dipity_userid:${element.phone}');
      }
      // TODO: Update code to update the hive connections with new connections, and also parse out the locations
      dbApi
          .getConnectionsInfo(ids)
          .then((value) => updateWithNewConnections(value));
    }
  }

  /// Removes all items from the cart.
  // void removeAll() {
  //   _items.clear();
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }
}
