// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'afdeling_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AfdelingModelAdapter extends TypeAdapter<AfdelingModel> {
  @override
  final int typeId = 6;

  @override
  AfdelingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AfdelingModel(
      id: fields[0] as int,
      kodeAfdeling: fields[1] as String,
      namaAfdeling: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AfdelingModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kodeAfdeling)
      ..writeByte(2)
      ..write(obj.namaAfdeling);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AfdelingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AfdelingModel _$AfdelingModelFromJson(Map<String, dynamic> json) =>
    AfdelingModel(
      id: (json['id'] as num).toInt(),
      kodeAfdeling: json['kode_afdeling'] as String,
      namaAfdeling: json['nama_afdeling'] as String,
    );

Map<String, dynamic> _$AfdelingModelToJson(AfdelingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kode_afdeling': instance.kodeAfdeling,
      'nama_afdeling': instance.namaAfdeling,
    };
