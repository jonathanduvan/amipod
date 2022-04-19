import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'pod_model.g.dart';

@HiveType(typeId: 3)
class PodModel extends HiveObject {
  PodModel(
      {required this.name,
      required this.id,
      this.avatar,
      this.connections,
      this.contacts});

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Uint8List? avatar;

  @HiveField(3)
  HiveList? connections;

  @HiveField(4)
  HiveList? contacts;
}
