// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConnectionModelAdapter extends TypeAdapter<ConnectionModel> {
  @override
  final int typeId = 1;

  @override
  ConnectionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConnectionModel(
      id: fields[0] as String,
      name: fields[1] as String,
      initials: fields[2] as String,
      phone: fields[4] as String,
      lat: fields[5] == null ? 'Not Available' : fields[5] as String?,
      long: fields[6] == null ? 'Not Available' : fields[6] as String?,
      city: fields[7] == null ? 'Not Available' : fields[7] as String?,
      blocked: fields[9] == null ? false : fields[9] as bool?,
      last_update: fields[10] == null ? 'Not Available' : fields[10] as String?,
    )
      ..avatar = fields[3] as Uint8List?
      ..street = fields[8] == null ? 'Not Available' : fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, ConnectionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.initials)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.lat)
      ..writeByte(6)
      ..write(obj.long)
      ..writeByte(7)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.street)
      ..writeByte(9)
      ..write(obj.blocked)
      ..writeByte(10)
      ..write(obj.last_update);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
