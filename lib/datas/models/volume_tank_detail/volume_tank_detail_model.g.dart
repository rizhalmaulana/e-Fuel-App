// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_tank_detail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VolumeTankDetailModelAdapter extends TypeAdapter<VolumeTankDetailModel> {
  @override
  final int typeId = 29;

  @override
  VolumeTankDetailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VolumeTankDetailModel(
      id: fields[0] as int,
      unit: fields[1] as StorageUnitModel?,
      masterStorage: fields[2] as CSTStorageModel?,
      masterSolarTank: fields[3] as CSTTankModel?,
      volume: fields[4] as double,
      height: fields[5] as double,
      createdAt: fields[6] as String?,
      updatedAt: fields[7] as String?,
      capacity: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VolumeTankDetailModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.masterStorage)
      ..writeByte(3)
      ..write(obj.masterSolarTank)
      ..writeByte(4)
      ..write(obj.volume)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.capacity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolumeTankDetailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
