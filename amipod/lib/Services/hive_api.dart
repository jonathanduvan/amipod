import 'dart:convert';
import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/Services/encryption.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';

class HiveAPI {
  String contactsBoxName = 'contactsBox';
  String connectionsBoxName = 'connectionsBox';
  String podsBoxName = 'podsBox';
  String checkInBoxName = 'checkInBox';

  bool areBoxesOpen(List<Box> boxes) {
    bool open = true;
    boxes.forEach((element) {
      if (element.isOpen == false) {
        open = false;
      }
    });
    return open;
  }

  Future<Box> getContactsBox(List<int> key) async {
    // return Hive.box<ContactModel>(contactsBoxName);
    final encryptedBox = await Hive.openBox<ContactModel>(contactsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Future<Box> getConnectionsBox(List<int> key) async {
    // return Hive.box<ContactModel>(contactsBoxName);
    final encryptedBox = await Hive.openBox<ConnectionModel>(connectionsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Future<Box> getPodsBox(List<int> key) async {
    // return Hive.box<ContactModel>(contactsBoxName);
    final encryptedBox = await Hive.openBox<PodModel>(podsBoxName,
        encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  List<int> decodeHiveBoxKey(String key) {
    final encryptionKey = base64Url.decode(key);
    return encryptionKey;
  }

  // Functions Relating to Contacts
  Future<Box> createContactsBox(List<int> key) async {
    // Initialize TypeAdapters
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

  getContact(Box contactsBox, String id) {
    return contactsBox.get(id);
  }

  //

  block(Box box, String id) {
    var userModel = box.get(id);

    if (userModel is ConnectionModel) {
      ConnectionModel user = userModel;
      user.blocked = true;
      print(user.blocked);
      print(id);
      print(user.name);
      user.save();
      print(user.blocked);
    } else {
      ContactModel user = userModel;

      user.blocked = true;
      print(user.blocked);
      user.save();
    }
    print("we going to block the following user: $id");
  }

  unblock(Box box, String id) {
    var userModel = box.get(id);

    userModel.blocked = false;

    userModel.save();
  }
  //

  // Functions Relating to Connections

  Future<Box> createConnectionsBox(List<int> key) async {
    // Initialize TypeAdapters
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

  void addConnections(EncryptionManager encrypter, Box connectionsBox,
      List<ConnectedContact> connContacts) async {
    for (var element in connContacts) {
      String id = encrypter.encryptData(element.phone);

      if (!element.uncharted) {
        var connection = ConnectionModel(
            id: id,
            name: element.name,
            initials: element.initials,
            phone: element.phone,
            lat: element.location!.latitude.toString(),
            long: element.location!.longitude.toString(),
            city: element.city,
            blocked: element.blocked,
            last_update: element.last_update);
        if (element.avatar != null && element.avatar?.isEmpty == true) {
          connection.avatar = element.avatar;
        }

        connectionsBox.put(id, connection);
      }
    }
  }

  getConnection(Box connectionsBox, String id) {
    return connectionsBox.get(id);
  }

  // Functions Relating to Pods

  Future<Box> createPodsBox(List<int> key) async {
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
      Map<String, ConnectionModel> podConnections,
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

      newPod.connections = HiveList(connectionsBox); // Create a HiveList
      newPod.connections!.addAll(podConnections.values);

      newPod.save();

      return newPod;
    }

    return inPods;
  }

  bool updatePod(
      Box podsBox,
      String id,
      Map<String, ConnectionModel> connections,
      Map<String, ContactModel> contacts,
      String title) {
    PodModel inPods = podsBox.get(id);

    inPods.contacts?.clear();
    inPods.contacts?.addAll(contacts.values);

    inPods.connections?.clear();
    inPods.connections?.addAll(connections.values);

    inPods.name = title;

    inPods.save();
    return true;
  }

  getPod(Box podsBox, String id) {
    return podsBox.get(id);
  }

  addPod(Box podsBox, PodModel pod) {
    podsBox.add(pod);
  }

  Future<void> deletePod(PodModel pod) async {
    return pod.delete();
  }

  // Check if name of pod being created or updated already has a pod with the same name
  bool checkPodTitle(Box box, String name, String? id) {
    Iterable<dynamic> pods = box.values;

    for (PodModel pod in pods) {
      print(pod.name);
      print(name);
      print('OH WE COMPARING');

      if ((pod.name == name) && ((id != null) && (id != pod.id))) {
        return false;
      } else if (pod.name == name) {
        print('we returned false');
        return false;
      }
    }
    print('we didn NOTTTT erturn fale');
    return true;
  }
}
