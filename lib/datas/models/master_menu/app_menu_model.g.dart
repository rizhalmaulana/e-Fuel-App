// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_menu_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppMenuModelAdapter extends TypeAdapter<AppMenuModel> {
  @override
  final int typeId = 8;

  @override
  AppMenuModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppMenuModel(
      namaLevelMenu: fields[0] as String,
      menu: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppMenuModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.namaLevelMenu)
      ..writeByte(1)
      ..write(obj.menu);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppMenuModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppMenuModel _$AppMenuModelFromJson(Map<String, dynamic> json) => AppMenuModel(
      namaLevelMenu: json['nama_level_menu'] as String,
      menu: (json['menu'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AppMenuModelToJson(AppMenuModel instance) =>
    <String, dynamic>{
      'nama_level_menu': instance.namaLevelMenu,
      'menu': instance.menu,
    };
