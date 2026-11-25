import 'package:e_fuel/modules/home/services/home_service.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/master_data_service.dart';

class TankSyncResult {
  final List<VolumeTankDetailModel> tanks;
  final bool isFromServer;
  final Object? error;

  const TankSyncResult({
    required this.tanks,
    required this.isFromServer,
    this.error,
  });
}

class HomeRepository {
  HomeService get _homeService => Get.find<HomeService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final MasterDataService _masterDataService = MasterDataService();

  Future<TankSyncResult> syncSensorStockWithStatus({
    required String unitId,
    required String storageCode,
  }) async {
    final offlineData = _fuelDataService
        .getApiManualTanks()
        .where((t) => t.masterStorage?.kodeStorage == storageCode)
        .toList();

    List<VolumeTankDetailModel> masterTanks = [];
    Object? fetchError;
    try {
      masterTanks = await _masterDataService.getTankDetailFromStorage(
        unitId: unitId,
        storageId: storageCode,
      );
    } catch (e) {
      fetchError = e;
      print("⚠️ [HomeRepo] Gagal fetch master tangki (offline?): $e");
    }

    if (fetchError != null) {
      return TankSyncResult(
        tanks: offlineData,
        isFromServer: false,
        error: fetchError,
      );
    }

    if (masterTanks.isEmpty) {
      return TankSyncResult(
        tanks: offlineData,
        isFromServer: false,
      );
    }

    List<VolumeTankDetailModel> syncedList = [];
    for (var tank in masterTanks) {
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
          "untuk storage $storageCode");
    }

    return TankSyncResult(
      tanks: syncedList,
      isFromServer: true,
    );
  }

  Future<List<VolumeTankDetailModel>> syncSensorStockWithLocal({
    required String unitId,
    required String storageCode,
  }) async {
    final result = await syncSensorStockWithStatus(
      unitId: unitId,
      storageCode: storageCode,
    );
    return result.tanks;
  }
}