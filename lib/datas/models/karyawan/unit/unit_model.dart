import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit_model.g.dart';

@HiveType(typeId: 5)
@JsonSerializable(fieldRename: FieldRename.snake)
class UnitModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String kodeUnit;

  @HiveField(2)
  final String namaUnit;

  UnitModel({required this.id, required this.kodeUnit, required this.namaUnit});

  factory UnitModel.fromJson(Map<String, dynamic> json) => _$UnitModelFromJson(json);
  Map<String, dynamic> toJson() => _$UnitModelToJson(this);
}