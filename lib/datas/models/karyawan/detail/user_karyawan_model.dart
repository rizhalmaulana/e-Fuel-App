import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../unit/unit_model.dart';
import '../afdeling/afdeling_model.dart';
import '../detail/jenis_karyawan_model.dart';
import '../jabatan/jabatan_model.dart';

part 'user_karyawan_model.g.dart';

@HiveType(typeId: 4)
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserKaryawanModel extends HiveObject {
  @HiveField(0)
  final UnitModel unit;

  @HiveField(1)
  final JabatanModel jabatan;

  @HiveField(2)
  final JenisKaryawanModel jenisKaryawan;

  @HiveField(3)
  final AfdelingModel afdeling;

  @HiveField(4)
  final String? pin;

  @HiveField(5)
  final int id;

  @HiveField(6)
  final String nik;

  @HiveField(7)
  final String? nfc;

  @HiveField(8)
  final String firstName;

  @HiveField(9)
  final String? lastName;

  UserKaryawanModel({
    required this.unit,
    required this.jabatan,
    required this.jenisKaryawan,
    required this.afdeling,
    this.pin,
    required this.id,
    required this.nik,
    this.nfc,
    required this.firstName,
    this.lastName,
  });

  factory UserKaryawanModel.fromJson(Map<String, dynamic> json) => _$UserKaryawanModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserKaryawanModelToJson(this);
}