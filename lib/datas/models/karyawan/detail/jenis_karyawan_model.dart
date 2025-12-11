import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'jenis_karyawan_model.g.dart';

@HiveType(typeId: 7)
@JsonSerializable(fieldRename: FieldRename.snake)
class JenisKaryawanModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String kode_jenis_karyawan;

  @HiveField(2)
  final String nama_jenis_karyawan;

  JenisKaryawanModel({required this.id, required this.kode_jenis_karyawan, required this.nama_jenis_karyawan});

  factory JenisKaryawanModel.fromJson(Map<String, dynamic> json) => _$JenisKaryawanModelFromJson(json);
  Map<String, dynamic> toJson() => _$JenisKaryawanModelToJson(this);
}