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

  // Path foto lokal (Opsional, jika ingin ditampilkan di history/detail)
  @HiveField(10)
  String? pathFoto1;

  @HiveField(11)
  String? pathFoto2;

  @HiveField(12)
  String? pathFoto3;

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
  });
}