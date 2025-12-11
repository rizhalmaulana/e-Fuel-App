import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../user/user_model.dart';
import '../karyawan/kemandoran/kemandoran_model.dart';

part 'auth_response_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class AuthResponseModel extends HiveObject {
  @HiveField(0)
  final String refresh;

  @HiveField(1)
  final String access;

  @HiveField(2)
  final dynamic otorisasiData;

  @HiveField(3)
  final List<KemandoranModel> daftarKemandoran;

  @HiveField(4)
  final UserModel user;

  AuthResponseModel({
    required this.refresh,
    required this.access,
    this.otorisasiData,
    required this.daftarKemandoran,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}