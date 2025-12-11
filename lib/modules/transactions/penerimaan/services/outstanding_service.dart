import 'package:hive/hive.dart';
import '../../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../../datas/models/penerimaan/penerimaan_setelah_pengisian/penerimaan_setelah_model.dart';
import '../../../../datas/models/transactions/penerimaan/transaction_model.dart';

class OutstandingService {
  final String userId;
  OutstandingService(this.userId);

  String get _boxName => 'outstanding_transactions_$userId';

  Future<Box<TransactionModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<TransactionModel>(_boxName);
    }
    return Hive.box<TransactionModel>(_boxName);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final box = await _getBox();
    List<TransactionModel> list = box.values.toList();

    list.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a.dateCreated) ?? DateTime.now();
      DateTime dateB = DateTime.tryParse(b.dateCreated) ?? DateTime.now();
      return dateB.compareTo(dateA); // Descending (Terbaru diatas)
    });

    return list;
  }

  Future<TransactionModel?> getTransactionByNoBast(String noBast) async {
    final box = await _getBox();
    // Cari berdasarkan key (noBast) agar lebih cepat O(1)
    // Jika key anda bukan noBast, gunakan .values.firstWhere seperti sebelumnya

    // Opsi 1: Jika saveOutstanding menggunakan key = noBast (Recommended)
    if (box.containsKey(noBast)) {
      return box.get(noBast);
    }

    // Opsi 2: Fallback cari manual (jika key auto-increment)
    try {
      return box.values.firstWhere((item) => item.noBast == noBast);
    } catch (e) {
      print("⚠️ Transaksi dengan No Doc $noBast tidak ditemukan.");
      return null;
    }
  }

  Future<void> saveTransaction(TransactionModel data) async {
    final box = await _getBox();

    await box.put(data.noBast, data);
    print("📥 Data Transaksi Baru disimpan: ${data.noBast}");
  }

  Future<void> updateDataSesudah(String noBast, PenerimaanSetelahModel dataSesudah) async {
    final box = await _getBox();
    final transaction = box.get(noBast); // Asumsi key = noBast

    if (transaction != null) {
      transaction.dataSesudah = dataSesudah; // Masukkan object model sesudah
      transaction.status = 'setelah_pengisian'; // Auto update status (opsional)
      await transaction.save();
      print("✅ Data Sesudah berhasil ditambahkan ke Transaksi $noBast");
    } else {
      print("❌ Gagal update data sesudah: Transaksi $noBast tidak ditemukan.");
    }
  }

  Future<void> updateStatus(String noBast, String newStatus, {
    String? levelApproval,
    int? stepApproval,
  }) async {
    final box = await _getBox();

    // Coba ambil by Key
    var transaction = box.get(noBast);

    // Jika null, coba cari manual (fallback)
    if (transaction == null) {
      try {
        transaction = box.values.firstWhere((element) => element.noBast == noBast);
      } catch (_) {}
    }

    if (transaction != null) {
      transaction.status = newStatus;

      // Jika ada update approval info
      if (levelApproval != null) transaction.currentLevelApproval = levelApproval;
      if (stepApproval != null) transaction.currentStepApproval = stepApproval;

      await transaction.save();
      print("🔄 Status Transaksi $noBast diupdate ke '$newStatus'");
    } else {
      print("⚠️ Gagal update status: Transaksi $noBast tidak ditemukan.");
    }
  }
}