import 'package:hive/hive.dart';

part 'ukuran_standar_tangki_model.g.dart';

@HiveType(typeId: 19)
class UkuranStandarTangkiModel extends HiveObject {
  @HiveField(0)
  String kodeTank;

  @HiveField(1)
  double? stdLebarDiterima;

  @HiveField(2)
  double? volumeSolarDiterima;

  @HiveField(3)
  double? stdLebarTangkiKebun;

  @HiveField(4)
  double? stdPanjangDiterima;

  @HiveField(5)
  double? volumeTangkiPengirim;

  @HiveField(6)
  double? stdTinggiDiterima;

  @HiveField(7)
  double? stdPanjangTangkiKebun;

  @HiveField(8)
  double? stdTinggiTangkiKebun;

  @HiveField(9)
  double? varSolarTangki;

  UkuranStandarTangkiModel({
    required this.kodeTank,
    this.stdLebarDiterima,
    this.volumeSolarDiterima,
    this.stdLebarTangkiKebun,
    this.stdPanjangDiterima,
    this.volumeTangkiPengirim,
    this.stdTinggiDiterima,
    this.stdPanjangTangkiKebun,
    this.stdTinggiTangkiKebun,
    this.varSolarTangki,
  });

  Map<String, dynamic> toApiJson() {
    return {
      "kode_tank": kodeTank,
      "std_lebar_diterima": stdLebarDiterima ?? 0.0,
      "volume_solar_diterima": volumeSolarDiterima ?? 0.0,
      "std_lebar_tangki_kebun": stdLebarTangkiKebun ?? 0.0,
      "std_panjang_diterima": stdPanjangDiterima ?? 0.0,
      "volume_tangki_pengirim": volumeTangkiPengirim ?? 0.0,
      "std_tinggi_diterima": stdTinggiDiterima ?? 0.0,
      "std_panjang_tangki_kebun": stdPanjangTangkiKebun ?? 0.0,
      "std_tinggi_tangki_kebun": stdTinggiTangkiKebun ?? 0.0,
      "var_solar_tangki": varSolarTangki ?? 0.0,
    };
  }
}