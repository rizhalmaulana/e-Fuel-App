import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:e_fuel/configs/app_config.dart';
import 'package:e_fuel/datas/constant/value_key_static.dart';
import '../../../configs/app_colors.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../../fuel/services/master_data_service.dart';

class FuelSensorService extends GetxService {
  late Box<List<dynamic>> _sensorBox;
  Box? _configBox;
  bool _isInitialized = false;

  final RxList<VolumeTankDetailModel> iotData = <VolumeTankDetailModel>[].obs;
  final RxList<VolumeTankDetailModel> snapshotData = <VolumeTankDetailModel>[].obs;

  final MasterDataService _masterDataService = MasterDataService();

  Future<void> initSensorBox(String username) async {
    final boxName = AppConfig.isDevMode
        ? '${ValueKeyStatic.FUEL_DATA_IOT_BOX}_dev_$username'
        : '${ValueKeyStatic.FUEL_DATA_IOT_BOX}_$username';
    final configBoxName = '${boxName}_${username}_config';

    // ✅ Cek migrasi dulu SEBELUM buka box utama
    bool needsMigration = false;
    if (await Hive.boxExists(configBoxName)) {
      try {
        final tempBox = await Hive.openBox(configBoxName);
        final version = tempBox.get('data_version', defaultValue: 1);
        await tempBox.close(); // ✅ Tutup setelah cek
        needsMigration = version < 2;
      } catch (e) {
        needsMigration = true;
      }
    } else {
      needsMigration = true; // belum ada config = perlu migrate
    }

    if (needsMigration) {
      if (await Hive.boxExists(boxName)) await Hive.deleteBoxFromDisk(boxName);
      if (await Hive.boxExists(configBoxName)) await Hive.deleteBoxFromDisk(configBoxName);
    }

    // ✅ Buka box utama SEKALI saja
    try {
      if (Hive.isBoxOpen(boxName)) {
        _sensorBox = Hive.box<List<dynamic>>(boxName);
      } else {
        _sensorBox = await Hive.openBox<List<dynamic>>(boxName);
      }
    } catch (e) {
      print("Error opening box, force deleting: $e");
      await Hive.deleteBoxFromDisk(boxName);
      _sensorBox = await Hive.openBox<List<dynamic>>(boxName);
    }

    // ✅ Buka config box
    if (Hive.isBoxOpen(configBoxName)) {
      _configBox = Hive.box(configBoxName);
    } else {
      _configBox = await Hive.openBox(configBoxName);
    }

    final currentVersion = _configBox!.get('data_version', defaultValue: 1);
    if (currentVersion < 2) {
      await _migrateFromV1ToV2();
      await _configBox!.put('data_version', 2);
    }

    _loadLocalIotData();
    _loadSnapshotData();
  }

  Future<void> _migrateFromV1ToV2() async {
    print("🔄 Migrasi sensor data dari v1 ke v2...");

    Get.snackbar(
      "Pembaruan Aplikasi",
      "Data sensor akan dimuat ulang secara otomatis.",
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    print("✅ Migrasi selesai");
  }

  void _loadLocalIotData() {
    if (!_isInitialized) return;
    final data = _sensorBox.get(ValueKeyStatic.LIST_STORAGE_TANK_IOT_KEY, defaultValue: []);
    if (data is List) {
      final list = data.cast<dynamic>().map((e) => e as VolumeTankDetailModel).toList();
      iotData.assignAll(list);
    }
  }

  Future<void> _saveLocalIotData(List<VolumeTankDetailModel> data) async {
    if (_sensorBox == null) return;
    await _sensorBox!.put(ValueKeyStatic.LIST_STORAGE_TANK_IOT_KEY, data);
    iotData.assignAll(data);
  }

  void _loadSnapshotData() {
    if (_sensorBox == null) return;
    final data = _sensorBox!.get(ValueKeyStatic.TEMP_SNAPSHOT_DATA_KEY, defaultValue: []);
    if (data is List) {
      final list = data.cast<dynamic>().map((e) => e as VolumeTankDetailModel).toList();
      snapshotData.assignAll(list);
    }
  }

  Future<void> captureSnapshot() async {
    if (_sensorBox == null) return;
    final currentData = List<VolumeTankDetailModel>.from(iotData);
    await _sensorBox!.put(ValueKeyStatic.TEMP_SNAPSHOT_DATA_KEY, currentData);
    snapshotData.assignAll(currentData);
  }

  Future<void> clearSnapshot() async {
    if (_sensorBox == null) return;
    await _sensorBox!.delete(ValueKeyStatic.TEMP_SNAPSHOT_DATA_KEY);
    snapshotData.clear();
  }

  Future<List<dynamic>> fetchDataDetailTank({
    required String unitId,
    required String targetStorageCode
  }) async {
    try {
      final tanks = await _masterDataService.getTankDetailFromStorage(
        unitId: unitId,
        storageId: targetStorageCode,
      );

      if (tanks.isNotEmpty) {
        final List<VolumeTankDetailModel> validTanks = tanks.map((e) => e).toList();
        await _saveLocalIotData(validTanks);

        return validTanks;
      }

      return [];
    } catch (e) {
      debugPrint("⚠️ Gagal refresh sensor data: $e");
      return [];
    }
  }
}