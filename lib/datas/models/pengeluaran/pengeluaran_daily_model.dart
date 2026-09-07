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
  String? kategoriKendaraan;
  String? costCenter;
  double? aktualLiter;
  double? varianLiter;
  bool? hasBackdate;

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
    this.kategoriKendaraan,
    this.costCenter,
    this.aktualLiter,
    this.varianLiter,
    this.hasBackdate,
  });

  factory PengeluaranDailyModel.fromJson(Map<String, dynamic> json) {
    return PengeluaranDailyModel(
      id: json['id'],
      noDoc: json['no_doc'],
      tipeTransaksi: json['tipe_transaksi'],
      namaUnit: json['nama_unit'],
      noIo: json['no_io'],
      liter: _parseDouble(json['estimasi_liter'] ?? json['liter']),
      ratio: _parseDouble(json['ratio']),
      varian: _parseDouble(json['varian']),
      dateInbound: json['tanggal_transaksi'] ?? json['date_inbound'],
      namaSupir: json['nama_supir'],
      kategoriKendaraan: json['kategori_kendaraan'],
      costCenter: json['cost_center'],
      aktualLiter: _parseDouble(json['aktual_liter']),
      varianLiter: _parseDouble(json['varian_liter']),
      hasBackdate: json['has_backdate'] as bool?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }
}