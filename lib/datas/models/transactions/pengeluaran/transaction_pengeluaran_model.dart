import 'package:hive/hive.dart';
import '../../penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../penerimaan/penerimaan_setelah_pengisian/penerimaan_setelah_model.dart';
import '../../pengeluaran/pengeluaran_model.dart';

part 'transaction_pengeluaran_model.g.dart';

@HiveType(typeId: 31)
class TransactionPengeluaranModel extends HiveObject {
  @HiveField(0)
  String noBast;

  @HiveField(1)
  String status;

  @HiveField(2)
  String dateCreated;

  @HiveField(3)
  PenerimaanSebelumModel? dataSebelum;

  @HiveField(4)
  PenerimaanSetelahModel? dataSesudah;

  @HiveField(5)
  String? currentLevelApproval;

  @HiveField(6)
  int? currentStepApproval;

  @HiveField(7)
  PengeluaranModel? dataPengeluaran;

  TransactionPengeluaranModel({
    required this.noBast,
    required this.status,
    required this.dateCreated,
    this.dataSebelum,
    this.dataSesudah,
    this.currentLevelApproval,
    this.currentStepApproval,
    this.dataPengeluaran, // Tambahkan di constructor
  });
}