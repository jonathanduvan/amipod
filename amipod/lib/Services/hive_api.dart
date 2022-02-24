import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';

class HiveAPI {
  List<int> decodeHiveBoxKey(String key) {
    final encryptionKey = base64Url.decode(key);
    return encryptionKey;
  }

  Future<Box> createContactsBox(List<int> key) async {
    final encryptedBox =
        await Hive.openBox('contactsBox', encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Future<Box> createConnectionsBox(List<int> key) async {
    final encryptedBox =
        await Hive.openBox('contactsBox', encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }

  Future<Box> createPodBox(List<int> key) async {
    final encryptedBox =
        await Hive.openBox('podBox', encryptionCipher: HiveAesCipher(key));
    return encryptedBox;
  }
}
