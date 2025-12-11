import '../../penerimaan/penerimaan_setelah_pengisian/penerimaan_setelah_model.dart';
import '../../penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 20)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String noBast;

  @HiveField(1)
  String status; // 'proses', 'pengisian_solar', 'setelah_pengisian', 'verifikasi_bast', 'approval', 'selesai'

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

  TransactionModel({
    required this.noBast,
    required this.status,
    required this.dateCreated,
    this.dataSebelum,
    this.dataSesudah,
    this.currentLevelApproval,
    this.currentStepApproval,
  });
}