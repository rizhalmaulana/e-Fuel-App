class PengembalianSolarModel {
  final int id;
  final String noDoc;
  final String dateInbound;
  final String kodeUnit;
  final String namaUnit;
  final String statusInbound;
  final String tipeUnitIo;
  final String noIo;
  final num liter;
  final num aktualLiter;
  final num varianLiter;
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
    required this.liter,
    required this.aktualLiter,
    required this.varianLiter,
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
      id: (json['id'] as num?)?.toInt() ?? 0,
      noDoc: json['no_doc'] as String? ?? '-',
      dateInbound: json['date_inbound'] as String? ?? '-',
      kodeUnit: json['kode_unit'] as String? ?? '-',
      namaUnit: json['nama_unit'] as String? ?? '-',
      statusInbound: json['status_inbound'] as String? ?? '-',
      tipeUnitIo: json['tipe_unit_io'] as String? ?? '-',
      noIo: json['no_io'] as String? ?? '-',
      liter: json['liter'] as num? ?? 0,
      aktualLiter: json['aktual_liter'] as num? ?? 0,
      varianLiter: json['varian_liter'] as num? ?? 0,
      keterangan: json['keterangan'] as String? ?? '-',
      satuan: json['satuan'] as String? ?? '',
      foto1: json['foto1'] as String? ?? '',
      foto2: json['foto2'] as String? ?? '',
      foto3: json['foto3'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '-',
      createdAt: json['created_at'] as String? ?? '-',
    );
  }
}
