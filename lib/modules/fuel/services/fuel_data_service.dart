import 'package:e_fuel/configs/app_config.dart';
import 'package:e_fuel/datas/constant/value_key_static.dart';
import 'package:hive/hive.dart';
import 'package:e_fuel/datas/models/unit_to_storage/unit_to_storage_model.dart';
// Import model VolumeTankDetailModel
import 'package:e_fuel/datas/models/volume_tank_detail/volume_tank_detail_model.dart';

class FuelDataService {
  Box<List>? _fuelDataBox;
  Box? _manualStateBox;

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

  // ===========================================================================
  // REGION 1: MASTER STORAGE (UnitToStorageModel)
  // ===========================================================================

  Future<void> saveLocalStorages(List<UnitToStorageModel> storages) async {
    if (_fuelDataBox == null) return;
    await _fuelDataBox!.put(ValueKeyStatic.LIST_STORAGE_KEY, storages);
  }

  List<UnitToStorageModel> getLocalStorages() {
    if (_fuelDataBox == null) return [];
    final data = _fuelDataBox!.get(ValueKeyStatic.LIST_STORAGE_KEY, defaultValue: []);
    if (data is List) {
      return data.cast<dynamic>().map((e) => e as UnitToStorageModel).toList();
    }
    return [];
  }

  // ===========================================================================
  // REGION 2: API MANUAL TANK DATA (NEW FEATURE)
  // Menyimpan hasil fetch API getTankDetailFromStorage agar persist
  // ===========================================================================

  Future<void> saveApiManualTanks(List<VolumeTankDetailModel> tanks) async {
    if (_fuelDataBox == null) return;
    await _fuelDataBox!.put(ValueKeyStatic.API_MANUAL_TANKS_KEY, tanks);
  }

  List<VolumeTankDetailModel> getApiManualTanks() {
    if (_fuelDataBox == null) return [];
    final data = _fuelDataBox!.get(ValueKeyStatic.API_MANUAL_TANKS_KEY, defaultValue: []);

    if (data is List) {
      return data.cast<dynamic>().map((e) => e as VolumeTankDetailModel).toList();
    }
    return [];
  }

  // ===========================================================================
  // REGION 3: USER DRAFT INPUT (Persisted User Input)
  // ===========================================================================

  Future<void> saveManualTankInput({
    required String tankCode,
    required double volume,
    required double height
  }) async {
    if (_manualStateBox == null) return;
    await _manualStateBox!.put(tankCode, {
      'volume': volume,
      'height': height,
      'last_updated': DateTime.now().toIso8601String(),
    });
  }

  Map<String, double> getManualTankInput(String tankCode) {
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
}