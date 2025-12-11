// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StorageModelAdapter extends TypeAdapter<StorageModel> {
  @override
  final int typeId = 10;

  @override
  StorageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageModel(
      storageCode: fields[0] as String,
      storageDesc: fields[1] as String,
      storageActive: fields[2] as String,
      storageName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StorageModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.storageCode)
      ..writeByte(1)
      ..write(obj.storageDesc)
      ..writeByte(2)
      ..write(obj.storageActive)
      ..writeByte(3)
      ..write(obj.storageName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TankModelAdapter extends TypeAdapter<TankModel> {
  @override
  final int typeId = 11;

  @override
  TankModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TankModel(
      tankCode: fields[0] as String,
      tankDesc: fields[1] as String,
      tankActive: fields[2] as String,
      tankId: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TankModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tankCode)
      ..writeByte(1)
      ..write(obj.tankDesc)
      ..writeByte(2)
      ..write(obj.tankActive)
      ..writeByte(3)
      ..write(obj.tankId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TankModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StorageTankModelAdapter extends TypeAdapter<StorageTankModel> {
  @override
  final int typeId = 12;

  @override
  StorageTankModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageTankModel(
      storageCode: fields[0] as String,
      tankCode: fields[1] as String,
      volume: fields[2] as double,
      height: fields[3] as int,
      statusActive: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StorageTankModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.storageCode)
      ..writeByte(1)
      ..write(obj.tankCode)
      ..writeByte(2)
      ..write(obj.volume)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.statusActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageTankModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
