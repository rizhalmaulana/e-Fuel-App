class PengembalianSolarModel {
  final int id;
  final String noDoc;
  final String dateInbound;
  final String kodeUnit;
  final String namaUnit;
  final String statusInbound;
  final String tipeUnitIo;
  final String noIo;
  final String storageCode;
  final String storageName;
  final num liter;
  final num aktualLiter;
  final num varianLiter;
  final num aktualLiterTransfer;
  final num varianLiterTransfer;
  final num awalAktualLiter;
  final num awalVarianLiter;
  final String keterangan;
  final String satuan;
  final String foto1;
  final String foto2;
  final String foto3;
  final String createdBy;
  final String createdAt;

  PengembalianSolarModel({
    required this.id,
    required this.noDoc,
    required this.dateInbound,
    required this.kodeUnit,
    required this.namaUnit,
    required this.statusInbound,
    required this.tipeUnitIo,
    required this.noIo,
    required this.storageCode,
    required this.storageName,
    required this.liter,
    required this.aktualLiter,
    required this.varianLiter,
    required this.aktualLiterTransfer,
    required this.varianLiterTransfer,
    required this.awalAktualLiter,
    required this.awalVarianLiter,
    required this.keterangan,
    required this.satuan,
    required this.foto1,
    required this.foto2,
    required this.foto3,
    required this.createdBy,
    required this.createdAt,
  });

  factory PengembalianSolarModel.fromJson(Map<String, dynamic> json) {
    return PengembalianSolarModel(
      id: _parseNum(json['id'])?.toInt() ?? 0,
      noDoc: json['no_doc']?.toString() ?? '-',
      dateInbound: json['date_inbound']?.toString() ?? '-',
      kodeUnit: json['kode_unit']?.toString() ?? '-',
      namaUnit: json['nama_unit']?.toString() ?? '-',
      statusInbound: json['status_inbound']?.toString() ?? '-',
      tipeUnitIo: json['tipe_unit_io']?.toString() ?? '-',
      noIo: json['no_io']?.toString() ?? '-',
      storageCode: json['storage_code']?.toString() ?? '',
      storageName: json['storage_name']?.toString() ?? '',
      liter: _parseNum(json['estimasi_liter']) ?? _parseNum(json['liter']) ?? 0,
      aktualLiter: _parseNum(json['aktual_liter']) ?? 0,
      varianLiter: _parseNum(json['varian_liter']) ?? 0,
      aktualLiterTransfer: _parseNum(json['aktual_liter_transfer']) ?? _parseNum(json['aktual_liter_tf']) ?? _parseNum(json['aktual_liter']) ?? 0,
      varianLiterTransfer: _parseNum(json['varian_liter_transfer']) ?? _parseNum(json['varian_liter_tf']) ?? _parseNum(json['varian_liter']) ?? 0,
      awalAktualLiter: _parseNum(json['awal_aktual_liter']) ?? _parseNum(json['aktual_liter']) ?? 0,
      awalVarianLiter: _parseNum(json['awal_varian_liter']) ?? _parseNum(json['varian_liter']) ?? 0,
      keterangan: json['keterangan']?.toString() ?? '-',
      satuan: json['satuan']?.toString() ?? '',
      foto1: json['foto1']?.toString() ?? '',
      foto2: json['foto2']?.toString() ?? '',
      foto3: json['foto3']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '-',
      createdAt: json['created_at']?.toString() ?? '-',
    );
  }

  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}
