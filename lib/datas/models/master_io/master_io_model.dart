class MasterIoModel {
  String? internalOrder;
  String? kodeUnit;
  String? namaUnit;
  String? description;
  String? noPolisi;
  String? idCard;
  String? rfId;
  String? statusUnit;
  bool isActive;

  MasterIoModel({
    this.internalOrder,
    this.kodeUnit,
    this.namaUnit,
    this.description,
    this.noPolisi,
    this.idCard,
    this.rfId,
    this.statusUnit,
    required this.isActive
  });

  factory MasterIoModel.fromJson(Map<String, dynamic> json) {
    return MasterIoModel(
      internalOrder: json['internal_order'],
      kodeUnit: json['kode_unit'],
      namaUnit: json['nama_unit'],
      description: json['deskripsi_unit'],
      noPolisi: json['no_polisi'],
      idCard: json['id_card'],
      rfId: json['rfid'],
      statusUnit: json['status_unit'],
      isActive: json['is_active']
    );
  }
}