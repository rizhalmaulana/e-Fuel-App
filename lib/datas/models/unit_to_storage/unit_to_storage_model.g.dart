// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_to_storage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitToStorageModelAdapter extends TypeAdapter<UnitToStorageModel> {
  @override
  final int typeId = 24;

  @override
  UnitToStorageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitToStorageModel(
      unit: fields[0] as StorageUnitModel,
      masterStorage: (fields[1] as List).cast<MasterStorageModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, UnitToStorageModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.unit)
      ..writeByte(1)
      ..write(obj.masterStorage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitToStorageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitToStorageItemModelAdapter
    extends TypeAdapter<UnitToStorageItemModel> {
  @override
  final int typeId = 25;

  @override
  UnitToStorageItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitToStorageItemModel(
      kodeStorage: fields[0] as String,
      namaStorage: fields[1] as String,
      status: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UnitToStorageItemModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.kodeStorage)
      ..writeByte(1)
      ..write(obj.namaStorage)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitToStorageItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
