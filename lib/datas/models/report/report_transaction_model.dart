class ReportTransactionModel {
  int? id;
  String? noDoc;
  String? docType;
  String? docTypeName;
  String? dateInbound;
  String? kodeUnit;
  String? namaUnit;
  String? statusInbound;

  // FIN (Penerimaan) Fields dari API Response
  String? storageCode;
  String? storageName;
  String? noPo;
  int? volumeVendor;
  String? vendorSpb;
  String? nopolVendor;
  String? supirVendor;

  // FOT (Pengeluaran) Fields
  String? unitIo;
  double? jumlahPengisianSolar;
  double? estimasiPengisianSolar;
  double? aktualPengisianSolar;
  String? nopolCheck;
  String? supirCheck;

  ReportTransactionModel({
    this.id,
    this.noDoc,
    this.docType,
    this.docTypeName,
    this.dateInbound,
    this.kodeUnit,
    this.namaUnit,
    this.statusInbound,
    this.storageCode,
    this.storageName,
    this.noPo,
    this.volumeVendor,
    this.vendorSpb,
    this.nopolVendor,
    this.supirVendor,
    this.unitIo,
    this.jumlahPengisianSolar,
    this.estimasiPengisianSolar,
    this.aktualPengisianSolar,
    this.nopolCheck,
    this.supirCheck,
  });

  factory ReportTransactionModel.fromJson(Map<String, dynamic> json) {
    return ReportTransactionModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      noDoc: json['no_doc'],
      docType: json['doc_type'],
      docTypeName: json['doc_type_name'],
      dateInbound: json['date_inbound'],
      kodeUnit: json['kode_unit'],
      namaUnit: json['nama_unit'],
      statusInbound: json['status_inbound'],
      storageCode: json['storage_code'],
      storageName: json['storage_name'],
      noPo: json['no_po'],
      vendorSpb: json['vendor_spb'],
      nopolVendor: json['nopol_vendor'],
      supirVendor: json['supir_vendor'],
      volumeVendor: json['volume_vendor'] != null ? (json['volume_vendor'] as num).toInt() : null,
      unitIo: json['unit_io'],
      jumlahPengisianSolar: json['jumlah_pengisian_solar'] != null
          ? double.tryParse(json['jumlah_pengisian_solar'].toString())
          : null,
      estimasiPengisianSolar: json['estimasi_pengisian_solar'] != null
          ? double.tryParse(json['estimasi_pengisian_solar'].toString())
          : null,
      aktualPengisianSolar: json['aktual_pengisian_solar'] != null
          ? double.tryParse(json['aktual_pengisian_solar'].toString())
          : null,
      nopolCheck: json['nopol_check'],
      supirCheck: json['supir_check'],
    );
  }
}