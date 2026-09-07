import 'package:e_fuel/modules/home/services/home_service.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/master_data_service.dart';

class HomeRepository {
  HomeService get _homeService => Get.find<HomeService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final MasterDataService _masterDataService = MasterDataService();

  Future<List<VolumeTankDetailModel>> syncSensorStockWithLocal({
    required String unitId,
    required String storageCode,
  }) async {
    final offlineData = _fuelDataService
        .getApiManualTanks()
        .where((t) => t.masterStorage?.kodeStorage == storageCode)
        .toList();

    List<VolumeTankDetailModel> masterTanks = [];
    try {
      masterTanks = await _masterDataService.getTankDetailFromStorage(
        unitId: unitId,
        storageId: storageCode,
      );
    } catch (e) {
      print("⚠️ [HomeRepo] Gagal fetch master tangki (offline?): $e");
    }

    if (masterTanks.isEmpty) {
      if (offlineData.isNotEmpty) {
        print("📦 [HomeRepo] Menggunakan data offline untuk storage: $storageCode");
        return offlineData;
      }
      return [];
    }

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<VolumeTankDetailModel> syncedList = [];
    bool anyStockApiSuccess = false;

    // API_GET_CHILD_DETAIL_STORAGE_TANK already returns the latest volume and height, 
    // so we can just use the data from masterTanks directly.
    for (var tank in masterTanks) {
      anyStockApiSuccess = true;
      syncedList.add(VolumeTankDetailModel(
        id: tank.id,
        unit: tank.unit,
        masterStorage: tank.masterStorage,
        masterSolarTank: tank.masterSolarTank,
        volume: tank.volume,
        height: tank.height,
        updatedAt: DateTime.now().toIso8601String(),
        capacity: tank.capacity,
      ));
    }

    if (syncedList.isNotEmpty) {
      final allCached = _fuelDataService.getApiManualTanks();

      final otherStorageData = allCached
          .where((t) => t.masterStorage?.kodeStorage != storageCode)
          .toList();

      final mergedCache = [...otherStorageData, ...syncedList];
      await _fuelDataService.saveApiManualTanks(mergedCache);

      print("✅ [HomeRepo] Cache offline diperbarui: ${syncedList.length} tangki "
          "untuk storage $storageCode (stockApiOk: $anyStockApiSuccess)");
    }

    return syncedList;
  }
}