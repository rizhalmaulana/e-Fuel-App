import 'dart:math';
import 'package:get/get.dart';
import '../../../datas/models/fuel/fuel_model.dart';
import '../../../modules/fuel/services/fuel_data_service.dart';

class FuelSensorService extends GetxService {
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final RxList<StorageTankModel> iotData = <StorageTankModel>[].obs;
  final RxList<StorageTankModel> snapshotData = <StorageTankModel>[].obs;

  Future<void> loadInitialData(String username) async {
    await _fuelDataService.openFuelDataBox(username);

    final data = _fuelDataService.getStorageTankIotData();
    iotData.assignAll(data);

    final savedSnapshot = _fuelDataService.getTempSnapshot();
    if (savedSnapshot.isNotEmpty) {
      snapshotData.assignAll(savedSnapshot);
      print("♻️ Data Snapshot lama berhasil dipulihkan: ${snapshotData.length} tangki");
    }
  }

  Future<void> captureSnapshotAndSave() async {
    snapshotData.assignAll(List.from(iotData));
    await _fuelDataService.saveTempSnapshot(snapshotData);
  }

  Future<List<StorageTankModel>> refreshData({String? targetStorageCode}) async {
    await captureSnapshotAndSave();

    await Future.delayed(const Duration(seconds: 2));
    await _simulateNewData(targetStorageCode: targetStorageCode);

    return iotData;
  }

  Future<void> _simulateNewData({String? targetStorageCode}) async {
    final random = Random();
    final List<StorageTankModel> updated = [];

    for (var old in iotData) {
      bool shouldUpdate = true;
      if (targetStorageCode != null) {
        shouldUpdate = old.storageCode == targetStorageCode;
      }

      if (shouldUpdate) {
        updated.add(StorageTankModel(
          storageCode: old.storageCode,
          tankCode: old.tankCode,
          volume: old.volume + 50 + random.nextInt(100),
          height: old.height + 5 + random.nextInt(10),
          statusActive: old.statusActive,
        ));
      } else {
        // Jangan Ubah Data (Keep Old Data)
        updated.add(old);
      }
    }

    iotData.assignAll(updated);
    await _fuelDataService.saveStorageTankIotData(updated);
  }
}