// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jenis_karyawan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JenisKaryawanModelAdapter extends TypeAdapter<JenisKaryawanModel> {
  @override
  final int typeId = 7;

  @override
  JenisKaryawanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JenisKaryawanModel(
      id: fields[0] as int,
      kode_jenis_karyawan: fields[1] as String,
      nama_jenis_karyawan: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JenisKaryawanModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kode_jenis_karyawan)
      ..writeByte(2)
      ..write(obj.nama_jenis_karyawan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JenisKaryawanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JenisKaryawanModel _$JenisKaryawanModelFromJson(Map<String, dynamic> json) =>
    JenisKaryawanModel(
      id: (json['id'] as num).toInt(),
      kode_jenis_karyawan: json['kode_jenis_karyawan'] as String,
      nama_jenis_karyawan: json['nama_jenis_karyawan'] as String,
    );

Map<String, dynamic> _$JenisKaryawanModelToJson(JenisKaryawanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kode_jenis_karyawan': instance.kode_jenis_karyawan,
      'nama_jenis_karyawan': instance.nama_jenis_karyawan,
    };
