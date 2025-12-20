import 'package:hive/hive.dart';
import '../../../datas/models/bon_sementara/bon_sementara_model.dart';

class BonSementaraLocalService {
  final String boxName = "master_bon_sementara";

  Future<void> saveMasterList(List<BonSementaraModel> data) async {
    var box = await Hive.openBox(boxName);
    List<Map<String, dynamic>> jsonList = data.map((e) => e.toJson()).toList();
    await box.put('master_data', jsonList);
  }

  Future<List<BonSementaraModel>> getMasterList() async {
    var box = await Hive.openBox(boxName);
    var data = box.get('master_data');
    if (data != null) {
      return (data as List).map((e) => BonSementaraModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<void> updateItem(BonSementaraModel updatedItem) async {
    List<BonSementaraModel> currentList = await getMasterList();
    int index = currentList.indexWhere((element) => element.internalOrder == updatedItem.internalOrder);

    if (index != -1) {
      currentList[index] = updatedItem;
      await saveMasterList(currentList);
    }
  }
}