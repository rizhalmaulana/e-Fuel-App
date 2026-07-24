import 'package:e_fuel/configs/app_config.dart';
import 'package:e_fuel/datas/constant/value_key_static.dart';
import 'package:hive/hive.dart';
import 'package:e_fuel/datas/models/unit_to_storage/unit_to_storage_model.dart';
import 'package:e_fuel/datas/models/volume_tank_detail/volume_tank_detail_model.dart';

class FuelDataService {
  Box<List>? _fuelDataBox;
  Box? _manualStateBox;

  Future<void> openFuelDataBox(String username) async {
    final boxName = AppConfig.isDevMode
        ? '${ValueKeyStatic.FUEL_DATA_BOX}_dev_$username'
        : '${ValueKeyStatic.FUEL_DATA_BOX}_$username';

    if (!Hive.isBoxOpen(boxName)) {
      _fuelDataBox = await Hive.openBox(boxName);
    } else {
      _fuelDataBox = Hive.box(boxName);
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
  // Offline-first: selalu simpan saat online, baca dari lokal saat offline
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
  // REGION 2: DATA TANGKI (VolumeTankDetailModel) — BUGFIX + OFFLINE-FIRST
  // ===========================================================================

  /// Simpan data tangki (volume, kapasitas, master info) ke Hive lokal per user.
  /// Dipanggil setiap kali berhasil fetch dari API (online) — menggantikan cache lama.
  Future<void> saveApiManualTanks(List<VolumeTankDetailModel> tanks) async {
    if (_fuelDataBox == null) return;
    // FIX: gunakan _fuelDataBox (per user) bukan box terpisah tanpa username
    await _fuelDataBox!.put(ValueKeyStatic.API_MANUAL_TANKS_KEY, tanks);
  }

  /// Baca data tangki dari lokal Hive. Digunakan sebagai fallback saat offline
  /// atau sebagai data awal sebelum API selesai dipanggil.
  List<VolumeTankDetailModel> getApiManualTanks() {
    if (_fuelDataBox == null) return [];
    final data = _fuelDataBox!.get(ValueKeyStatic.API_MANUAL_TANKS_KEY, defaultValue: []);
    if (data is List) {
      return data.cast<dynamic>().map((e) => e as VolumeTankDetailModel).toList();
    }
    return [];
  }

  /// Cek apakah ada data tangki yang tersimpan secara offline.
  bool hasOfflineTankData() {
    return getApiManualTanks().isNotEmpty;
  }

  // ===========================================================================
  // REGION 3: USER DRAFT INPUT (Persisted User Input)
  // ===========================================================================

  Future<void> saveManualTankInputService({
    required String tankCode,
    required double volume,
    required double height,
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

  Future<void> saveLastInputType(String type) async {
    if (_manualStateBox == null) return;
    await _manualStateBox!.put('last_input_type', type);
  }

  String getLastInputType() {
    if (_manualStateBox == null) return "M";
    return _manualStateBox!.get('last_input_type', defaultValue: "M");
  }

  Future<void> saveLastSelectedStorage(String name, String code) async {
    if (_manualStateBox == null) return;
    await _manualStateBox!.put(ValueKeyStatic.LAST_SELECTED_STORAGE_KEY, name);
    await _manualStateBox!.put(ValueKeyStatic.LAST_SELECTED_STORAGE_CODE_KEY, code);
  }

  String getLastSelectedStorage() {
    if (_manualStateBox == null) return 'Pilih Lokasi Storage';
    return _manualStateBox!.get(
      ValueKeyStatic.LAST_SELECTED_STORAGE_KEY,
      defaultValue: 'Pilih Lokasi Storage',
    );
  }

  String getLastSelectedStorageCode() {
    if (_manualStateBox == null) return '';
    return _manualStateBox!.get(
      ValueKeyStatic.LAST_SELECTED_STORAGE_CODE_KEY,
      defaultValue: '',
    );
  }
}