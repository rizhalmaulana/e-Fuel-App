import 'package:hive/hive.dart';

part 'tangki_model.g.dart';

@HiveType(typeId: 17)
class TangkiModel extends HiveObject {
  @HiveField(0)
  String kodeTank;

  @HiveField(1)
  double? volumeTerkiniLiter; // Volume Sebelumnya

  @HiveField(2)
  double? tinggiTerkiniCM; // Tinggi Sebelumnya

  @HiveField(3)
  double? volumeAkhirLiter; // Volume Setelah

  @HiveField(4)
  double? tinggiAkhirCM; // Tinggi Setelah

  @HiveField(5)
  double? volumeVarLiter; // Volume Varian

  @HiveField(6)
  double? tinggiVarCM; // Tinggi Varian

  @HiveField(7)
  String? namaTank; // Tinggi Varian

  TangkiModel({
    required this.kodeTank,
    this.volumeTerkiniLiter,
    this.tinggiTerkiniCM,
    this.volumeAkhirLiter,
    this.tinggiAkhirCM,
    this.volumeVarLiter,
    this.tinggiVarCM,
    this.namaTank,
  });

  Map<String, dynamic> toApiJson() {
    return {
      "kode_tank": kodeTank,
      "volume_terkini_liter": volumeTerkiniLiter ?? 0.0,
      "tinggi_terkini_cm": tinggiTerkiniCM ?? 0.0,
      "volume_akhir_liter": volumeAkhirLiter ?? 0.0,
      "tinggi_akhir_cm": tinggiAkhirCM ?? 0.0,
      "volume_var_liter": volumeVarLiter ?? 0.0,
      "tinggi_var_cm": tinggiVarCM ?? 0.0,
      "nama_tank": namaTank
    };
  }

  factory TangkiModel.fromJson(Map<String, dynamic> json) {
    return TangkiModel(
      kodeTank: json['kode_tank'],
      namaTank: json['nama_tank'],
      volumeTerkiniLiter: json['volume_terkini_liter'],
      tinggiTerkiniCM: json['tinggi_terkini_cm'],
      volumeAkhirLiter: json['volume_akhir_liter'],
      tinggiAkhirCM: json['tinggi_akhir_cm'],
      tinggiVarCM: json['tinggi_var_cm'],
      volumeVarLiter: json['volume_var_liter'],
    );
  }
}