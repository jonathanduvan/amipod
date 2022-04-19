// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pod_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PodModelAdapter extends TypeAdapter<PodModel> {
  @override
  final int typeId = 3;

  @override
  PodModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PodModel(
      name: fields[1] as String,
      id: fields[0] as String,
      avatar: fields[2] as Uint8List?,
      connections: (fields[3] as HiveList?)?.castHiveList(),
      contacts: (fields[4] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, PodModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatar)
      ..writeByte(3)
      ..write(obj.connections)
      ..writeByte(4)
      ..write(obj.contacts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
