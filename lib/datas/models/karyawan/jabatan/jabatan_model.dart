import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'jabatan_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable(fieldRename: FieldRename.snake)
class JabatanModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String kodeJabatan;

  @HiveField(2)
  final String namaJabatan;

  @HiveField(3)
  final bool isMandor;

  @HiveField(4)
  final bool isActive;

  @HiveField(5)
  final bool isAsisten;

  JabatanModel({
    required this.id,
    required this.kodeJabatan,
    required this.namaJabatan,
    required this.isMandor,
    required this.isActive,
    required this.isAsisten,
  });

  factory JabatanModel.fromJson(Map<String, dynamic> json) =>
      _$JabatanModelFromJson(json);

  Map<String, dynamic> toJson() => _$JabatanModelToJson(this);
}