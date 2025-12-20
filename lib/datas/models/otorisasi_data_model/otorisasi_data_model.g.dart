// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otorisasi_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OtorisasiDataModelAdapter extends TypeAdapter<OtorisasiDataModel> {
  @override
  final int typeId = 32;

  @override
  OtorisasiDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OtorisasiDataModel(
      area: (fields[0] as List?)?.cast<OtorisasiAreaModel>(),
      unit: (fields[1] as List?)?.cast<OtorisasiUnitModel>(),
      afdeling: (fields[2] as List?)?.cast<OtorisasiAfdelingModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, OtorisasiDataModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.area)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.afdeling);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtorisasiDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OtorisasiAreaModelAdapter extends TypeAdapter<OtorisasiAreaModel> {
  @override
  final int typeId = 33;

  @override
  OtorisasiAreaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OtorisasiAreaModel(
      id: fields[0] as int,
      namaArea: fields[1] as String,
      kodeArea: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OtorisasiAreaModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaArea)
      ..writeByte(2)
      ..write(obj.kodeArea);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtorisasiAreaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OtorisasiUnitModelAdapter extends TypeAdapter<OtorisasiUnitModel> {
  @override
  final int typeId = 34;

  @override
  OtorisasiUnitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OtorisasiUnitModel(
      id: fields[0] as int,
      kodeUnit: fields[1] as String,
      namaUnit: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OtorisasiUnitModel obj) {
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
      other is OtorisasiUnitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OtorisasiAfdelingModelAdapter
    extends TypeAdapter<OtorisasiAfdelingModel> {
  @override
  final int typeId = 35;

  @override
  OtorisasiAfdelingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OtorisasiAfdelingModel(
      id: fields[0] as int,
      kodeAfdeling: fields[1] as String,
      namaAfdeling: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OtorisasiAfdelingModel obj) {
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
      other is OtorisasiAfdelingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtorisasiDataModel _$OtorisasiDataModelFromJson(Map<String, dynamic> json) =>
    OtorisasiDataModel(
      area: (json['area'] as List<dynamic>?)
          ?.map((e) => OtorisasiAreaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      unit: (json['unit'] as List<dynamic>?)
          ?.map((e) => OtorisasiUnitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      afdeling: (json['afdeling'] as List<dynamic>?)
          ?.map(
              (e) => OtorisasiAfdelingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OtorisasiDataModelToJson(OtorisasiDataModel instance) =>
    <String, dynamic>{
      'area': instance.area?.map((e) => e.toJson()).toList(),
      'unit': instance.unit?.map((e) => e.toJson()).toList(),
      'afdeling': instance.afdeling?.map((e) => e.toJson()).toList(),
    };

OtorisasiAreaModel _$OtorisasiAreaModelFromJson(Map<String, dynamic> json) =>
    OtorisasiAreaModel(
      id: (json['id'] as num).toInt(),
      namaArea: json['nama_area'] as String,
      kodeArea: json['kode_area'] as String,
    );

Map<String, dynamic> _$OtorisasiAreaModelToJson(OtorisasiAreaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nama_area': instance.namaArea,
      'kode_area': instance.kodeArea,
    };

OtorisasiUnitModel _$OtorisasiUnitModelFromJson(Map<String, dynamic> json) =>
    OtorisasiUnitModel(
      id: (json['id'] as num).toInt(),
      kodeUnit: json['kode_unit'] as String,
      namaUnit: json['nama_unit'] as String,
    );

Map<String, dynamic> _$OtorisasiUnitModelToJson(OtorisasiUnitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kode_unit': instance.kodeUnit,
      'nama_unit': instance.namaUnit,
    };

OtorisasiAfdelingModel _$OtorisasiAfdelingModelFromJson(
        Map<String, dynamic> json) =>
    OtorisasiAfdelingModel(
      id: (json['id'] as num).toInt(),
      kodeAfdeling: json['kode_afdeling'] as String,
      namaAfdeling: json['nama_afdeling'] as String,
    );

Map<String, dynamic> _$OtorisasiAfdelingModelToJson(
        OtorisasiAfdelingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kode_afdeling': instance.kodeAfdeling,
      'nama_afdeling': instance.namaAfdeling,
    };
