import 'package:crypt/crypt.dart';
import 'package:encrypt/encrypt.dart';
import 'package:amipod/Services/secure_storage.dart';

class EncryptionManager {
  SecureStorage storage = SecureStorage();
  final String encryptionString;
  final iv = IV.fromLength(16);
  late Key encryptionKey;

  EncryptionManager({required this.encryptionString});

  createEncryptionKey() {
    encryptionKey = Key.fromUtf8(encryptionString);
  }

  hashPassword(String password) {
    String hashedPassword = Crypt.sha256(password).toString(); // 2
    return hashedPassword;
  }

  encryptData(String encryptionType, String data) {
    var encryptionData = "$encryptionType:$data";
    final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(encryptionData, iv: iv);
    return encrypted.base64;
  }

  String decryptData(String data) {
    final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(Encrypted.from64(data), iv: iv);
    return decrypted;
  }
}
