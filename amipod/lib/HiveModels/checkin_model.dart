// Connection Objects
import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'checkin_model.g.dart';

@HiveType(typeId: 4)
class CheckInModel extends HiveObject {
  CheckInModel(
      {required this.id,
      required this.name,
      required this.completed,
      required this.due_date,
      required this.start_date,
      this.about,
      this.connections,
      this.contacts,
      this.frequency,
      this.length});
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  DateTime? due_date;

  @HiveField(4)
  DateTime? start_date;

  @HiveField(5, defaultValue: [])
  List<String>? about;

  @HiveField(6)
  HiveList? connections;

  @HiveField(7)
  HiveList? contacts;

  @HiveField(8)
  int? frequency;

  @HiveField(9)
  String? length;
}
