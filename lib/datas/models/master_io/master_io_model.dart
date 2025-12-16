class MasterIoModel {
  String? internalOrder;
  String? namaUnit;
  String? description;
  String? noPolisi;

  MasterIoModel({
    this.internalOrder,
    this.namaUnit,
    this.description,
    this.noPolisi
  });

  factory MasterIoModel.fromJson(Map<String, dynamic> json) {
    return MasterIoModel(
      internalOrder: json['internal_order'],
      namaUnit: json['nama_unit'],
      description: json['deskripsi_unit'],
      noPolisi: json['no_polisi'],
    );
  }
}