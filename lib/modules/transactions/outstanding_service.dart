import 'package:hive/hive.dart';

import '../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';

class OutstandingService {
  final String userId;
  OutstandingService(this.userId);

  String get _boxNamePenerimaan => 'outstanding_transactions_$userId';
  String get _boxNamePengeluaran => 'outstanding_pengeluaran_$userId';

  // ===========================================================================
  // REGION: BOX OPENERS
  // ===========================================================================

  Future<Box<TransactionModel>> _getBoxPenerimaan() async {
    if (!Hive.isBoxOpen(_boxNamePenerimaan)) {
      return await Hive.openBox<TransactionModel>(_boxNamePenerimaan);
    }
    return Hive.box<TransactionModel>(_boxNamePenerimaan);
  }

  Future<Box<TransactionPengeluaranModel>> _getBoxPengeluaran() async {
    if (!Hive.isBoxOpen(_boxNamePengeluaran)) {
      return await Hive.openBox<TransactionPengeluaranModel>(_boxNamePengeluaran);
    }
    return Hive.box<TransactionPengeluaranModel>(_boxNamePengeluaran);
  }

  // ===========================================================================
  // REGION: GET ALL (COMBINED FOR HOME)
  // ===========================================================================

  Future<List<dynamic>> getAllCombinedTransactions() async {
    final boxPenerimaan = await _getBoxPenerimaan();
    final boxPengeluaran = await _getBoxPengeluaran();

    List<dynamic> allTransactions = [];

    // 1. Ambil Data Penerimaan
    allTransactions.addAll(boxPenerimaan.values.toList());

    // 2. Ambil Data Pengeluaran
    allTransactions.addAll(boxPengeluaran.values.toList());

    allTransactions.sort((a, b) {
      String dateStrA = "";
      String dateStrB = "";

      if (a is TransactionModel) dateStrA = a.dateCreated;
      if (a is TransactionPengeluaranModel) dateStrA = a.dateCreated;

      if (b is TransactionModel) dateStrB = b.dateCreated;
      if (b is TransactionPengeluaranModel) dateStrB = b.dateCreated;

      DateTime dateA = DateTime.tryParse(dateStrA) ?? DateTime.now();
      DateTime dateB = DateTime.tryParse(dateStrB) ?? DateTime.now();

      return dateB.compareTo(dateA);
    });

    return allTransactions;
  }

  // ===========================================================================
  // REGION: PENERIMAAN (EXISTING)
  // ===========================================================================

  Future<TransactionModel?> getTransactionByNoBast(String noBast) async {
    final box = await _getBoxPenerimaan();
    if (box.containsKey(noBast)) return box.get(noBast);
    try {
      return box.values.firstWhere((item) => item.noBast == noBast);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveTransaction(TransactionModel data) async {
    final box = await _getBoxPenerimaan();
    await box.put(data.noBast, data);
  }

  Future<void> updateStatus(String noBast, String newStatus, {String? levelApproval, int? stepApproval}) async {
    final box = await _getBoxPenerimaan();
    var transaction = box.get(noBast);

    // Fallback search jika key berbeda
    if (transaction == null) {
      try { transaction = box.values.firstWhere((e) => e.noBast == noBast); } catch (_) {}
    }

    if (transaction != null) {
      transaction.status = newStatus;
      if (levelApproval != null) transaction.currentLevelApproval = levelApproval;
      if (stepApproval != null) transaction.currentStepApproval = stepApproval;
      await transaction.save();
    }
  }

  // ===========================================================================
  // REGION: PENGELUARAN (NEW)
  // ===========================================================================

  Future<TransactionPengeluaranModel?> getTransactionPengeluaranByNoBast(String noBast) async {
    final box = await _getBoxPengeluaran();
    if (box.containsKey(noBast)) return box.get(noBast);
    try {
      return box.values.firstWhere((item) => item.noBast == noBast);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveTransactionPengeluaran(TransactionPengeluaranModel data) async {
    final box = await _getBoxPengeluaran();
    // Gunakan noBast sebagai Key agar pencarian O(1)
    await box.put(data.noBast, data);
    print("📥 [Pengeluaran] Disimpan: ${data.noBast}");
  }

  Future<void> updateStatusPengeluaran(String noBast, String newStatus) async {
    final box = await _getBoxPengeluaran();
    var transaction = box.get(noBast);

    // Fallback search
    if (transaction == null) {
      try { transaction = box.values.firstWhere((e) => e.noBast == noBast); } catch (_) {}
    }

    if (transaction != null) {
      transaction.status = newStatus;
      await transaction.save(); // HiveObject save
      print("🔄 [Pengeluaran] Status $noBast update -> $newStatus");
    } else {
      print("⚠️ [Pengeluaran] Gagal update status: $noBast tidak ditemukan");
    }
  }

  // Fungsi Update Data Full (jika diperlukan update field lain selain status)
  Future<void> updateDataPengeluaran(TransactionPengeluaranModel newData) async {
    final box = await _getBoxPengeluaran();
    await box.put(newData.noBast, newData);
  }
}