class ReportTransactionModel {
  int? id;
  String? noDoc;
  String? docType;
  String? docTypeName;
  String? dateInbound;
  String? kodeUnit;
  String? namaUnit;
  String? statusInbound;
  // Specific for FIN (Penerimaan)
  String? vendorSpb;
  int? volumeVendor;
  // Specific for FOT (Pengeluaran)
  String? unitIo;
  double? jumlahPengisianSolar;

  ReportTransactionModel({
    this.id,
    this.noDoc,
    this.docType,
    this.docTypeName,
    this.dateInbound,
    this.kodeUnit,
    this.namaUnit,
    this.statusInbound,
    this.vendorSpb,
    this.volumeVendor,
    this.unitIo,
    this.jumlahPengisianSolar,
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
      vendorSpb: json['vendor_spb'],

      volumeVendor: json['volume_vendor'] != null
          ? (json['volume_vendor'] as num).toInt()
          : null,

      unitIo: json['unit_io'],

      jumlahPengisianSolar: json['jumlah_pengisian_solar'] != null
          ? double.tryParse(json['jumlah_pengisian_solar'].toString())
          : null,
    );
  }
}