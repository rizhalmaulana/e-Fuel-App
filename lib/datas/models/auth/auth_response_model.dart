import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../otorisasi_data_model/otorisasi_data_model.dart';
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
  final OtorisasiDataModel? otorisasiData;

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

  String? get currentKodeUnit {
    final karyawan = user.userKaryawan;
    if (karyawan != null) {
      return karyawan.unit.kodeUnit;
    }

    final authData = otorisasiData;
    if (authData?.unit != null && authData!.unit!.isNotEmpty) {
      return authData.unit!.first.kodeUnit;
    }

    return null;
  }

  String? get currentNamaUnit {
    final karyawan = user.userKaryawan;
    if (karyawan != null) {
      return karyawan.unit.namaUnit;
    }

    final authData = otorisasiData;
    if (authData?.unit != null && authData!.unit!.isNotEmpty) {
      return authData.unit!.first.namaUnit;
    }

    return null;
  }

  String? get currentKodeArea {
    final authData = otorisasiData;
    if (authData?.area != null && authData!.area!.isNotEmpty) {
      return authData.area!.first.kodeArea;
    }
    return null;
  }

  String get currentFullName {
    final karyawan = user.userKaryawan;
    if (karyawan != null) {
      return karyawan.firstName;
    }

    String name = user.firstName;
    if (user.lastName != null && user.lastName!.isNotEmpty) {
      name += " ${user.lastName}";
    }
    return name;
  }
}