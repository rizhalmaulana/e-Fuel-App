// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitModelAdapter extends TypeAdapter<UnitModel> {
  @override
  final int typeId = 5;

  @override
  UnitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitModel(
      id: fields[0] as int,
      kodeUnit: fields[1] as String,
      namaUnit: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UnitModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kodeUnit)
      ..writeByte(2)
      ..write(obj.namaUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitModel _$UnitModelFromJson(Map<String, dynamic> json) => UnitModel(
      id: (json['id'] as num).toInt(),
      kodeUnit: json['kode_unit'] as String,
      namaUnit: json['nama_unit'] as String,
    );

Map<String, dynamic> _$UnitModelToJson(UnitModel instance) => <String, dynamic>{
      'id': instance.id,
      'kode_unit': instance.kodeUnit,
      'nama_unit': instance.namaUnit,
    };
