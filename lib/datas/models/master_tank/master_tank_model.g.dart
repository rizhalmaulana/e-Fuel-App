// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_tank_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MasterTankModelAdapter extends TypeAdapter<MasterTankModel> {
  @override
  final int typeId = 23;

  @override
  MasterTankModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MasterTankModel(
      id: fields[0] as int,
      kodeTank: fields[1] as String,
      namaTank: fields[2] as String,
      tankStatus: fields[3] as String,
      unit: fields[4] as StorageUnitModel?,
    );
  }

  @override
  void write(BinaryWriter writer, MasterTankModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kodeTank)
      ..writeByte(2)
      ..write(obj.namaTank)
      ..writeByte(3)
      ..write(obj.tankStatus)
      ..writeByte(4)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterTankModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
