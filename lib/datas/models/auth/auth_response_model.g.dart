// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthResponseModelAdapter extends TypeAdapter<AuthResponseModel> {
  @override
  final int typeId = 1;

  @override
  AuthResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthResponseModel(
      refresh: fields[0] as String,
      access: fields[1] as String,
      otorisasiData: fields[2] as OtorisasiDataModel?,
      daftarKemandoran: (fields[3] as List).cast<KemandoranModel>(),
      user: fields[4] as UserModel,
    );
  }

  @override
  void write(BinaryWriter writer, AuthResponseModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.refresh)
      ..writeByte(1)
      ..write(obj.access)
      ..writeByte(2)
      ..write(obj.otorisasiData)
      ..writeByte(3)
      ..write(obj.daftarKemandoran)
      ..writeByte(4)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      refresh: json['refresh'] as String,
      access: json['access'] as String,
      otorisasiData: json['otorisasi_data'] == null
          ? null
          : OtorisasiDataModel.fromJson(
              json['otorisasi_data'] as Map<String, dynamic>),
      daftarKemandoran: (json['daftar_kemandoran'] as List<dynamic>)
          .map((e) => KemandoranModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'refresh': instance.refresh,
      'access': instance.access,
      'otorisasi_data': instance.otorisasiData?.toJson(),
      'daftar_kemandoran':
          instance.daftarKemandoran.map((e) => e.toJson()).toList(),
      'user': instance.user.toJson(),
    };
