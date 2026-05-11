import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/master_data_service.dart';
import '../../transactions/penerimaan/services/penerimaan_api_service.dart';

class HomeRepository {
  final PenerimaanApiService _apiService = PenerimaanApiService();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final MasterDataService _masterDataService = MasterDataService();

  /// Sinkronisasi data tangki dengan strategi offline-first:
  ///
  /// 1. Tampilkan data offline (Hive) terlebih dahulu sebagai initial data
  /// 2. Jika online → fetch master tangki dari API
  ///    - Jika berhasil → merge dengan data volume real-time per tangki
  ///    - Update cache Hive dengan data terbaru (termasuk capacity & info master)
  /// 3. Jika offline atau API gagal → kembalikan data Hive as-is
  ///
  /// Data Hive tidak pernah dihapus saat logout karena box sudah per-user.

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

    // =========================================================================
    // API master berhasil → fetch volume real-time per tangki lalu merge dengan data master (capacity, kode, dll)
    // =========================================================================
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<VolumeTankDetailModel> syncedList = [];
    bool anyStockApiSuccess = false;

    await Future.wait(masterTanks.map((tank) async {
      try {
        final response = await _apiService.getLatestStockTanks(
          unitId: unitId,
          tankCode: tank.masterSolarTank?.kodeTank ?? '',
          dateLog: today,
        );

        if (response != null && response is List && response.isNotEmpty) {
          final stockData = response.first;
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
        } else {
          final offlineTank = offlineData.firstWhere(
                (o) => o.masterSolarTank?.kodeTank == tank.masterSolarTank?.kodeTank,
            orElse: () => tank,
          );

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
          volume: offlineTank.volume,
          height: offlineTank.height,
          updatedAt: offlineTank.updatedAt,
          capacity: tank.capacity,
        ));
        print("⚠️ [HomeRepo] Gagal fetch stock untuk tangki ${tank.masterSolarTank?.kodeTank}: $e");
      }
    })).timeout(const Duration(seconds: 10));

    // =========================================================================
    // Update cache Hive
    //
    // Strategi update cache:
    // - Selalu simpan jika ada perubahan data master (capacity, info tangki)
    // - Jika minimal 1 stock API berhasil → data volume juga diperbarui
    // - Gabungkan data storage lain yang sudah ada di cache agar tidak hilang
    // =========================================================================
    if (syncedList.isNotEmpty) {
      final allCached = _fuelDataService.getApiManualTanks();

      // Hapus entry lama untuk storage ini, ganti dengan data baru
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