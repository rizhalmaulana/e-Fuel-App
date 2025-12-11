import 'package:hive/hive.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';

class DraftPenerimaanService {
  final String userName;

  DraftPenerimaanService(this.userName);

  String get _draftSebelumBoxName => 'draft_penerimaan_sebelum_$userName';
  String _draftSesudahBoxName(String noBast) => 'draft_penerimaan_sesudah_${userName}_$noBast';

  // ===========================================================================
  // REGION: DRAFT PENERIMAAN SEBELUM (STEP 1)
  // ===========================================================================

  Future<void> saveDraftBefore(PenerimaanSebelumModel data) async {
    if (!Hive.isBoxOpen(_draftSebelumBoxName)) {
      await Hive.openBox<PenerimaanSebelumModel>(_draftSebelumBoxName);
    }
    var box = Hive.box<PenerimaanSebelumModel>(_draftSebelumBoxName);

    await box.put('active_draft_before', data);
    print("💾 Draft (Sebelum) tersimpan untuk user $userName");
  }

  Future<PenerimaanSebelumModel?> getDraftBefore() async {
    if (!Hive.isBoxOpen(_draftSebelumBoxName)) {
      await Hive.openBox<PenerimaanSebelumModel>(_draftSebelumBoxName);
    }
    var box = Hive.box<PenerimaanSebelumModel>(_draftSebelumBoxName);
    return box.get('active_draft_before');
  }

  Future<void> deleteDraftBefore() async {
    if (!Hive.isBoxOpen(_draftSebelumBoxName)) {
      await Hive.openBox<PenerimaanSebelumModel>(_draftSebelumBoxName);
    }
    var box = Hive.box<PenerimaanSebelumModel>(_draftSebelumBoxName);
    await box.delete('active_draft_before');
    print("🗑️ Draft (Sebelum) dihapus.");
  }

  // ===========================================================================
  // REGION: DRAFT PENERIMAAN SESUDAH (STEP 3)
  // ===========================================================================

  Future<void> saveDraftSesudah(String noBast, Map<String, dynamic> formData) async {
    final boxName = _draftSesudahBoxName(noBast);
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Map>(boxName);
    }
    var box = Hive.box<Map>(boxName);

    await box.put('form_data', formData);
    print("💾 Draft (Sesudah) tersimpan untuk No Bast: $noBast");
  }

  Future<Map<dynamic, dynamic>?> getDraftSesudah(String noBast) async {
    final boxName = _draftSesudahBoxName(noBast);
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Map>(boxName);
    }
    var box = Hive.box<Map>(boxName);
    return box.get('form_data');
  }

  Future<void> deleteDraftSesudah(String noBast) async {
    final boxName = _draftSesudahBoxName(noBast);
    if (Hive.isBoxOpen(boxName)) {
      var box = Hive.box<Map>(boxName);
      await box.clear();
      // Opsional: Close box jika ingin hemat memory, tapi hati-hati race condition
      // await box.close();
    } else {
      var box = await Hive.openBox<Map>(boxName);
      await box.clear();
    }
    print("🗑️ Draft (Sesudah) untuk $noBast dihapus.");
  }
}