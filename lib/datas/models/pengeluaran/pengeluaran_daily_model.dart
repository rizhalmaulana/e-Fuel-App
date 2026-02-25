class PengeluaranDailyModel {
  int? id;
  String? namaUnit;
  double? liter;
  double? ratio;
  double? varian;
  String? dateInbound;
  String? noIo;
  double? aktualLiter;
  double? varianLiter;

  PengeluaranDailyModel({
    this.id,
    this.namaUnit,
    this.liter,
    this.ratio,
    this.varian,
    this.dateInbound,
    this.noIo,
    this.aktualLiter,
    this.varianLiter
  });

  factory PengeluaranDailyModel.fromJson(Map<String, dynamic> json) {
    return PengeluaranDailyModel(
      id: json['id'],
      namaUnit: json['nama_unit'],
      liter: (json['liter'] is int) ? (json['liter'] as int).toDouble() : json['liter'],
      ratio: (json['ratio'] is int) ? (json['ratio'] as int).toDouble() : json['ratio'],
      varian: (json['varian'] is int) ? (json['varian'] as int).toDouble() : json['varian'],
      dateInbound: json['date_inbound'],
      noIo: json['no_io'],
      aktualLiter: (json['aktual_liter'] is int) ? (json['aktual_liter'] as int).toDouble() : json['aktual_liter'],
      varianLiter: (json['varian_liter'] is int) ? (json['varian_liter'] as int).toDouble() : json['varian_liter'],
    );
  }
}