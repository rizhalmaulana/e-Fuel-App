import 'package:hive/hive.dart';

class DraftPengeluaranService {
  final String userName;
  DraftPengeluaranService(this.userName);

  String get _boxName => 'draft_pengeluaran_$userName';

  Future<void> saveDraft(Map<String, dynamic> data) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
    var box = Hive.box<Map>(_boxName);
    await box.put('active_draft_pengeluaran', data);
    print("💾 Draft Pengeluaran tersimpan");
  }

  Future<Map<dynamic, dynamic>?> getDraft() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
    var box = Hive.box<Map>(_boxName);
    return box.get('active_draft_pengeluaran');
  }

  Future<void> deleteDraft() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
    var box = Hive.box<Map>(_boxName);
    await box.delete('active_draft_pengeluaran');
    print("🗑️ Draft Pengeluaran dihapus");
  }
}