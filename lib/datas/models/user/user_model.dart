import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../karyawan/jabatan/jabatan_model.dart';
import '../karyawan/detail/user_karyawan_model.dart';
import '../master_menu/app_menu_model.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String firstName;

  @HiveField(3)
  final String? lastName;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final bool isSuperuser;

  @HiveField(6)
  final bool isStaff;

  @HiveField(7)
  final JabatanModel? jabatan;

  @HiveField(8)
  final List<String> otorisasi;

  @HiveField(9)
  final UserKaryawanModel? userKaryawan;

  @HiveField(10)
  final List<AppMenuModel>? appMenu;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    this.lastName,
    this.email,
    required this.isSuperuser,
    required this.isStaff,
    this.jabatan,
    required this.otorisasi,
    this.userKaryawan,
    this.appMenu,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Helper
  bool get isKrani => otorisasi.contains('fuel_level_1');
  bool get isApprover => otorisasi.contains('fuel_level_2') || otorisasi.contains('fuel_level_3');
}