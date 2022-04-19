import 'dart:convert';
import 'dart:typed_data';
import 'package:amipod/HiveModels/connection_model.dart';
import 'package:amipod/HiveModels/contact_model.dart';
import 'package:amipod/HiveModels/pod_model.dart';
import 'package:amipod/Services/encryption.dart';
import 'package:hive/hive.dart';

import '../constants.dart';

class HiveAPI {
  String contactsBoxName = 'contactsBox';
  String connectionsBoxName = 'connectionsBox';
  String podsBoxName = 'podsBox';

  List<int> decodeHiveBoxKey(String key) {
    final encryptionKey = base64Url.decode(key);
    return encryptionKey;
  }

  // Functions Relating to Contacts
  Future<Box> createContactsBox(List<int> key) async {
    // Initialize TypeAdapters
    Hive.registerAdapter(ContactModelAdapter());
    final encryptedBox = await Hive.openBox<ContactModel>(contactsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Box openContactsBox() {
    return Hive.box<ContactModel>(contactsBoxName);
  }

  ContactModel createAndAddContact(EncryptionManager encrypter, Box contactsBox,
      UnconnectedContact flutterContact) {
    String id = encrypter.encryptData(flutterContact.phone);
    var contact = ContactModel(
        id: id,
        name: flutterContact.name,
        initials: flutterContact.initials,
        phone: flutterContact.phone);

    if (flutterContact.avatar != null &&
        flutterContact.avatar?.isEmpty == true) {
      contact.avatar = flutterContact.avatar;
    }
    contactsBox.put(id, contact);
    return contact;
  }

  addMissingContacts(EncryptionManager encrypter, Box contactsBox,
      Box connectionsBox, List<UnconnectedContact> unconnectedContacts) {
    unconnectedContacts.forEach((element) {
      String id = encrypter.encryptData(element.phone);

      var inContacts = contactsBox.get(id);
      var inConnections = connectionsBox.get(id);

      // If the contact is completely new
      if ((inContacts == null) & (inConnections == null)) {
        createAndAddContact(encrypter, contactsBox, element);
      }
    });
  }

  addContact(Box contactsBox, ContactModel contact) {
    contactsBox.add(contact);
  }

  addListOfContacts(Box contactsBox, List<ContactModel> contacts) {
    contactsBox.addAll(contacts);
  }

  Future<void> deleteContact(ContactModel contact) async {
    return contact.delete();
  }

  Iterable<dynamic> getAllContacts(Box contactsBox) {
    return contactsBox.values;
  }

  // Functions Relating to Connections

  Future<Box> createConnectionsBox(List<int> key) async {
    // Initialize TypeAdapters
    Hive.registerAdapter(ConnectionModelAdapter());
    final encryptedBox = await Hive.openBox<ConnectionModel>(connectionsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Box openConnectionsBox() {
    return Hive.box<ConnectionModel>(connectionsBoxName);
  }

  Iterable<dynamic> getAllConnections(Box connectionsBox) {
    return connectionsBox.values;
  }

  // TODO: add connections Functions

  // Functions Relating to Pods

  Future<Box> createPodBox(List<int> key) async {
    Hive.registerAdapter(PodModelAdapter());
    final encryptedBox = await Hive.openBox<PodModel>(podsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Box openPodsBox() {
    return Hive.box<PodModel>(podsBoxName);
  }

  PodModel createPod(Pod flutterPod) {
    String id = 'this where the the generated pod id goes';
    var pod = PodModel(name: flutterPod.name, id: id);
    return pod;
  }

  Iterable<dynamic> getAllPods(Box podsBox) {
    return podsBox.values;
  }

  addPod(Box podsBox, PodModel pod) {
    podsBox.add(pod);
  }

  Future<void> deletePod(PodModel pod) async {
    return pod.delete();
  }
}
