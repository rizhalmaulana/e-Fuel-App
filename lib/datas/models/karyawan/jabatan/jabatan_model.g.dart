// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jabatan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JabatanModelAdapter extends TypeAdapter<JabatanModel> {
  @override
  final int typeId = 3;

  @override
  JabatanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JabatanModel(
      id: fields[0] as int,
      kodeJabatan: fields[1] as String?,
      namaJabatan: fields[2] as String?,
      isMandor: fields[3] as bool,
      isActive: fields[4] as bool,
      isAsisten: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, JabatanModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kodeJabatan)
      ..writeByte(2)
      ..write(obj.namaJabatan)
      ..writeByte(3)
      ..write(obj.isMandor)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.isAsisten);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JabatanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JabatanModel _$JabatanModelFromJson(Map<String, dynamic> json) => JabatanModel(
      id: (json['id'] as num).toInt(),
      kodeJabatan: json['kode_jabatan'] as String?,
      namaJabatan: json['nama_jabatan'] as String?,
      isMandor: json['is_mandor'] as bool,
      isActive: json['is_active'] as bool,
      isAsisten: json['is_asisten'] as bool,
    );

Map<String, dynamic> _$JabatanModelToJson(JabatanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kode_jabatan': instance.kodeJabatan,
      'nama_jabatan': instance.namaJabatan,
      'is_mandor': instance.isMandor,
      'is_active': instance.isActive,
      'is_asisten': instance.isAsisten,
    };
