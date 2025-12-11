// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_karyawan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserKaryawanModelAdapter extends TypeAdapter<UserKaryawanModel> {
  @override
  final int typeId = 4;

  @override
  UserKaryawanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserKaryawanModel(
      unit: fields[0] as UnitModel,
      jabatan: fields[1] as JabatanModel,
      jenisKaryawan: fields[2] as JenisKaryawanModel,
      afdeling: fields[3] as AfdelingModel,
      pin: fields[4] as String?,
      id: fields[5] as int,
      nik: fields[6] as String,
      nfc: fields[7] as String?,
      firstName: fields[8] as String,
      lastName: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserKaryawanModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.unit)
      ..writeByte(1)
      ..write(obj.jabatan)
      ..writeByte(2)
      ..write(obj.jenisKaryawan)
      ..writeByte(3)
      ..write(obj.afdeling)
      ..writeByte(4)
      ..write(obj.pin)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.nik)
      ..writeByte(7)
      ..write(obj.nfc)
      ..writeByte(8)
      ..write(obj.firstName)
      ..writeByte(9)
      ..write(obj.lastName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserKaryawanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserKaryawanModel _$UserKaryawanModelFromJson(Map<String, dynamic> json) =>
    UserKaryawanModel(
      unit: UnitModel.fromJson(json['unit'] as Map<String, dynamic>),
      jabatan: JabatanModel.fromJson(json['jabatan'] as Map<String, dynamic>),
      jenisKaryawan: JenisKaryawanModel.fromJson(
          json['jenis_karyawan'] as Map<String, dynamic>),
      afdeling:
          AfdelingModel.fromJson(json['afdeling'] as Map<String, dynamic>),
      pin: json['pin'] as String?,
      id: (json['id'] as num).toInt(),
      nik: json['nik'] as String,
      nfc: json['nfc'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
    );

Map<String, dynamic> _$UserKaryawanModelToJson(UserKaryawanModel instance) =>
    <String, dynamic>{
      'unit': instance.unit.toJson(),
      'jabatan': instance.jabatan.toJson(),
      'jenis_karyawan': instance.jenisKaryawan.toJson(),
      'afdeling': instance.afdeling.toJson(),
      'pin': instance.pin,
      'id': instance.id,
      'nik': instance.nik,
      'nfc': instance.nfc,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };
