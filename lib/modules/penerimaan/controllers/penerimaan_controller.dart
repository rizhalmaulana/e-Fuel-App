import 'dart:convert';

import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/helpers/string_helper.dart';
import 'package:e_fuel/modules/master_flow_process/services/flow_process_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/widgets/penerimaan_step.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/fuel_sensor_service.dart';

import '../../../datas/dummy/master_tank_dummy.dart';
import '../../../datas/dummy/master_storage_dummy.dart';
import '../../../datas/dummy/child_storage_tank_dummy.dart';
import '../../../datas/models/fuel/fuel_model.dart';
import '../services/draft_penerimaan_service.dart';

class PenerimaanController extends GetxController {
  // Inject Services
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  final FlowProcessService _stepService = Get.find<FlowProcessService>();
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();

  late DraftPenerimaanService _draftService;

  // Flow Process Getters
  RxList<PenerimaanStep> get masterSteps => _stepService.steps;
  RxInt get currentStepId => _stepService.currentStepId;
  RxString get progressTitle => _stepService.currentStepTitle;

  // UI State Variables
  final isRefreshing = false.obs;
  final lastSyncTime = ''.obs;
  final selectedStorage = 'Pilih Lokasi Storage'.obs;
  final storageLocations = <String>[].obs;

  // --- CARD 1: IOT DATA (LIVE) ---
  final totalVolumeIoT = 0.0.obs;
  final tankListIoT = <Map<String, dynamic>>[].obs;

  // --- CARD 2: MANUAL DATA (SNAPSHOT) ---
  final totalVolumeManualSnapshot = 0.0.obs;
  final tankListManualSnapshot = <Map<String, dynamic>>[].obs;

  // Variabel PageView
  final headerPageIndex = 0.obs;

  // --- MANUAL INPUT DATA (FORM BAWAH) ---
  final manualInputControllers = <String, Map<String, TextEditingController>>{}.obs;
  final manualTotalVolume = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _draftService = DraftPenerimaanService(auth.user.username);
    }
    updateLastSyncTime();

    _ensureDataIsLoaded().then((_) {
      _checkAndRestoreDraft();
    });

    // LISTENER IOT (Update Card 1 Saja)
    ever(_sensorService.iotData, (_) {
      if (selectedStorage.value != 'Pilih Lokasi Storage') {
        _calculateIoTData(selectedStorage.value);
      }
    });

    // LISTENER STORAGE (Update Semua)
    ever(selectedStorage, (val) {
      _calculateAllData(val);
    });
  }

  // --- LOGIC RESTORE DRAFT ---
  Future<void> _checkAndRestoreDraft() async {
    final draft = await _draftService.getDraftBefore();

    if (draft != null && draft.storageCode == selectedStorage.value) {
      if (draft.manualTankDetailsJson != null) {
        try {
          List<dynamic> manualList = jsonDecode(draft.manualTankDetailsJson!);

          for (var item in manualList) {
            String code = item['tank_code'];
            // Format kode agar sesuai key controller (menghilangkan underscore jika ada)
            String formattedCode = code.replaceAll('_', ' ');

            if (manualInputControllers.containsKey(formattedCode)) {
              manualInputControllers[formattedCode]?['volume']?.text = item['volume_manual'].toString();
              manualInputControllers[formattedCode]?['height']?.text = item['height_manual'].toString();
            }
          }
          _updateManualTotalVolume();
        } catch (e) {
          debugPrint("Gagal restore draft manual: $e");
        }
      }
    }
  }

  Future<void> refreshData() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    await _sensorService.refreshData(targetStorageCode: _currentStorageCode);

    updateLastSyncTime();
    isRefreshing.value = false;
  }

  void _calculateAllData(String storageName) {
    _calculateIoTData(storageName);
    _calculateManualSnapshotData(storageName);
    _initializeInputForms(storageName);
  }

  void _calculateIoTData(String storageName) {
    String storageCode = _getStorageCode(storageName);
    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.storageCode == storageCode && tank.statusActive == 'Y',
    ).toList();
    activeTanks.sort((a, b) => a.tankCode.compareTo(b.tankCode));

    double tempTotal = 0.0;
    List<Map<String, dynamic>> tempList = [];

    for (var tank in activeTanks) {
      tempTotal += tank.volume;
      tempList.add({
        'code': tank.tankCode.replaceAll('_', ' '),
        'volume': tank.volume,
        'height': tank.height,
      });
    }
    totalVolumeIoT.value = tempTotal;
    tankListIoT.assignAll(tempList);
  }

  // LOGIC CARD 2 (MANUAL SNAPSHOT)
  void _calculateManualSnapshotData(String storageName) {
    String storageCode = _getStorageCode(storageName);

    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.storageCode == storageCode && tank.statusActive == 'Y',
    ).toList();
    activeTanks.sort((a, b) => a.tankCode.compareTo(b.tankCode));

    double tempTotal = 0.0;
    List<Map<String, dynamic>> tempList = [];

    for (var tank in activeTanks) {
      final manualState = _fuelDataService.getLastManualState(tank.tankCode);

      double vol = manualState['volume']!;
      double h = manualState['height']!;

      tempTotal += vol;

      tempList.add({
        'code': tank.tankCode.replaceAll('_', ' '),
        'volume': vol,
        'height': h,
      });
    }

    totalVolumeManualSnapshot.value = tempTotal;
    tankListManualSnapshot.assignAll(tempList);
  }

  // INIT FORM INPUT
  void _initializeInputForms(String storageName) {
    String storageCode = _getStorageCode(storageName);
    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.storageCode == storageCode && tank.statusActive == 'Y',
    ).toList();
    activeTanks.sort((a, b) => a.tankCode.compareTo(b.tankCode));

    for (var tank in activeTanks) {
      String formattedCode = tank.tankCode.replaceAll('_', ' ');

      if (!manualInputControllers.containsKey(formattedCode)) {
        final volCtrl = TextEditingController();
        final heightCtrl = TextEditingController();
        volCtrl.addListener(_updateManualTotalVolume);

        manualInputControllers[formattedCode] = {
          'volume': volCtrl,
          'height': heightCtrl
        };
      }
    }
    _updateManualTotalVolume();
  }

  Future<void> validateAndProceed() async {
    List<Map<String, dynamic>> manualDataToSave = [];
    List<Map<String, dynamic>> iotDataToSave = [];
    bool isValid = true;

    for (var tank in tankListManualSnapshot) {
      String code = tank['code']!;
      var controllers = manualInputControllers[code];

      if (controllers != null) {
        String volText = controllers['volume']!.text;
        String heightText = controllers['height']!.text;

        if (volText.isEmpty || heightText.isEmpty) {
          isValid = false;
          Get.snackbar("Validasi Gagal", "Mohon lengkapi data volume dan tinggi untuk $code",
              backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
          break;
        }

        manualDataToSave.add({
          'tank_code': code,
          'volume_manual': double.tryParse(StringHelper().cleanNumber(volText)) ?? 0.0,
          'height_manual': double.tryParse(StringHelper().cleanNumber(heightText)) ?? 0.0,
        });
      }
    }

    for (var tank in tankListIoT) {
      iotDataToSave.add({
        'tank_code': tank['code'],
        'volume_iot': double.tryParse(tank['volume'].toString()) ?? 0.0,
        'height_iot': double.tryParse(tank['height'].toString()) ?? 0.0,
      });
    }

    if (!isValid) return;
    var existingDraft = await _draftService.getDraftBefore();

    final draftToSave = PenerimaanSebelumModel(
      userName: _loginService.getCurrentAuth()?.user.username ?? "",
      status: 'draft',
      storageCode: selectedStorage.value,

      manualTankDetailsJson: jsonEncode(manualDataToSave),
      iotTankDetailsJson: jsonEncode(iotDataToSave),
      totalVolumeManual: manualTotalVolume.value,
      totalVolumeIot: totalVolumeIoT.value,

      purchNo: existingDraft?.purchNo,
      vendorSpb: existingDraft?.vendorSpb,
    );

    await _draftService.saveDraftBefore(draftToSave);

    Get.toNamed(
        Routes.PENERIMAAN_SEBELUM_FORM,
        arguments: {
          'storage': selectedStorage.value,
          'manual_total': manualTotalVolume.value,
          'tank_data': manualDataToSave,
        }
    );
  }

  // --- LOGIC UTAMA: DISPLAY DATA ---
  void calculateDisplayData(String storageName) {
    String storageCode = _getStorageCode(storageName);

    // Ambil data IoT aktif
    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.storageCode == storageCode && tank.statusActive == 'Y',
    ).toList();

    activeTanks.sort((a, b) => a.tankCode.compareTo(b.tankCode));

    double totalIoT = 0.0;
    List<Map<String, String>> tempList = [];

    for (var tank in activeTanks) {
      totalIoT += tank.volume;
      String formattedCode = tank.tankCode.replaceAll('_', ' ');

      tempList.add({
        'code': formattedCode,
        'volume': tank.volume.toString(), // Data IoT untuk Card Atas
        'height': tank.height.toString(), // Data IoT untuk Card Atas
      });

      if (!manualInputControllers.containsKey(formattedCode)) {
        final volCtrl = TextEditingController();
        final heightCtrl = TextEditingController();

        // Listener untuk auto-update Total Volume Manual saat mengetik
        volCtrl.addListener(_updateManualTotalVolume);

        manualInputControllers[formattedCode] = {
          'volume': volCtrl,
          'height': heightCtrl
        };
      }
    }

    // Update Data IoT UI
    totalVolumeIoT.value = totalIoT;
    tankListManualSnapshot.assignAll(tempList);

    // Pastikan total manual terupdate (jika list tangki berubah)
    _updateManualTotalVolume();
  }

  void _updateManualTotalVolume() {
    double tempTotal = 0.0;
    manualInputControllers.forEach((key, value) {
      String text = value['volume']?.text ?? '0';
      double vol = double.tryParse(StringHelper().cleanNumber(text)) ?? 0.0;
      tempTotal += vol;
    });
    manualTotalVolume.value = tempTotal;
  }

  void resetForNewTransaction() {
    manualInputControllers.forEach((key, value) {
      value['volume']?.clear();
      value['height']?.clear();
    });

    manualTotalVolume.value = 0.0;
    refreshData();
  }

  String get _currentStorageCode => _getStorageCode(selectedStorage.value);

  String _getStorageCode(String full) {
    return full.split(' - ').length > 1 ? full.split(' - ').last : full;
  }

  @override
  void onClose() {
    manualInputControllers.forEach((key, value) {
      value['volume']?.dispose();
      value['height']?.dispose();
    });
    super.onClose();
  }

  void updateLastSyncTime() {
    final now = DateTime.now();
    final dayName = StringHelper().getDayName(now.weekday);
    final formattedDate = DateFormat('dd MMM yyyy').format(now);
    final formattedHour = DateFormat('HH:mm:ss').format(now);
    lastSyncTime.value = "$dayName, $formattedDate pukul $formattedHour";
  }

  Future<void> _ensureDataIsLoaded() async {
    var auth = _loginService.getCurrentAuth();

    if (auth == null) {
      final success = await _loginService.initializeSessionFromHive();
      if (success) auth = _loginService.getCurrentAuth();
    }

    if (auth != null) {
      final username = auth.user.username;

      await _sensorService.loadInitialData(username);
      await _fuelDataService.openFuelDataBox(username);

      var existingStorages = _fuelDataService.getStorages();

      if (_sensorService.iotData.isEmpty) {
        if (existingStorages.isEmpty) {
          List<StorageModel> storageList = masterStorageDummy.map((e) => StorageModel.fromJson(e)).toList();
          List<TankModel> tankList = mappingMasterTank.map((e) => TankModel.fromJson(e)).toList();
          List<StorageTankModel> iotList = mappingStorageTank.map((e) => StorageTankModel.fromJson(e)).toList();

          await _fuelDataService.saveMasterStorages(storageList);
          await _fuelDataService.saveMasterTanks(tankList);
          await _fuelDataService.saveStorageTankIotData(iotList);

          existingStorages = storageList;
          _sensorService.iotData.assignAll(iotList);
        } else {
          List<StorageTankModel> iotList = mappingStorageTank.map((e) => StorageTankModel.fromJson(e)).toList();
          _sensorService.iotData.assignAll(iotList);
        }
      }

      storageLocations.assignAll(existingStorages.map((e) => e.storageName).toList());

      if (storageLocations.isNotEmpty) {
        String initialStorage = storageLocations.first;
        if (Get.arguments != null && Get.arguments is String) {
          final String argStorage = Get.arguments;
          if (storageLocations.contains(argStorage)) {
            initialStorage = argStorage;
          }
        }
        selectedStorage.value = initialStorage;
        _calculateAllData(initialStorage);
      }
    }
  }
}