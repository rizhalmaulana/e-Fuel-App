// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kemandoran_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KemandoranModelAdapter extends TypeAdapter<KemandoranModel> {
  @override
  final int typeId = 9;

  @override
  KemandoranModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KemandoranModel(
      id: fields[0] as int,
      kodeKemandoran: fields[1] as String,
      namaKemandoran: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KemandoranModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kodeKemandoran)
      ..writeByte(2)
      ..write(obj.namaKemandoran);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KemandoranModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KemandoranModel _$KemandoranModelFromJson(Map<String, dynamic> json) =>
    KemandoranModel(
      id: (json['id'] as num).toInt(),
      kodeKemandoran: json['kode_kemandoran'] as String,
      namaKemandoran: json['nama_kemandoran'] as String,
    );

Map<String, dynamic> _$KemandoranModelToJson(KemandoranModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kode_kemandoran': instance.kodeKemandoran,
      'nama_kemandoran': instance.namaKemandoran,
    };
