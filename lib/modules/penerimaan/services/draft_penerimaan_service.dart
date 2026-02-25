import 'package:hive/hive.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';

class DraftPenerimaanService {
  final String userName;
  DraftPenerimaanService(this.userName);

  String get _draftSebelumBoxName => 'draft_penerimaan_sebelum_$userName';
  String _draftSesudahBoxName(String noBast) => 'draft_penerimaan_sesudah_${userName}_$noBast';

  // --- DRAFT STEP 1 (SEBELUM) ---
  Future<void> saveDraftBefore(PenerimaanSebelumModel data) async {
    final box = await _openBeforeBox();
    await box.put('active_draft_before', data);
  }

  Future<PenerimaanSebelumModel?> getDraftBefore() async {
    final box = await _openBeforeBox();
    return box.get('active_draft_before');
  }

  Future<void> deleteDraftBefore() async {
    final box = await _openBeforeBox();
    await box.delete('active_draft_before');
  }

  Future<Box<PenerimaanSebelumModel>> _openBeforeBox() async {
    if (!Hive.isBoxOpen(_draftSebelumBoxName)) {
      return await Hive.openBox<PenerimaanSebelumModel>(_draftSebelumBoxName);
    }
    return Hive.box<PenerimaanSebelumModel>(_draftSebelumBoxName);
  }

  // --- DRAFT STEP 3 (SESUDAH) ---
  Future<void> saveDraftSesudah(String noBast, Map<String, dynamic> formData) async {
    final box = await _openSesudahBox(noBast);
    await box.put('form_data', formData);
  }

  Future<Map<dynamic, dynamic>?> getDraftSesudah(String noBast) async {
    final box = await _openSesudahBox(noBast);
    return box.get('form_data');
  }

  Future<void> deleteDraftSesudah(String noBast) async {
    final box = await _openSesudahBox(noBast);
    await box.clear();
  }

  Future<Box<Map>> _openSesudahBox(String noBast) async {
    final boxName = _draftSesudahBoxName(noBast);
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<Map>(boxName);
    }
    return Hive.box<Map>(boxName);
  }
}