import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otorisasi_data_model.g.dart';

@HiveType(typeId: 32)
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class OtorisasiDataModel extends HiveObject {
  @HiveField(0)
  final List<OtorisasiAreaModel>? area;

  @HiveField(1)
  final List<OtorisasiUnitModel>? unit;

  @HiveField(2)
  final List<OtorisasiAfdelingModel>? afdeling;

  OtorisasiDataModel({
    this.area,
    this.unit,
    this.afdeling,
  });

  factory OtorisasiDataModel.fromJson(Map<String, dynamic> json) =>
      _$OtorisasiDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtorisasiDataModelToJson(this);
}

@HiveType(typeId: 33)
@JsonSerializable(fieldRename: FieldRename.snake)
class OtorisasiAreaModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String namaArea;

  @HiveField(2)
  final String kodeArea;

  OtorisasiAreaModel({
    required this.id,
    required this.namaArea,
    required this.kodeArea,
  });

  factory OtorisasiAreaModel.fromJson(Map<String, dynamic> json) =>
      _$OtorisasiAreaModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtorisasiAreaModelToJson(this);
}

@HiveType(typeId: 34)
@JsonSerializable(fieldRename: FieldRename.snake)
class OtorisasiUnitModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String kodeUnit;

  @HiveField(2)
  final String namaUnit;

  OtorisasiUnitModel({
    required this.id,
    required this.kodeUnit,
    required this.namaUnit,
  });

  factory OtorisasiUnitModel.fromJson(Map<String, dynamic> json) =>
      _$OtorisasiUnitModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtorisasiUnitModelToJson(this);
}

@HiveType(typeId: 35)
@JsonSerializable(fieldRename: FieldRename.snake)
class OtorisasiAfdelingModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String kodeAfdeling;

  @HiveField(2)
  final String namaAfdeling;

  OtorisasiAfdelingModel({
    required this.id,
    required this.kodeAfdeling,
    required this.namaAfdeling,
  });

  factory OtorisasiAfdelingModel.fromJson(Map<String, dynamic> json) =>
      _$OtorisasiAfdelingModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtorisasiAfdelingModelToJson(this);
}