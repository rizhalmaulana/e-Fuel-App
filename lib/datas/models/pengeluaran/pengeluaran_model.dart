import 'package:hive/hive.dart';

part 'pengeluaran_model.g.dart';

@HiveType(typeId: 30)
class PengeluaranModel extends HiveObject {
  @HiveField(0)
  String? noDoc;

  @HiveField(1)
  String? noIo;

  @HiveField(2)
  String? nopolCheck;

  @HiveField(3)
  String? statusSupir;

  @HiveField(4)
  String? supirCheck;

  @HiveField(5)
  double? kmPengisian;

  @HiveField(6)
  double? jumlahPengisianSolar;

  @HiveField(7)
  String? unitIO;

  @HiveField(8)
  String? userName;

  @HiveField(9)
  String? dateOutbound;

  @HiveField(10)
  String? pathFoto1;

  @HiveField(11)
  String? pathFoto2;

  @HiveField(12)
  String? pathFoto3;

  @HiveField(13)
  String? keterangan;

  @HiveField(14)
  String? docType;

  @HiveField(15)
  double? hmKmAkhi;

  @HiveField(16)
  double? liter;

  @HiveField(17)
  double? hmKmAwak;

  @HiveField(18)
  String? costCenter;

  @HiveField(19)
  double? ratio;

  @HiveField(20)
  String? tipeUnitIo;

  @HiveField(21)
  double? varian;

  @HiveField(22)
  String? tanggalAkhir;

  @HiveField(23)
  String? tanggalAwal;

  @HiveField(24)
  String? satuan;

  PengeluaranModel({
    this.noDoc,
    this.noIo,
    this.nopolCheck,
    this.statusSupir,
    this.supirCheck,
    this.kmPengisian,
    this.jumlahPengisianSolar,
    this.unitIO,
    this.userName,
    this.dateOutbound,
    this.pathFoto1,
    this.pathFoto2,
    this.pathFoto3,
    this.keterangan,
    this.docType,
    this.hmKmAkhi,
    this.liter,
    this.hmKmAwak,
    this.costCenter,
    this.ratio,
    this.tipeUnitIo,
    this.varian,
    this.tanggalAkhir,
    this.tanggalAwal,
    this.satuan,
  });
}