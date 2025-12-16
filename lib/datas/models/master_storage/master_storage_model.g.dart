// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_storage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MasterStorageModelAdapter extends TypeAdapter<MasterStorageModel> {
  @override
  final int typeId = 21;

  @override
  MasterStorageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MasterStorageModel(
      id: fields[0] as int,
      kodeStorage: fields[1] as String,
      namaStorage: fields[2] as String,
      storageStatus: fields[3] as String,
      unit: fields[4] as StorageUnitModel?,
    );
  }

  @override
  void write(BinaryWriter writer, MasterStorageModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kodeStorage)
      ..writeByte(2)
      ..write(obj.namaStorage)
      ..writeByte(3)
      ..write(obj.storageStatus)
      ..writeByte(4)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterStorageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
