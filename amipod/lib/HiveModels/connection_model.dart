// Connection Objects
import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'connection_model.g.dart';

@HiveType(typeId: 1)
class ConnectionModel extends HiveObject {
  ConnectionModel(
      {required this.id,
      required this.name,
      required this.initials,
      required this.phone,
      required this.lat,
      required this.long,
      this.city});
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

  @HiveField(5, defaultValue: 'Not Available')
  String? lat;

  @HiveField(6, defaultValue: 'Not Available')
  String? long;

  @HiveField(7, defaultValue: 'Not Available')
  String? city;

  @HiveField(8, defaultValue: 'Not Available')
  String? street;
}
