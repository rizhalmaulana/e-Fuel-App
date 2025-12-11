import 'package:hive/hive.dart';

part 'tangki_model.g.dart';

@HiveType(typeId: 17)
class TangkiModel extends HiveObject {
  @HiveField(0)
  String kodeTank;

  @HiveField(1)
  double? volumeTerkiniLiter; // Volume Sebelumnya

  @HiveField(2)
  double? tinggiTerkiniCm; // Tinggi Sebelumnya

  @HiveField(3)
  double? volumeAkhirLiter; // Volume Setelah

  @HiveField(4)
  double? tinggiAkhirCm; // Tinggi Setelah

  @HiveField(5)
  double? volumeVarLiter; // Volume Varian

  @HiveField(6)
  double? tinggiVarCm; // Tinggi Varian

  TangkiModel({
    required this.kodeTank,
    this.volumeTerkiniLiter,
    this.tinggiTerkiniCm,
    this.volumeAkhirLiter,
    this.tinggiAkhirCm,
    this.volumeVarLiter,
    this.tinggiVarCm,
  });

  Map<String, dynamic> toApiJson() {
    return {
      "kode_tank": kodeTank,
      "volume_terkini_liter": volumeTerkiniLiter ?? 0.0,
      "tinggi_terkini_cm": tinggiTerkiniCm ?? 0.0,
      "volume_akhir_liter": volumeAkhirLiter ?? 0.0,
      "tinggi_akhir_cm": tinggiAkhirCm ?? 0.0,
      "volume_var_liter": volumeVarLiter ?? 0.0,
      "tinggi_var_cm": tinggiVarCm ?? 0.0,
    };
  }
}