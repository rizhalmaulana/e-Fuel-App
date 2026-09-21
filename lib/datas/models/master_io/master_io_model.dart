class   MasterIoModel {
  String? internalOrder;
  String? costCenter;
  String? kodeUnit;
  String? namaUnit;
  String? description;
  String? noPolisi;
  String? idCard;
  String? rfId;
  String? statusUnit;
  String? tipeUnitIo;
  bool? isActive;

  MasterIoModel({
    this.internalOrder,
    this.costCenter,
    this.kodeUnit,
    this.namaUnit,
    this.description,
    this.noPolisi,
    this.idCard,
    this.rfId,
    this.statusUnit,
    this.tipeUnitIo,
    this.isActive
  });

  factory MasterIoModel.fromJson(Map<String, dynamic> json) {
    return MasterIoModel(
      internalOrder: json['internal_order'],
      costCenter: json['cost_center'],
      kodeUnit: json['kode_unit'],
      namaUnit: json['nama_unit'],
      description: json['deskripsi_unit'],
      noPolisi: json['no_polisi'],
      idCard: json['id_card'],
      rfId: json['rfid'],
      statusUnit: json['status_unit'],
      tipeUnitIo: json['tipe_unit_io'],
      isActive: json['is_active']
    );
  }
}