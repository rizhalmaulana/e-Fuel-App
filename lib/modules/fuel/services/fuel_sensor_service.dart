import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:e_fuel/configs/app_config.dart';
import 'package:e_fuel/datas/constant/value_key_static.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../../fuel/services/master_data_service.dart';

class FuelSensorService extends GetxService {
  Box<List>? _sensorBox;

  final RxList<VolumeTankDetailModel> iotData = <VolumeTankDetailModel>[].obs;
  final RxList<VolumeTankDetailModel> snapshotData = <VolumeTankDetailModel>[].obs;

  final MasterDataService _masterDataService = MasterDataService();

  Future<void> initSensorBox(String username) async {
    final boxName = AppConfig.isDevMode
        ? '${ValueKeyStatic.FUEL_DATA_IOT_BOX}_dev_$username'
        : '${ValueKeyStatic.FUEL_DATA_IOT_BOX}_$username';

    if (!Hive.isBoxOpen(boxName)) {
      _sensorBox = await Hive.openBox<List>(boxName);
    } else {
      _sensorBox = Hive.box<List>(boxName);
    }

    _loadLocalIotData();
    _loadSnapshotData();
  }

  void _loadLocalIotData() {
    if (_sensorBox == null) return;
    final data = _sensorBox!.get(ValueKeyStatic.LIST_STORAGE_TANK_IOT_KEY, defaultValue: []);
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

  Future<void> refreshData({
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
      }
    } catch (e) {
      debugPrint("⚠️ Gagal refresh sensor data: $e");
    }
  }
}