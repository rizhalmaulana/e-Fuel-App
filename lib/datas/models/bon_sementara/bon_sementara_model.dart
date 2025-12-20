class BonSementaraModel {
  int? no;
  String? internalOrder;
  String? namaUnit;
  String? deskripsiUnit;
  String? noPolisi;
  String? ket;
  String? tipe;
  String? satuan;
  String? opr;
  String? opl;
  dynamic hmKmAwal;
  dynamic hmKmAkhir;
  String? dateAwal;
  String? dateAkhir;
  String? ratio;
  double? liter;

  BonSementaraModel({
    this.no,
    this.internalOrder,
    this.namaUnit,
    this.deskripsiUnit,
    this.noPolisi,
    this.ket,
    this.tipe,
    this.satuan,
    this.opr,
    this.opl,
    this.hmKmAwal,
    this.hmKmAkhir,
    this.dateAwal,
    this.dateAkhir,
    this.ratio,
    this.liter,
  });

  factory BonSementaraModel.fromJson(Map<String, dynamic> json) {
    return BonSementaraModel(
      no: json['No'],
      internalOrder: json['Internal Order'],
      namaUnit: json['Nama Unit'],
      deskripsiUnit: json['Deskripsi Unit'],
      noPolisi: json['No Polisi'],
      ket: json['Ket']?.toString(),
      tipe: json['Tipe'],
      satuan: json['Satuan'],
      opr: json['OPR'],
      opl: json['OPL']?.toString(),
      hmKmAwal: json['HM/KM Awal'],
      hmKmAkhir: json['HM/KM Akhir'],
      dateAwal: json['Date Awal'] ?? json['DateAwal'],
      dateAkhir: json['Date Akhir'] ?? json['DateAkhir'],
      ratio: json['Ratio']?.toString(),
      liter: (json['Liter'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'No': no,
    'Internal Order': internalOrder,
    'Nama Unit': namaUnit,
    'Deskripsi Unit': deskripsiUnit,
    'No Polisi': noPolisi,
    'Ket': ket,
    'Tipe': tipe,
    'Satuan': satuan,
    'OPR': opr,
    'OPL': opl,
    'HM/KM Awal': hmKmAwal,
    'HM/KM Akhir': hmKmAkhir,
    'Date Awal': dateAwal,
    'Date Akhir': dateAkhir,
    'Ratio': ratio,
    'Liter': liter,
  };

  double get hmKmDiff {
    if (hmKmAkhir == null || hmKmAwal == null) return 0;
    double awal = double.tryParse(hmKmAwal.toString()) ?? 0;
    double akhir = double.tryParse(hmKmAkhir.toString()) ?? 0;
    return (akhir - awal) > 0 ? (akhir - awal) : 0;
  }

  int get dateDiff {
    if (dateAwal == null || dateAkhir == null) return 0;
    try {
      DateTime start = DateTime.parse(dateAwal!);
      DateTime end = DateTime.parse(dateAkhir!);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }
}