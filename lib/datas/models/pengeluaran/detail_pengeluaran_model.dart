class DetailPengeluaranModel {
  final String noDoc;
  final String docType;
  final String docTypeName;
  final String kodeUnit;
  final String namaUnit;
  final String storageCode;
  final String storageName;
  final String dateInbound;
  final int yearInbound;
  final int monthInbound;
  final String statusInbound;
  final String? dtimeBefore;
  final String? dtimeAfter;
  final String? nopolCheck;
  final String? supirCheck;
  final String? createdBy;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? noIo;
  final double hmKmAwal;
  final double hmKmAkhir;
  final double varianHmKmAwal;
  final double ratioInput;
  final double estimasiLiter;
  final double aktualLiter;
  final double varianLiter;
  final String costCenter;
  final String keterangan;
  final String inputType;
  final double selisihVolTera;

  DetailPengeluaranModel({
    required this.noDoc,
    required this.docType,
    required this.docTypeName,
    required this.kodeUnit,
    required this.namaUnit,
    required this.storageCode,
    required this.storageName,
    required this.dateInbound,
    required this.yearInbound,
    required this.monthInbound,
    required this.statusInbound,
    this.dtimeBefore,
    this.dtimeAfter,
    this.nopolCheck,
    this.supirCheck,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.noIo,
    required this.hmKmAwal,
    required this.hmKmAkhir,
    required this.varianHmKmAwal,
    required this.ratioInput,
    required this.estimasiLiter,
    required this.aktualLiter,
    required this.varianLiter,
    required this.costCenter,
    required this.keterangan,
    required this.inputType,
    required this.selisihVolTera,
  });

  factory DetailPengeluaranModel.fromJson(Map<String, dynamic> json) {
    return DetailPengeluaranModel(
      noDoc: json['no_doc']?.toString() ?? '',
      docType: json['doc_type']?.toString() ?? '',
      docTypeName: json['doc_type_name']?.toString() ?? '',
      kodeUnit: json['kode_unit']?.toString() ?? '',
      namaUnit: json['nama_unit']?.toString() ?? '',
      storageCode: json['storage_code']?.toString() ?? '',
      storageName: json['storage_name']?.toString() ?? '',
      dateInbound: json['date_inbound']?.toString() ?? '',
      yearInbound: json['year_inbound'] as int? ?? 0,
      monthInbound: json['month_inbound'] as int? ?? 0,
      statusInbound: json['status_inbound']?.toString() ?? '',
      dtimeBefore: json['dtime_before']?.toString(),
      dtimeAfter: json['dtime_after']?.toString(),
      nopolCheck: json['nopol_check']?.toString(),
      supirCheck: json['supir_check']?.toString(),
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      noIo: json['no_io']?.toString(),
      hmKmAwal: _toDouble(json['hm_km_awal']),
      hmKmAkhir: _toDouble(json['hm_km_akhir']),
      varianHmKmAwal: _toDouble(json['varian_hm_km_awal']),
      ratioInput: _toDouble(json['ratio_input']),
      estimasiLiter: _toDouble(json['estimasi_liter']),
      aktualLiter: _toDouble(json['aktual_liter']),
      varianLiter: _toDouble(json['varian_liter']),
      costCenter: json['cost_center']?.toString() ?? '-',
      keterangan: json['keterangan']?.toString() ?? '',
      inputType: json['input_type']?.toString() ?? 'Auto',
      selisihVolTera: _toDouble(json['selisih_vol_tera']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'no_doc': noDoc,
      'doc_type': docType,
      'doc_type_name': docTypeName,
      'kode_unit': kodeUnit,
      'nama_unit': namaUnit,
      'storage_code': storageCode,
      'storage_name': storageName,
      'date_inbound': dateInbound,
      'year_inbound': yearInbound,
      'month_inbound': monthInbound,
      'status_inbound': statusInbound,
      'dtime_before': dtimeBefore,
      'dtime_after': dtimeAfter,
      'nopol_check': nopolCheck,
      'supir_check': supirCheck,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'no_io': noIo,
      'hm_km_awal': hmKmAwal,
      'hm_km_akhir': hmKmAkhir,
      'varian_hm_km_awal': varianHmKmAwal,
      'ratio_input': ratioInput,
      'estimasi_liter': estimasiLiter,
      'aktual_liter': aktualLiter,
      'varian_liter': varianLiter,
      'cost_center': costCenter,
      'keterangan': keterangan,
      'input_type': inputType,
      'selisih_vol_tera': selisihVolTera,
    };
  }
}
