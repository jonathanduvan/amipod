// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckInModelAdapter extends TypeAdapter<CheckInModel> {
  @override
  final int typeId = 4;

  @override
  CheckInModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckInModel(
      id: fields[0] as String,
      name: fields[1] as String,
      completed: fields[2] as bool,
      due_date: fields[3] as DateTime?,
      start_date: fields[4] as DateTime?,
      about: fields[5] == null ? [] : (fields[5] as List?)?.cast<String>(),
      connections: (fields[6] as HiveList?)?.castHiveList(),
      contacts: (fields[7] as HiveList?)?.castHiveList(),
      frequency: fields[8] as int?,
      length: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CheckInModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.due_date)
      ..writeByte(4)
      ..write(obj.start_date)
      ..writeByte(5)
      ..write(obj.about)
      ..writeByte(6)
      ..write(obj.connections)
      ..writeByte(7)
      ..write(obj.contacts)
      ..writeByte(8)
      ..write(obj.frequency)
      ..writeByte(9)
      ..write(obj.length);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
