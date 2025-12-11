import 'package:hive/hive.dart';

part 'penerimaan_sebelum_model.g.dart';

@HiveType(typeId: 14)
class PenerimaanSebelumModel extends HiveObject {
  @HiveField(0)
  String userName;

  @HiveField(1)
  String? status; // 'proses', 'setelah_pengisian', 'approval', 'selesai'

  @HiveField(2)
  String? supirCheck;

  @HiveField(3)
  String? segelKondisi;

  @HiveField(4)
  String? tangkiPeka;

  @HiveField(5)
  String? segelTangkiBawah;

  @HiveField(6)
  String? dateInbound;

  @HiveField(7)
  String? docTypeCode; // FIN (Penerimaan) dan FOT (Pengeluaran)

  @HiveField(8)
  double? volumeVendor;

  @HiveField(9)
  String? dtimeBefore;

  @HiveField(10)
  String? purchNo;

  @HiveField(11)
  String? dtimeAfter;

  @HiveField(12)
  String? vendorSpb;

  @HiveField(13)
  String? supirVendor;

  @HiveField(14)
  String? storageCode;

  @HiveField(15)
  double? densityCheck;

  @HiveField(16)
  double? kapasitasCheck;

  @HiveField(17)
  double? tempVendor;

  @HiveField(18)
  String? nopolCheck;

  @HiveField(19)
  double? terraVendor;

  @HiveField(20)
  double? terraVar;

  @HiveField(21)
  double? terraCheck;

  @HiveField(22)
  double? volumeTerkiniLiter;

  @HiveField(23)
  String? nopolVendor;

  @HiveField(24)
  double? tempCheck;

  @HiveField(25)
  String? segelTangkiAtas;

  @HiveField(26)
  String? kodeUnit;

  @HiveField(27)
  double? kapasitasVendor;

  @HiveField(28)
  double? tinggiTerkiniCm;

  @HiveField(29)
  double? densityVendor;

  @HiveField(30)
  String? pathFotoDoc;

  @HiveField(31)
  String? pathFotoDepan;

  @HiveField(32)
  String? pathFotoSamping;

  @HiveField(33)
  bool isSynced;

  @HiveField(34)
  String? noDocBast;

  @HiveField(35)
  String? manualTankDetailsJson;

  @HiveField(36)
  String? iotTankDetailsJson;

  @HiveField(37)
  double? totalVolumeManual;

  @HiveField(38)
  double? totalVolumeIot;

  PenerimaanSebelumModel({
    required this.userName,
    this.status = 'proses',
    this.supirCheck,
    this.segelKondisi,
    this.tangkiPeka,
    this.segelTangkiBawah,
    this.dateInbound,
    this.docTypeCode,
    this.volumeVendor,
    this.dtimeBefore,
    this.purchNo,
    this.dtimeAfter,
    this.vendorSpb,
    this.supirVendor,
    this.storageCode,
    this.densityCheck,
    this.kapasitasCheck,
    this.tempVendor,
    this.nopolCheck,
    this.terraVendor,
    this.terraVar,
    this.terraCheck,
    this.volumeTerkiniLiter,
    this.nopolVendor,
    this.tempCheck,
    this.segelTangkiAtas,
    this.kodeUnit,
    this.kapasitasVendor,
    this.tinggiTerkiniCm,
    this.densityVendor,
    this.pathFotoDoc,
    this.pathFotoDepan,
    this.pathFotoSamping,
    this.isSynced = false,
    this.noDocBast,
    this.manualTankDetailsJson,
    this.iotTankDetailsJson,
    this.totalVolumeManual,
    this.totalVolumeIot,
  });

  // Method convert ke JSON untuk API
  Map<String, dynamic> toApiJson() {
    return {
      "status": status,
      "supir_check": supirCheck ?? "",
      "segel_kondisi": segelKondisi ?? "",
      "tangki_peka": tangkiPeka ?? "0",
      "segel_tangki_bawah": segelTangkiBawah ?? "",
      "date_inbound": dateInbound ?? "",
      "doc_type_code": docTypeCode ?? "SPB",
      "volume_vendor": volumeVendor ?? 0.0,
      "dtime_before": dtimeBefore ?? DateTime.now().toIso8601String(),
      "purch_no": purchNo ?? "",
      "dtime_after": dtimeAfter ?? DateTime.now().toIso8601String(),
      "vendor_spb": vendorSpb ?? "",
      "supir_vendor": supirVendor ?? "",
      "storage_code": storageCode ?? "",
      "density_check": densityCheck ?? 0.0,
      "kapasitas_check": kapasitasCheck ?? 0.0,
      "temp_vendor": tempVendor ?? 0.0,
      "nopol_check": nopolCheck ?? "",
      "terra_vendor": terraVendor ?? 0.0,
      "terra_var": terraVar ?? 0.0,
      "terra_check": terraCheck ?? 0.0,
      "volume_terkini_liter": volumeTerkiniLiter ?? 0.0,
      "nopol_vendor": nopolVendor ?? "",
      "temp_check": tempCheck ?? 0.0,
      "segel_tangki_atas": segelTangkiAtas ?? "",
      "kode_unit": kodeUnit ?? "",
      "kapasitas_vendor": kapasitasVendor ?? 0.0,
      "tinggi_terkini_cm": tinggiTerkiniCm ?? 0.0,
      "density_vendor": densityVendor ?? 0.0,
    };
  }
}