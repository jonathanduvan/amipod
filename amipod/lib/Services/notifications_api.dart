//import timezone plugin
import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/Services/encryption.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:dipity/Services/secure_storage.dart';
import 'package:dipity/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

import 'database_api.dart';

class NotificationApi {
  static final _notification = FlutterLocalNotificationsPlugin();
  DatabaseAPI dbApi = DatabaseAPI();
  SecureStorage storage = SecureStorage();
  EncryptionManager encrypter = EncryptionManager();
  HiveAPI hiveApi = HiveAPI();

  late Map<String, String> allValues;

  late Box contactsBox;
  late Box connectionsBox;
  late Box podsBox;

  static void init() {
    _notification.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  FlutterLocalNotificationsPlugin getFlip() {
    return _notification;
  }

  void notificationChecker(
      Set<List<QueryDocumentSnapshot<Object?>>> newConns) async {
    List<QueryDocumentSnapshot<Object?>> conns = newConns.first;

    if (conns.isNotEmpty) {
      NotificationCollection connected = await createConnectedContacts(conns);

      if (connected.secretConnections.isNotEmpty) {
        for (Map<String, dynamic> conn in connected.secretConnections.values) {
          scheduleNotification(conn['title'], conn['body'], 15);
        }
        // notifyListeners();
      }

      if (connected.potentialConnections.isNotEmpty) {
        for (Map<String, dynamic> conn
            in connected.potentialConnections.values) {
          scheduleNotification(conn['title'], conn['body'], 15);
        }
      } else {
        // notifyListeners();
      }
    } else {
      // notifyListeners();
    }
  }

  void gatherConnectionData() async {
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
            .then((value) => notificationChecker(value));
      }
    }
  }

  Future setContactsBox() async {
    String encryptContactsKey = allValues[unconnectedContactsStorageKeyName]!;
    var contactsKey = base64Decode(encryptContactsKey);
    contactsBox = await hiveApi.getContactsBox(contactsKey);
  }

  Future setConnectionsBox() async {
    String encryptConnectionsKey = allValues[connectionsStorageKeyName]!;
    var connectionsKey = base64Decode(encryptConnectionsKey);
    connectionsBox = await hiveApi.getConnectionsBox(connectionsKey);
  }

  Future setPodsBox() async {
    String encryptPodsKey = allValues[podsStorageKeyName]!;
    var podsKey = base64Decode(encryptPodsKey);
    podsBox = await hiveApi.getPodsBox(podsKey);
  }

  Future<bool> checkAllBoxes() async {
    allValues = await storage.readAllSecureData();

    if ((allValues[connectionsStorageKeyName] != null) &
        (allValues[unconnectedContactsStorageKeyName] != null) &
        (allValues[podsStorageKeyName] != null)) {
      List<Future> future = [
        setPodsBox(),
        setConnectionsBox(),
        setContactsBox()
      ];

      await Future.wait(future);
      return true;
    }
    return false;
  }

  testNotification() async {
    bool checker = await checkAllBoxes();

    if (checker) {
      gatherConnectionData();
    } else {
      print('damn we failed the checker');
    }
  }

  Future<NotificationCollection> createConnectedContacts(
      List<QueryDocumentSnapshot<Object?>> conns) async {
    List<ConnectedContact> connected = [];

    var userId = await storage.readSecureData(idKeyName);

    final notifications = NotificationCollection();

    for (var conn in conns) {
      Map<String, dynamic> encryptedData = conn.data() as Map<String, dynamic>;
      if (encryptedData.isNotEmpty) {
        String encryptedName = dbApi.appId(conn.id);
        String phone = encrypter.decryptData(encryptedName);

        print(allValues[userPhoneNumberKeyName]);
        print(phone);
        print(phone.trim() !=
            allValues[userPhoneNumberKeyName].toString().trim());

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

          // check if user is in the contact's contact list
          Set<Map<String, dynamic>?> conDoc =
              await dbApi.checkContact(userId, conn.id);

          Map<String, dynamic>? conInfo = conDoc.first;

          print('this is what we got: $conInfo');

          bool secretContact = (conInfo != null);

          if (secretContact) {
            print('I caught you AAHHHHHHHHH');
            print(allValues[userPhoneNumberKeyName]);
            print(phone);

            notifications.secretConnections[phone] = {
              "title": 'Recognize this number:, $phone',
              "body":
                  'Looks like they want to be friends! Add them to your phone contact app.'
            };
          }

          // if this user is a contact or already connected
          if (isContact || alreadyConnected) {
            // check if contact is in the user's contact list in db
            Set<Map<String, dynamic>?> userDoc =
                await dbApi.checkContact(conn.id, userId);

            Map<String, dynamic>? userInfo = userDoc.first;

            // the user exists in the  contacts list, but they havent connected yet

            bool potentialContact =
                ((conInfo != null) && (conInfo['blocked'] != true));

            Map<String, String> userNotif = {
              'name': contact!.name,
            };

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

            if (potentialContact) {
              notifications.potentialConnections[phone] = {
                'title': "${contact.name} has joined Dipity",
                'body': " You'll get connected next time you both log in!"
              };
            }
            if (connect) {
              try {
                String name = contact.name;
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
                  // dbApi.updateContact(userId, conn.id, contactVal);
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
    return notifications;
  }

  scheduleNotification(String title, String body, int duration) async {
    print('OH HELLO ARE YOU SCHEDFULING A NOTIIF TODAY?2');
    timezone.initializeTimeZones();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      importance: Importance.max, // set the importance of the notification
      priority: Priority.high, // set prority
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _notification.zonedSchedule(
      1,
      title,
      body,
      timezone.TZDateTime.now(timezone.local).add(Duration(seconds: duration)),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

class NotificationCollection {
  Map<String, dynamic> potentialConnections = {};
  Map<String, dynamic> secretConnections = {};
}
