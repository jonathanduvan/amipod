import 'package:dipity/Services/database_api.dart';
import 'package:dipity/Services/encryption.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:dipity/Services/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CheckInModel extends ChangeNotifier {
  SecureStorage storage = SecureStorage();
  HiveAPI hiveApi = HiveAPI();
  DatabaseAPI dbApi = DatabaseAPI();

  EncryptionManager encrypter = EncryptionManager();

  late Box checkInBox;

  List<dynamic> get checkIns {
    Iterable<dynamic> unsortedCheckIns = hiveApi.getAllContacts(checkInBox);
    return [...unsortedCheckIns];
  }

  createCheckIn() {}

  deleteCheckIn() {}

  updateCheckIn() {}
}
