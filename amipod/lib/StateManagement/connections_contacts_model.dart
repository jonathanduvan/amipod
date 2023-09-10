import 'dart:convert';

import 'package:dipity/HiveModels/connection_model.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionsContactsModel extends ChangeNotifier {
  List<dynamic> hiveContacts = [];
  Iterable<dynamic> hiveConnections = [];
  List<dynamic> hiveBlockedContacts = [];
  Iterable<dynamic> hiveBlockedConnections = [];

  Iterable<dynamic> hivePods = [];

  SecureStorage storage = SecureStorage();
  HiveAPI hiveApi = HiveAPI();
  DatabaseAPI dbApi = DatabaseAPI();

  EncryptionManager encrypter = EncryptionManager();

  late Map<String, String> allValues;

  late Box contactsBox;
  late Box connectionsBox;
  late Box podsBox;

  List<dynamic> get contacts {
    Iterable<dynamic> unsortedContacts = hiveApi.getAllContacts(contactsBox);
    hiveContacts = unsortedContacts
        .where((element) =>
            (element.blocked == (false) || (element.blocked == (null))))
        .toList();
    hiveContacts.sort((a, b) => a.name.compareTo(b.name));
    return [...hiveContacts];
  }

  Iterable<dynamic> get connections {
    hiveConnections = hiveApi.getAllConnections(connectionsBox).where(
        (element) =>
            (element.blocked == (false) || (element.blocked == (null))));

    return [...hiveConnections];
  }

  Iterable<dynamic> get blockedContacts {
    Iterable<dynamic> unsortedContacts = hiveApi.getAllContacts(contactsBox);
    hiveBlockedContacts =
        unsortedContacts.where((element) => element.blocked == true).toList();
    hiveBlockedContacts.sort((a, b) => a.name.compareTo(b.name));

    return [...hiveBlockedContacts];
  }

  Iterable<dynamic> get blockedConnections {
    hiveBlockedConnections = hiveApi
        .getAllConnections(connectionsBox)
        .where((element) => element.blocked == true);
    return [...hiveBlockedConnections];
  }

  Iterable<dynamic> get pods {
    hivePods = hiveApi.getAllPods(podsBox);
    return [...hivePods];
  }

  Future setAllValues() async {
    allValues = await storage.readAllSecureData();
  }

  Future setContactBox() async {
    if ((allValues[unconnectedContactsStorageKeyName] == null)) {
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
    Iterable<dynamic> unsortedContacts = hiveApi.getAllContacts(contactsBox);
    List<dynamic> hiveContacts = unsortedContacts.toList();
    hiveContacts.sort((a, b) => a.name.compareTo(b.name));
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
    notifyListeners();
  }

  addPod(Map<String, ConnectionModel> podConnections,
      Map<String, ContactModel> podContacts, String title) {
    var podCreated = hiveApi.createAndAddPod(encrypter, podsBox, contactsBox,
        connectionsBox, podConnections, podContacts, title);

    if (podCreated is PodModel) {
      hivePods = hiveApi.getAllPods(podsBox);
      notifyListeners();
    }

    return podCreated;
  }

  // Replace All Functions
  void updateContacts(List<UnconnectedContact> unconnected) {
    if (contactsBox.isEmpty) {
      print('contact box was empty!');
      addAllContacts(unconnected);
    } else {
      print('contact box was fill');
      hiveApi.addMissingContacts(
          encrypter, contactsBox, connectionsBox, unconnected);
      notifyListeners();
    }
  }

  Future<List<ConnectedContact>> createConnectedContacts(
      List<QueryDocumentSnapshot<Object?>> conns) async {
    List<ConnectedContact> connected = [];

    var userId = await storage.readSecureData(idKeyName);

    for (var conn in conns) {
      Map<String, dynamic> encryptedData = conn.data() as Map<String, dynamic>;
      if (encryptedData.isNotEmpty) {
        String encryptedName = dbApi.appId(conn.id);
        String phone = encrypter.decryptData(encryptedName);

        print(allValues[userPhoneNumberKeyName]);
        print(phone);
        print(phone.trim() !=
            allValues[userPhoneNumberKeyName].toString().trim());
        print('ok just compared');
        if (phone.contains(':')) {
          phone = '+1${phone.split(':')[1]}';
        }

        // User is not looking at themselves
        if (phone.trim() !=
            allValues[userPhoneNumberKeyName].toString().trim()) {
          String encryptPhone = encrypter.encryptData(phone);
          ContactModel? contact = contactsBox.get(encryptPhone);
          ConnectionModel? connection = connectionsBox.get(encryptPhone);

          bool alreadyConnected = (connection != null);

          bool isContact = (contact != null);

          // if this user is a contact or already connected
          if (isContact || alreadyConnected) {
            // check if contact is in the user's contact list in db
            Set<Map<String, dynamic>?> userDoc =
                await dbApi.checkContact(conn.id, userId);

            Map<String, dynamic>? userInfo = userDoc.first;

            // check if user is in the contact's contact list
            Set<Map<String, dynamic>?> conDoc =
                await dbApi.checkContact(userId, conn.id);

            Map<String, dynamic>? conInfo = conDoc.first;

            print('this is what we got: $conInfo');

            // the user exists in the  contacts list, but they havent connected yet
            bool potentialContact =
                ((conInfo != null) && (conInfo['blocked'] != true));

            // The contact is not blocked
            bool unblockedContact =
                !(alreadyConnected) && isContact && (contact.blocked != true);

            // The connection is not blocked
            bool unblockedConnection = alreadyConnected;

            // Connect these users and get location
            bool connect =
                potentialContact && (unblockedContact || unblockedConnection);

            // These users haven't connected yet
            bool noConnectionYet = ((conInfo == null) && (userInfo == null));

            bool isContactUncharted = await dbApi.isUncharted(conn.id);

            // Can't connect but can update db to let it know we checked this contact
            if (noConnectionYet) {
              try {
                Map<String, dynamic> contactVal = {
                  "blocked": contact?.blocked ?? false,
                };
                dbApi.updateContact(userId, conn.id, contactVal);
              } catch (error) {
                print(error);
                print('could not update in db');
              }

              // Update with location data
            } else if (connect) {
              print('OH SHIT WE CAN CONNECT');
              try {
                //TODO: Remove hard coded us code

                String name = contact!.name;
                String initials = contact.initials;

                String encryptedLoc = encryptedData['location'];
                List encryptedPos = encryptedData['position'];
                String last_update = encryptedData['last_update'];

                String encryptedLat = encryptedPos[0];
                String encryptedLong = encryptedPos[1];

                String location = encrypter.decryptData(encryptedLoc);
                var lat =
                    encrypter.decryptData(encryptedLat).replaceAll('lat:', '');
                var long = encrypter
                    .decryptData(encryptedLong)
                    .replaceAll('long:', '');

                LatLng latLng =
                    LatLng(double.tryParse(lat)!, double.tryParse(long)!);

                ConnectedContact connContact = ConnectedContact(
                    name: name,
                    initials: initials,
                    phone: phone,
                    city: location,
                    location: latLng,
                    street: 'not available',
                    blocked: connection?.blocked ?? (contact.blocked ?? false),
                    last_update: last_update,
                    uncharted: isContactUncharted);

                connected.add(connContact);

                try {
                  Map<String, dynamic> contactVal = {
                    "blocked": false,
                  };
                  dbApi.updateContact(userId, conn.id, contactVal);
                } catch (error) {
                  print(error);
                  print('could not update in db');
                }
              } catch (error) {
                print(error);
              }
            }
          }
        }
      }
    }
    return connected;
  }

  void updateWithNewConnections(
      Set<List<QueryDocumentSnapshot<Object?>>> newConns) async {
    List<QueryDocumentSnapshot<Object?>> conns = newConns.first;

    if (conns.isNotEmpty) {
      List<ConnectedContact> connected = await createConnectedContacts(conns);

      if (connected.isEmpty) {
        connectionsBox.clear();
        notifyListeners();
      } else {
        hiveApi.addConnections(encrypter, connectionsBox, connected);
        notifyListeners();
      }
    } else {
      connectionsBox.clear();
      notifyListeners();
    }
  }

  void updateConnections() async {
    List ids = [];

    if (contactsBox.isNotEmpty) {
      Iterable<dynamic> unsortedContacts = hiveApi.getAllContacts(contactsBox);

      for (var element in unsortedContacts.toList()) {
        ids.add('${element.phone}');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      bool uncharted = prefs.getBool(isUnchartedModeKey) != null
          ? prefs.getBool(isUnchartedModeKey)!
          : false;

      if (!uncharted) {
        dbApi
            .getConnectionsInfo(ids)
            .then((value) => updateWithNewConnections(value));
      }
    }
  }

  dynamic getPod(String id) {
    return hiveApi.getPod(podsBox, id);
  }

  ContactModel getContact(String id) {
    return hiveApi.getContact(contactsBox, id);
  }

  ConnectionModel getConnection(String id) {
    return hiveApi.getConnection(connectionsBox, id);
  }

  blockConnection(String blockId) async {
    hiveApi.block(connectionsBox, blockId);
    var userId = await storage.readSecureData(idKeyName);
    await dbApi.block(userId, blockId);
    notifyListeners();
  }

  blockContact(String id) {
    hiveApi.block(contactsBox, id);
    notifyListeners();
  }

  unblockConnection(String blockId) async {
    hiveApi.unblock(connectionsBox, blockId);
    var userId = await storage.readSecureData(idKeyName);
    await dbApi.block(userId, blockId);
    notifyListeners();
  }

  unblockContact(String id) {
    hiveApi.unblock(contactsBox, id);
    notifyListeners();
  }

  deletePod(PodModel pod) {
    hiveApi.deletePod(pod);
  }

  updatePod(String id, Map<String, ConnectionModel> connections,
      Map<String, ContactModel> contacts, String title) {
    return hiveApi.updatePod(podsBox, id, connections, contacts, title);
  }

  bool checkPodTitle(String name, String? id) {
    return hiveApi.checkPodTitle(podsBox, name, id);
  }

  /// Removes all items from the cart.
  // void removeAll() {
  //   _items.clear();
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }
}
