import 'dart:convert';
import 'package:amipod/HiveModels/connection_model.dart';
import 'package:amipod/HiveModels/contact_model.dart';
import 'package:amipod/HiveModels/pod_model.dart';
import 'package:amipod/Services/encryption.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';

class HiveAPI {
  String contactsBoxName = 'contactsBox';
  String connectionsBoxName = 'connectionsBox';
  String podsBoxName = 'podsBox';

  bool areBoxesOpen(List<Box> boxes) {
    bool open = true;
    boxes.forEach((element) {
      if (element.isOpen == false) {
        open = false;
      }
    });
    return open;
  }

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

  Future<Box> openContactsBox(List<int> key) async {
    // return Hive.box<ContactModel>(contactsBoxName);
    final encryptedBox = await Hive.openBox<ContactModel>(contactsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
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
    if (contactsBox.isOpen) {
      return contactsBox.values;
    }
    Iterable<dynamic> noBox = [];
    return noBox;
  }

  // Functions Relating to Connections

  Future<Box> createConnectionsBox(List<int> key) async {
    // Initialize TypeAdapters
    Hive.registerAdapter(ConnectionModelAdapter());
    final encryptedBox = await Hive.openBox<ConnectionModel>(connectionsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Future<Box> openConnectionsBox(List<int> key) async {
    // Initialize TypeAdapters
    final encryptedBox = await Hive.openBox<ConnectionModel>(connectionsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Iterable<dynamic> getAllConnections(Box connectionsBox) {
    if (connectionsBox.isOpen) {
      return connectionsBox.values;
    }
    Iterable<dynamic> noBox = [];
    return noBox;
  }

  // Functions Relating to Pods

  Future<Box> createPodsBox(List<int> key) async {
    Hive.registerAdapter(PodModelAdapter());
    final encryptedBox = await Hive.openBox<PodModel>(podsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Future<Box> openPodsBox(List<int> key) async {
    final encryptedBox = await Hive.openBox<PodModel>(podsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  PodModel createPod(Pod flutterPod) {
    String id = 'this where the the generated pod id goes';
    var pod = PodModel(name: flutterPod.name, id: id);
    return pod;
  }

  Iterable<dynamic> getAllPods(Box podsBox) {
    if (podsBox.isOpen) {
      return podsBox.values;
    }
    Iterable<dynamic> noBox = [];
    return noBox;
  }

  dynamic createAndAddPod(
      EncryptionManager encrypter,
      Box podsBox,
      Box contactsBox,
      Box connectionsBox,
      Map<String, ContactModel> podContacts,
      String title) {
    var uuid = const Uuid();

    String id = uuid.v4();

    var inPods = podsBox.get(id);

    // If the pod is completely new
    if ((inPods == null)) {
      var newPod = PodModel(
        name: title,
        id: id,
      );

      podsBox.put(id, newPod);

      newPod.contacts = HiveList(contactsBox); // Create a HiveList
      newPod.contacts!.addAll(podContacts.values);

      newPod.save();
      return newPod;
    }

    return inPods;
  }

  addPod(Box podsBox, PodModel pod) {
    podsBox.add(pod);
  }

  Future<void> deletePod(PodModel pod) async {
    return pod.delete();
  }
}
