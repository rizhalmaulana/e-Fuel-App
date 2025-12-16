import 'package:hive/hive.dart';

part 'iot_tangki_model.g.dart';

@HiveType(typeId: 18)
class IotTangkiModel extends HiveObject {
  @HiveField(0)
  String kodeTank;

  @HiveField(1)
  double? iotVolumeTerkiniLiter; // Volume Sebelumnya

  @HiveField(2)
  double? iotTinggiTerkiniMM; // Tinggi Sebelumnya

  @HiveField(3)
  double? iotVolumeAkhirLiter; // Volume Setelah

  @HiveField(4)
  double? iotTinggiAkhirMM; // Tinggi Setelah

  @HiveField(5)
  double? iotVolumeVarLiter; // Volume Varian

  @HiveField(6)
  double? iotTinggiVarMM; // Tinggi Varian

  IotTangkiModel({
    required this.kodeTank,
    this.iotVolumeTerkiniLiter,
    this.iotTinggiTerkiniMM,
    this.iotVolumeAkhirLiter,
    this.iotTinggiAkhirMM,
    this.iotVolumeVarLiter,
    this.iotTinggiVarMM,
  });

  Map<String, dynamic> toApiJson() {
    return {
      "kode_tank": kodeTank,
      "iot_volume_terkini_liter": iotVolumeTerkiniLiter ?? 0.0,
      "iot_tinggi_terkini_cm": iotTinggiTerkiniMM ?? 0.0,
      "iot_volume_akhir_liter": iotVolumeAkhirLiter ?? 0.0,
      "iot_tinggi_akhir_cm": iotTinggiAkhirMM ?? 0.0,
      "iot_volume_var_liter": iotVolumeVarLiter ?? 0.0,
      "iot_tinggi_var_cm": iotTinggiVarMM ?? 0.0,
    };
  }
}