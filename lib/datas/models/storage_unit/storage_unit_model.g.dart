// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_unit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StorageUnitModelAdapter extends TypeAdapter<StorageUnitModel> {
  @override
  final int typeId = 22;

  @override
  StorageUnitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageUnitModel(
      kodeUnit: fields[0] as String,
      namaUnit: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StorageUnitModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.kodeUnit)
      ..writeByte(1)
      ..write(obj.namaUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageUnitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
