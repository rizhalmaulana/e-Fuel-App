import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transfer_solar_model.g.dart';

@HiveType(typeId: 36)
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class TransferSolarModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String noDoc;

  @HiveField(2)
  final String kodeUnit;

  @HiveField(3)
  final String namaUnit;

  @HiveField(23)
  final String? titleUnit;

  @HiveField(4)
  final String noIo;

  @HiveField(5)
  final num aktualLiter; // This maps to 'liter' in payload

  @HiveField(6)
  final String dateInbound;

  @HiveField(7)
  final String statusInbound;

  @HiveField(8)
  final String tipeUnitIo;

  @HiveField(9)
  final String nopolCheck;

  @HiveField(10)
  String supirCheck;

  @HiveField(11)
  final num? varian; // This maps to 'varian' in payload

  // Fields below are populated locally during offline transfer process

  @HiveField(12)
  num? inputAktualLiter; // Maps to 'aktual_liter' in payload

  @HiveField(13)
  num? inputVarianLiter; // Calculated, maps to 'varian_liter' in payload

  @HiveField(14)
  String? foto1Path; // Foto Odometer

  @HiveField(15)
  String? foto2Path; // Foto Alat Berat

  @HiveField(16)
  String? foto3Path; // Foto Operator

  @HiveField(17)
  bool isOfflineSubmitted;

  @HiveField(18)
  final String? satuan;

  @HiveField(19)
  num? hmKmAwal;

  @HiveField(20)
  num? hmKmAkhir;

  @HiveField(21)
  num? ratio;

  @HiveField(22)
  num? jumlahPengisianSolar;

  TransferSolarModel({
    required this.id,
    required this.noDoc,
    required this.kodeUnit,
    required this.namaUnit,
    required this.noIo,
    required this.aktualLiter,
    required this.dateInbound,
    required this.statusInbound,
    required this.tipeUnitIo,
    required this.nopolCheck,
    required this.supirCheck,
    this.titleUnit,
    this.varian,
    this.inputAktualLiter,
    this.inputVarianLiter,
    this.foto1Path,
    this.foto2Path,
    this.foto3Path,
    this.isOfflineSubmitted = false,
    this.satuan,
    this.hmKmAwal,
    this.hmKmAkhir,
    this.ratio,
    this.jumlahPengisianSolar,
  });

  factory TransferSolarModel.fromJson(Map<String, dynamic> json) {
    return TransferSolarModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      noDoc: json['no_doc'] as String? ?? '-',
      kodeUnit: json['kode_unit'] as String? ?? '-',
      namaUnit: json['nama_unit'] as String? ?? '-',
      titleUnit: json['title_unit'] as String?,
      noIo: json['no_io'] as String? ?? '-',
      aktualLiter: json['aktual_liter'] as num? ?? json['liter'] as num? ?? 0,
      dateInbound: json['date_inbound'] as String? ?? '-',
      statusInbound: json['status_inbound'] as String? ?? '-',
      tipeUnitIo: json['tipe_unit_io'] as String? ?? '-',
      nopolCheck: json['nopol_check'] as String? ?? '-',
      supirCheck: json['supir_check'] as String? ?? '-',
      varian: json['varian_liter'] as num? ?? json['varian'] as num?,
      inputAktualLiter: json['input_aktual_liter'] as num?,
      inputVarianLiter: json['input_varian_liter'] as num?,
      foto1Path: json['foto1_path'] as String?,
      foto2Path: json['foto2_path'] as String?,
      foto3Path: json['foto3_path'] as String?,
      isOfflineSubmitted: json['is_offline_submitted'] as bool? ?? false,
      satuan: json['satuan'] as String?,
      hmKmAwal: json['hm_km_awal'] as num?,
      hmKmAkhir: json['hm_km_akhir'] as num?,
      ratio: json['ratio_input'] as num? ?? json['ratio'] as num?,
      jumlahPengisianSolar: json['estimasi_liter'] as num? ?? json['liter'] as num? ?? json['jumlah_pengisian_solar'] as num?,
    );
  }

  Map<String, dynamic> toJson() => _$TransferSolarModelToJson(this);
}
