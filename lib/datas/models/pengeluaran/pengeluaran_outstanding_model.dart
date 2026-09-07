class PengeluaranOutstandingModel {
  String? tanggalTransaksi;
  int? totalTransaksi;

  PengeluaranOutstandingModel({
    this.tanggalTransaksi,
    this.totalTransaksi,
  });

  factory PengeluaranOutstandingModel.fromJson(Map<String, dynamic> json) {
    return PengeluaranOutstandingModel(
      tanggalTransaksi: json['tanggal_transaksi'] as String?,
      totalTransaksi: json['total_transaksi'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal_transaksi': tanggalTransaksi,
      'total_transaksi': totalTransaksi,
    };
  }
}
