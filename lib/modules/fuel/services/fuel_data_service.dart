import 'package:e_fuel/configs/app_config.dart';
import 'package:e_fuel/datas/constant/value_key_static.dart';
import 'package:e_fuel/datas/models/fuel/fuel_model.dart'; // Sesuaikan import
import 'package:hive/hive.dart';

class FuelDataService {
  Box<List>? _fuelDataBox;
  Box? _manualStateBox;

  Box<List>? get fuelDataBox => _fuelDataBox;

  Future<void> openFuelDataBox(String username) async {
    final boxName = AppConfig.isDevMode
        ? '${ValueKeyStatic.FUEL_DATA_BOX}_dev_$username'
        : '${ValueKeyStatic.FUEL_DATA_BOX}_$username';

    if (!Hive.isBoxOpen(boxName)) {
      _fuelDataBox = await Hive.openBox<List>(boxName);
    } else {
      _fuelDataBox = Hive.box<List>(boxName);
    }

    await _openManualStateBox(username);
  }

  Future<void> _openManualStateBox(String username) async {
    final boxName = 'manual_tank_state_$username';
    if (!Hive.isBoxOpen(boxName)) {
      _manualStateBox = await Hive.openBox(boxName);
    } else {
      _manualStateBox = Hive.box(boxName);
    }
  }

  // Simpan data manual (Panggil saat transaksi sukses)
  Future<void> updateTankManualState(String tankCode, double volume, double height) async {
    if (_manualStateBox == null) return;
    await _manualStateBox!.put(tankCode, {
      'volume': volume,
      'height': height,
      'last_updated': DateTime.now().toIso8601String(),
    });
  }

  Map<String, double> getLastManualState(String tankCode) {
    if (_manualStateBox == null) return {'volume': 0.0, 'height': 0.0};

    final data = _manualStateBox!.get(tankCode);

    if (data != null && data is Map) {
      return {
        'volume': (data['volume'] ?? 0.0).toDouble(),
        'height': (data['height'] ?? 0.0).toDouble(),
      };
    }

    return {'volume': 0.0, 'height': 0.0};
  }

  Future<void> saveMasterStorages(List<StorageModel> storages) async {
    if (_fuelDataBox == null) return;
    await _fuelDataBox!.put(ValueKeyStatic.LIST_STORAGE_KEY, storages);
    print('💾 Saved ${storages.length} storages to Hive');
  }

  Future<void> saveMasterTanks(List<TankModel> tanks) async {
    if (_fuelDataBox == null) return;
    await _fuelDataBox!.put(ValueKeyStatic.LIST_TANK_MASTER_KEY, tanks);
  }

  Future<void> saveStorageTankIotData(List<StorageTankModel> iotData) async {
    if (_fuelDataBox == null) return;
    await _fuelDataBox!.put(ValueKeyStatic.LIST_STORAGE_TANK_IOT_KEY, iotData);
    print('💾 Saved ${iotData.length} tank IOT records to Hive');
  }

  Future<void> saveTempSnapshot(List<StorageTankModel> snapshotData) async {
    if (_fuelDataBox == null) return;
    await _fuelDataBox!.put(ValueKeyStatic.TEMP_SNAPSHOT_DATA_KEY, snapshotData);
    print('💾 Snapshot Data (Before) berhasil disimpan ke Hive.');
  }

  List<StorageModel> getStorages() {
    if (_fuelDataBox == null) return [];
    final data = _fuelDataBox!.get(ValueKeyStatic.LIST_STORAGE_KEY, defaultValue: []);
    return data!.cast<StorageModel>().toList();
  }

  List<StorageTankModel> getStorageTankIotData() {
    if (_fuelDataBox == null) return [];
    final data = _fuelDataBox!.get(ValueKeyStatic.LIST_STORAGE_TANK_IOT_KEY, defaultValue: []);
    return data!.cast<StorageTankModel>().toList();
  }

  Future<void> clearFuelData() async {
    await _fuelDataBox?.clear();
  }

  List<StorageTankModel> getTempSnapshot() {
    if (_fuelDataBox == null) return [];
    final data = _fuelDataBox!.get(ValueKeyStatic.TEMP_SNAPSHOT_DATA_KEY, defaultValue: []);
    if (data is List) {
      return data.cast<dynamic>().map((e) {
        if (e is StorageTankModel) return e;
        return e as StorageTankModel;
      }).toList();
    }
    return [];
  }

  Future<void> clearTempSnapshot() async {
    if (_fuelDataBox == null) return;
    await _fuelDataBox!.delete(ValueKeyStatic.TEMP_SNAPSHOT_DATA_KEY);
  }
}