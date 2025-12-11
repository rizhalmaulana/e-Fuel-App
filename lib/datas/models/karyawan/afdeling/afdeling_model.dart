import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'afdeling_model.g.dart';

@HiveType(typeId: 6)
@JsonSerializable(fieldRename: FieldRename.snake)
class AfdelingModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String kodeAfdeling;

  @HiveField(2)
  final String namaAfdeling;

  AfdelingModel({required this.id, required this.kodeAfdeling, required this.namaAfdeling});

  factory AfdelingModel.fromJson(Map<String, dynamic> json) => _$AfdelingModelFromJson(json);
  Map<String, dynamic> toJson() => _$AfdelingModelToJson(this);
}