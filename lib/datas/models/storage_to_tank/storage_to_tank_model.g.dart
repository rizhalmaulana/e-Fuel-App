// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_to_tank_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StorageToTankModelAdapter extends TypeAdapter<StorageToTankModel> {
  @override
  final int typeId = 26;

  @override
  StorageToTankModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageToTankModel(
      id: fields[0] as int,
      unit: fields[1] as StorageUnitModel?,
      masterStorage: fields[2] as CSTStorageModel?,
      masterSolarTank: fields[3] as CSTTankModel?,
      status: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StorageToTankModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.masterStorage)
      ..writeByte(3)
      ..write(obj.masterSolarTank)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageToTankModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CSTStorageModelAdapter extends TypeAdapter<CSTStorageModel> {
  @override
  final int typeId = 27;

  @override
  CSTStorageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CSTStorageModel(
      kodeStorage: fields[0] as String,
      namaStorage: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CSTStorageModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.kodeStorage)
      ..writeByte(1)
      ..write(obj.namaStorage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CSTStorageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CSTTankModelAdapter extends TypeAdapter<CSTTankModel> {
  @override
  final int typeId = 28;

  @override
  CSTTankModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CSTTankModel(
      kodeTank: fields[0] as String,
      namaTank: fields[1] as String,
      capacity: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CSTTankModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.kodeTank)
      ..writeByte(1)
      ..write(obj.namaTank)
      ..writeByte(2)
      ..write(obj.capacity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CSTTankModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
