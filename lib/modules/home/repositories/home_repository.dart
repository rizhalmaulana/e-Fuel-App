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

    await Future.wait(masterTanks.map((tank) async {
      try {
        // Hit ke API Latest Stock
        final response = await _homeService.getLatestStockTanks(
          unitId: unitId,
          tankCode: tank.masterSolarTank?.kodeTank ?? '',
          dateLog: today,
        );

        // Ambil data dari cache lokal (Hive) sebagai fallback
        final offlineTank = offlineData.firstWhere(
              (o) => o.masterSolarTank?.kodeTank == tank.masterSolarTank?.kodeTank,
          orElse: () => tank,
        );

        if (response != null && response is List && response.isNotEmpty) {
          final stockData = response.last;
          anyStockApiSuccess = true;

          double vol = (stockData['stock_volume'] as num?)?.toDouble() ?? 0.0;
          double h = (stockData['tinggi'] ?? stockData['height'] as num?)?.toDouble() ?? 0.0;

          syncedList.add(VolumeTankDetailModel(
            id: tank.id,
            unit: tank.unit,
            masterStorage: tank.masterStorage,
            masterSolarTank: tank.masterSolarTank,
            volume: vol,
            height: h,
            updatedAt: DateTime.now().toIso8601String(),
            capacity: tank.capacity,
          ));
        }
        else {
          syncedList.add(VolumeTankDetailModel(
            id: tank.id,
            unit: tank.unit,
            masterStorage: tank.masterStorage,
            masterSolarTank: tank.masterSolarTank,
            volume: offlineTank.volume,
            height: offlineTank.height,
            updatedAt: offlineTank.updatedAt,
            capacity: tank.capacity,
          ));
        }
      } catch (e) {
        final offlineTank = offlineData.firstWhere(
              (o) => o.masterSolarTank?.kodeTank == tank.masterSolarTank?.kodeTank,
          orElse: () => tank,
        );

        syncedList.add(VolumeTankDetailModel(
          id: tank.id,
          unit: tank.unit,
          masterStorage: tank.masterStorage,
          masterSolarTank: tank.masterSolarTank,
          volume: offlineTank.volume, // Gunakan data cache / Hive
          height: offlineTank.height,
          updatedAt: offlineTank.updatedAt,
          capacity: tank.capacity,
        ));
        print("⚠️ [HomeRepo] Gagal fetch stock untuk tangki ${tank.masterSolarTank?.kodeTank}: $e");
      }
    })).timeout(const Duration(seconds: 10));

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