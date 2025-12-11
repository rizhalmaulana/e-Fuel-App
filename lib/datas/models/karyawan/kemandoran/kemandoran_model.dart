import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'kemandoran_model.g.dart';

@HiveType(typeId: 9)
@JsonSerializable(fieldRename: FieldRename.snake)
class KemandoranModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String kodeKemandoran;

  @HiveField(2)
  final String namaKemandoran;

  KemandoranModel({
    required this.id,
    required this.kodeKemandoran,
    required this.namaKemandoran,
  });

  // Metode untuk parsing JSON ke model
  factory KemandoranModel.fromJson(Map<String, dynamic> json) =>
      _$KemandoranModelFromJson(json);

  // Metode untuk konversi model ke JSON
  Map<String, dynamic> toJson() => _$KemandoranModelToJson(this);
}