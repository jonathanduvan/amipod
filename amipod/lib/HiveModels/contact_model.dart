// Connection Objects
import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 2)
class ContactModel extends HiveObject {
  ContactModel(
      {required this.id,
      required this.name,
      required this.initials,
      required this.phone});
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String initials;

  @HiveField(3)
  Uint8List? avatar;

  @HiveField(4)
  String phone;
}
