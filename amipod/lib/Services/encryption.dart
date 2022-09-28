import 'dart:convert';

import 'package:crypt/crypt.dart';
import 'package:encrypt/encrypt.dart';
import 'package:amipod/Services/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionManager {
  SecureStorage storage = SecureStorage();
  late Key encryptionKey;
  late IV iv;

  final String _privateIV = 'privateIV';
  final String _privateKey = 'privateKey';

  EncryptionManager() {
    encryptionKey = Key.fromUtf8(dotenv.env[_privateKey] ?? '');
    iv = IV.fromUtf8(utf8.decode((dotenv.env[_privateIV] ?? '').codeUnits));
  }

  hashPassword(String password) {
    String hashedPassword = Crypt.sha256(password).toString(); // 2
    return hashedPassword;
  }

  bool isPasswordValid(String cryptFormatHash, String enteredPassword) {
    return Crypt(cryptFormatHash).match(enteredPassword);
  }

  String encryptData(String data) {
    final encrypter = Encrypter(AES(encryptionKey));
    final encrypted = encrypter.encrypt(
      data,
      iv: iv,
    );
    return encrypted.base64;
  }

  String decryptData(String data) {
    final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(Encrypted.from64(data), iv: iv);
    return decrypted;
  }
}
