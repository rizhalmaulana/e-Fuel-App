// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 2;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as int,
      username: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      email: fields[4] as String,
      isSuperuser: fields[5] as bool,
      isStaff: fields[6] as bool,
      jabatan: fields[7] as JabatanModel,
      otorisasi: (fields[8] as List).cast<String>(),
      userKaryawan: fields[9] as UserKaryawanModel,
      appMenu: (fields[10] as List).cast<AppMenuModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.isSuperuser)
      ..writeByte(6)
      ..write(obj.isStaff)
      ..writeByte(7)
      ..write(obj.jabatan)
      ..writeByte(8)
      ..write(obj.otorisasi)
      ..writeByte(9)
      ..write(obj.userKaryawan)
      ..writeByte(10)
      ..write(obj.appMenu);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      isSuperuser: json['is_superuser'] as bool,
      isStaff: json['is_staff'] as bool,
      jabatan: JabatanModel.fromJson(json['jabatan'] as Map<String, dynamic>),
      otorisasi:
          (json['otorisasi'] as List<dynamic>).map((e) => e as String).toList(),
      userKaryawan: UserKaryawanModel.fromJson(
          json['user_karyawan'] as Map<String, dynamic>),
      appMenu: (json['app_menu'] as List<dynamic>)
          .map((e) => AppMenuModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'is_superuser': instance.isSuperuser,
      'is_staff': instance.isStaff,
      'jabatan': instance.jabatan.toJson(),
      'otorisasi': instance.otorisasi,
      'user_karyawan': instance.userKaryawan.toJson(),
      'app_menu': instance.appMenu.map((e) => e.toJson()).toList(),
    };
