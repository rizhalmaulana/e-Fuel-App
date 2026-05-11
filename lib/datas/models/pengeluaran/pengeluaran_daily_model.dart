class PengeluaranDailyModel {
  int? id;
  String? noDoc;
  String? tipeTransaksi;
  String? namaUnit;
  String? noIo;
  double? liter;
  double? ratio;
  double? varian;
  String? dateInbound;
  String? namaSupir;
  double? aktualLiter;
  double? varianLiter;


  PengeluaranDailyModel({
    this.id,
    this.noDoc,
    this.tipeTransaksi,
    this.namaUnit,
    this.noIo,
    this.liter,
    this.ratio,
    this.varian,
    this.dateInbound,
    this.namaSupir,
    this.aktualLiter,
    this.varianLiter,
  });

  factory PengeluaranDailyModel.fromJson(Map<String, dynamic> json) {
    return PengeluaranDailyModel(
      id: json['id'],
      noDoc: json['no_doc'],
      tipeTransaksi: json['tipe_transaksi'],
      namaUnit: json['nama_unit'],
      noIo: json['no_io'],
      liter: (json['liter'] is int) ? (json['liter'] as int).toDouble() : json['liter'],
      ratio: (json['ratio'] is int) ? (json['ratio'] as int).toDouble() : json['ratio'],
      varian: (json['varian'] is int) ? (json['varian'] as int).toDouble() : json['varian'],
      dateInbound: json['date_inbound'],
      namaSupir: json['nama_supir'],
      aktualLiter: (json['aktual_liter'] is int) ? (json['aktual_liter'] as int).toDouble() : json['aktual_liter'],
      varianLiter: (json['varian_liter'] is int) ? (json['varian_liter'] as int).toDouble() : json['varian_liter'],
    );
  }
}