import 'package:hive/hive.dart';

part 'tangki_model.g.dart';

@HiveType(typeId: 17)
class TangkiModel extends HiveObject {
  @HiveField(0)
  String kodeTank;

  @HiveField(1)
  double? volumeTerkiniLiter; // Volume Sebelumnya

  @HiveField(2)
  double? tinggiTerkiniMM; // Tinggi Sebelumnya

  @HiveField(3)
  double? volumeAkhirLiter; // Volume Setelah

  @HiveField(4)
  double? tinggiAkhirMM; // Tinggi Setelah

  @HiveField(5)
  double? volumeVarLiter; // Volume Varian

  @HiveField(6)
  double? tinggiVarMM; // Tinggi Varian

  TangkiModel({
    required this.kodeTank,
    this.volumeTerkiniLiter,
    this.tinggiTerkiniMM,
    this.volumeAkhirLiter,
    this.tinggiAkhirMM,
    this.volumeVarLiter,
    this.tinggiVarMM,
  });

  Map<String, dynamic> toApiJson() {
    return {
      "kode_tank": kodeTank,
      "volume_terkini_liter": volumeTerkiniLiter ?? 0.0,
      "tinggi_terkini_cm": tinggiTerkiniMM ?? 0.0,
      "volume_akhir_liter": volumeAkhirLiter ?? 0.0,
      "tinggi_akhir_cm": tinggiAkhirMM ?? 0.0,
      "volume_var_liter": volumeVarLiter ?? 0.0,
      "tinggi_var_cm": tinggiVarMM ?? 0.0,
    };
  }
}