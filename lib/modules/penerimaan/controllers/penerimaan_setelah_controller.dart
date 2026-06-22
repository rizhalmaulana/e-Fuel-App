import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/component/custom_snackbar.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_colors.dart';
import '../../../datas/models/filling/filling_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../helpers/calibration_helper.dart';
import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../repositories/penerimaan_setelah_repository.dart';

class PenerimaanSetelahController extends GetxController {
  final _loginService = Get.find<LoginService>();
  final _fuelDataService = Get.find<FuelDataService>();
  late PenerimaanSetelahRepository _repository;

  TransactionModel? currentTransaction;
  String activeNoBast = "";
  String activeNoPO = "";
  String _currentUsername = "";
  final Map<String, int> _tankCapacities = {};

  final isRefreshing = false.obs;
  final isLoadingData = true.obs;
  final lastSyncTime = ''.obs;

  // --- STATE IoT vs MANUAL ---
  final isSensorApiActive = true.obs;
  bool _isInjectingApiData = false;

  // --- DATA SEBELUM ---
  final manualBeforeList = <Map<String, dynamic>>[].obs;
  final totalManualBefore = 0.0.obs;
  final iotBeforeList = <Map<String, dynamic>>[].obs;
  final totalIotBefore = 0.0.obs;

  final Map<String, double> _manualBeforeVolMap = {};
  final Map<String, double> _manualBeforeHeightMap = {};
  final Map<String, double> _iotBeforeVolMap = {};
  final Map<String, double> _iotBeforeHeightMap = {};
  final Map<String, Timer> _debounceTimers = {};

  // --- DATA SESUDAH ---
  final activeTankCodes = <String>[].obs;
  final iotSesudahMap = <String, Map<String, dynamic>>{}.obs;
  final manualInputControllers = <String, Map<String, TextEditingController>>{}.obs;
  final totalVolumeManualSesudah = 0.0.obs;
  final refreshTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkArgumentsAndLoad();
  }

  void _checkArgumentsAndLoad() async {
    if (Get.arguments != null && Get.arguments is Map) {
      String? noBastArg = Get.arguments['noBast'];
      String? noPOArg = Get.arguments['noPO'];

      if (noBastArg != null && noBastArg.isNotEmpty && noPOArg != null && noPOArg.isNotEmpty) {
        await _initializeRepository();
        _loadTransactionData(noBastArg, noPOArg);
      } else {
        _handleErrorData("No. Dokumen tidak ditemukan.");
      }
    } else {
      _handleErrorData("Data argumen navigasi kosong.");
    }
  }

  Future<void> _initializeRepository() async {
    final auth = await _loginService.getAuthOrLoad();
    if (auth != null) {
      _currentUsername = auth.user.username;
      _repository = PenerimaanSetelahRepository(_currentUsername);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _loadTransactionData(String noBast, String noPO) async {
    activeNoBast = noBast;
    activeNoPO = noPO;
    isLoadingData.value = true;

    if (_currentUsername.isNotEmpty && activeNoBast.isNotEmpty) {
      try {
        await _fuelDataService.openFuelDataBox(_currentUsername);
        final trx = await _repository.getTransaction(activeNoBast);
        currentTransaction = trx;

        String? jsonManualString;
        String? jsonIoTString;

        if (trx != null && trx.dataSebelum != null) {
          jsonManualString = trx.dataSebelum!.manualTankDetailsJson;
          jsonIoTString = trx.dataSebelum!.iotTankDetailsJson;
        }

        if ((jsonManualString == null || jsonManualString.isEmpty) &&
            Get.arguments is Map) {
          jsonManualString = Get.arguments['manual_json_backup'];
        }
        if ((jsonIoTString == null || jsonIoTString.isEmpty) &&
            Get.arguments is Map) {
          jsonIoTString = Get.arguments['iot_json_backup'];
        }

        _processManualBeforeData(jsonManualString);
        _processIotBeforeData(jsonIoTString);

        if (trx != null && trx.dataSebelum != null && trx.dataSebelum!.storageCode != null) {
          _initializeTankUI(trx.dataSebelum!.storageCode!);
        }

        await _restoreDraft();
        _setInitialSyncTime();

        await refreshSensorData();

      } catch (e) {
        CustomSnackbar.show(
          title: "Error",
          message: "Gagal memuat data transaksi: $e",
          backgroundColor: AppColors.error,
        );
      }
    }
    isLoadingData.value = false;
  }

  void _processManualBeforeData(String? jsonString) {
    final list = _repository.parseManualJson(jsonString);
    double tempTotal = 0;

    _manualBeforeVolMap.clear();
    _manualBeforeHeightMap.clear();

    for (var item in list) {
      String code = item['code'];
      double vol = item['volume'];
      double h = item['height'];

      tempTotal += vol;
      _manualBeforeVolMap[code] = vol;
      _manualBeforeHeightMap[code] = h;
    }

    manualBeforeList.assignAll(list);
    totalManualBefore.value = tempTotal;
  }

  void _processIotBeforeData(String? jsonString) {
    final list = _repository.parseIotJson(jsonString);
    double tempTotal = 0;

    _iotBeforeVolMap.clear();
    _iotBeforeHeightMap.clear();

    for (var item in list) {
      String code = item['code'];
      double vol = item['volume'];
      double h = item['height'];

      tempTotal += vol;
      _iotBeforeVolMap[code] = vol;
      _iotBeforeHeightMap[code] = h;
    }

    iotBeforeList.assignAll(list);
    totalIotBefore.value = tempTotal;
  }

  Future<void> _restoreDraft() async {
    final draftData = await _repository.getDraft(activeNoBast);
    if (draftData != null) {
      draftData.forEach((tankCode, values) {
        if (manualInputControllers.containsKey(tankCode)) {
          if (values is Map) {
            manualInputControllers[tankCode]?['volume']?.text =
                values['volume'] ?? '';
            manualInputControllers[tankCode]?['height']?.text =
                values['height'] ?? '';
          }
        }
      });
      _updateTotalManual();
    }
  }

  void _initializeTankUI(String storageName) {
    String storageCode = storageName.split(' - ').length > 1
        ? storageName.split(' - ').last
        : storageName;
    final activeTanks = _repository.getLocalSensorData(storageCode);

    activeTanks.sort((a, b) => (a.masterSolarTank?.kodeTank ?? '')
        .compareTo(b.masterSolarTank?.kodeTank ?? ''));

    List<String> tempCodes = [];
    _tankCapacities.clear();

    if (activeTanks.isNotEmpty) {
      for (var tank in activeTanks) {
        String code = tank.masterSolarTank?.kodeTank ?? '';
        if (code.isEmpty) continue;

        tempCodes.add(code);
        int tankCapacity = tank.capacity;
        _tankCapacities[code] = tankCapacity;

        iotSesudahMap[code] = {
          'volume': tank.volume,
          'height': tank.height,
          'display_code': code.replaceAll('_', ' ')
        };

        _setupControllersForTank(code, tankCapacity);
      }
    } else {
      final fallbackList = manualBeforeList.isNotEmpty ? manualBeforeList : iotBeforeList;
      for (var item in fallbackList) {
        String originalCode = item['code'] ?? '';
        String code = originalCode.replaceAll(' ', '_');
        if (code.isEmpty) continue;

        if (!tempCodes.contains(code)) {
          tempCodes.add(code);
        }

        int tankCapacity = _findCapacityForTank(code) ?? 0;
        _tankCapacities[code] = tankCapacity;

        iotSesudahMap[code] = {
          'volume': 0.0,
          'height': 0.0,
          'display_code': originalCode
        };

        _setupControllersForTank(code, tankCapacity);
      }
    }

    activeTankCodes.assignAll(tempCodes);
    _updateTotalManual();
  }

  int? _findCapacityForTank(String code) {
    final cachedTanks = _fuelDataService.getApiManualTanks();
    final match = cachedTanks.firstWhereOrNull((tank) {
      String tankCode = tank.masterSolarTank?.kodeTank ?? '';
      return tankCode.replaceAll('_', ' ').trim().toLowerCase() ==
          code.replaceAll('_', ' ').trim().toLowerCase();
    });
    return match?.capacity;
  }

  void _setupControllersForTank(String code, int tankCapacity) {
    if (!manualInputControllers.containsKey(code)) {
      final volCtrl = TextEditingController();
      final heightCtrl = TextEditingController();

      volCtrl.addListener(() {
        _updateTotalManual();
        refreshTrigger.value++;

        if (isSensorApiActive.value && !_isInjectingApiData) {
          int currentCapacity = _tankCapacities[code] ?? tankCapacity;
          _onVolumeInputChanged(code, volCtrl.text, heightCtrl, currentCapacity);
        }

        _saveCurrentProgressToDraft();
      });

      heightCtrl.addListener(() {
        refreshTrigger.value++;

        if (!isSensorApiActive.value && !_isInjectingApiData) {
          int currentCapacity = _tankCapacities[code] ?? tankCapacity;
          _onHeightInputChanged(code, heightCtrl.text, volCtrl, currentCapacity);
        }

        _saveCurrentProgressToDraft();
      });

      manualInputControllers[code] = {'volume': volCtrl, 'height': heightCtrl};
    }
  }

  void _onVolumeInputChanged(String tankCode, String volumeText, TextEditingController heightCtrl, int capacity) {
    if (_debounceTimers.containsKey(tankCode)) {
      _debounceTimers[tankCode]?.cancel();
    }

    _debounceTimers[tankCode] = Timer(const Duration(milliseconds: 800), () {
      String cleanVol = volumeText.replaceAll('.', '').replaceAll(',', '.');
      if (cleanVol.isEmpty) {
        _silentSetText(heightCtrl, "");
        return;
      }

      double? volLiter = double.tryParse(cleanVol);
      if (volLiter != null && volLiter > 0) {
        int calcHeight = CalibrationHelper.getHeightByVolume(capacity, volLiter);
        _silentSetText(heightCtrl, TextConvertHelper().formatNumber(calcHeight.toDouble()));
      }
    });
  }

  void _onHeightInputChanged(String tankCode, String heightText, TextEditingController volCtrl, int capacity) {
    if (_debounceTimers.containsKey(tankCode)) {
      _debounceTimers[tankCode]?.cancel();
    }

    _debounceTimers[tankCode] = Timer(const Duration(milliseconds: 800), () async {
      String cleanHeight = heightText.replaceAll('.', '').replaceAll(',', '.');
      if (cleanHeight.isEmpty) {
        volCtrl.text = "";
        _updateTotalManual();
        return;
      }

      double? heightMm = double.tryParse(cleanHeight);
      if (heightMm != null && heightMm > 0) {

        double? literResult = await _repository.getLiterFromCalibration(capacity, heightMm);
        literResult ??= CalibrationHelper.getVolumeByHeight(capacity, heightMm.toInt());

        if (literResult > 0) {
          if (volCtrl.text != TextConvertHelper().formatNumber(literResult)) {
            volCtrl.text = TextConvertHelper().formatNumber(literResult);
          }
          _updateTotalManual();
        }
      }
    });
  }

  void _saveCurrentProgressToDraft() {
    if (_currentUsername.isEmpty || activeNoBast.isEmpty) return;
    Map<String, dynamic> formData = {};

    manualInputControllers.forEach((code, ctrls) {
      formData[code] = {
        'volume': ctrls['volume']?.text ?? '',
        'height': ctrls['height']?.text ?? ''
      };
    });

    _repository.saveDraft(activeNoBast, formData);
  }

  // --- LOGIC SENSOR IoT ---
  Future<void> refreshSensorData() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;

    try {
      final auth = await _loginService.getAuthOrLoad();
      final unitId = auth?.currentKodeUnit ?? '';
      final rawStorageCode = currentTransaction?.dataSebelum?.storageCode ?? "";
      final storageCode = _getStorageCode(rawStorageCode);

      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      bool anyDataFound = false;
      _isInjectingApiData = true;

      final masterTanksApi = await _repository.fetchMasterTankDetail(unitId, _getStorageCode(storageCode));

      for (var tankCode in activeTankCodes) {
        int capacity = 0;
        final getDataTangki = masterTanksApi.firstWhereOrNull((t) => t.masterSolarTank?.kodeTank == tankCode);

        if (getDataTangki != null) {
          capacity = getDataTangki.capacity;
          _tankCapacities[tankCode] = capacity;
        }

        final stockDataTanks = await _repository.fetchLatestTankStock(
          unitId: unitId,
          tankCode: tankCode,
          dateLog: today,
        );

        if (stockDataTanks != null) {
          anyDataFound = true;

          double vol = _toDouble(stockDataTanks['stock_volume']) ?? _toDouble(stockDataTanks['volume']) ?? 0.0;
          double height = 0.0;
          int currentCapacity = _tankCapacities[tankCode] ?? capacity;
          if (vol > 0 && currentCapacity > 0) {
            height = CalibrationHelper.getHeightByVolume(currentCapacity, vol).toDouble();
          }

          iotSesudahMap[tankCode] = {
            'volume': vol,
            'height': height,
            'display_code': tankCode.replaceAll('_', ' ')
          };

          if (manualInputControllers.containsKey(tankCode)) {
            _silentSetText(manualInputControllers[tankCode]!['volume']!, vol > 0 ? TextConvertHelper().formatNumber(vol) : '');
            _silentSetText(manualInputControllers[tankCode]!['height']!, height > 0 ? TextConvertHelper().formatNumber(height) : '');
          }
        }
      }

      _isInjectingApiData = false;
      isSensorApiActive.value = anyDataFound;
      _updateTotalManual();

      if (anyDataFound) {
        CustomSnackbar.show(
          title: "Koneksi Sukses",
          message: "Data volume diambil otomatis dari sensor IoT terbaru.",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        CustomSnackbar.show(
          title: "Koneksi Sensor",
          message: "Gagal mendapat respon API. Mode input manual diaktifkan.",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }

      _setInitialSyncTime();
    } catch (e) {
      _isInjectingApiData = false;
      isSensorApiActive.value = false;
      print("Error refresh: $e");
      CustomSnackbar.show(
        title: "Koneksi Sensor",
        message: "Gagal mendapat respon API. Mode input manual diaktifkan.",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  void _silentSetText(TextEditingController ctrl, String value) {
    if (ctrl.text != value) {
      ctrl.text = value;
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  String _getStorageCode(String full) {
    final parts = full.split(' - ');
    return parts.length > 1 ? parts.last.trim() : full.trim();
  }

  List<FillingModel> generateFillingModels() {
    List<FillingModel> results = [];
    String storage = currentTransaction?.dataSebelum?.storageCode ?? "";

    for (String code in activeTankCodes) {
      double volBeforeMan = getVolumeManualSebelum(code);
      double hBeforeMan = getHeightManualSebelum(code);
      double volAfterMan = getVolumeManualSesudah(code);
      double hAfterMan = getHeightManualSesudah(code);

      double volBeforeIoT = _iotBeforeVolMap[code.replaceAll('_', ' ')] ?? 0.0;
      double hBeforeIoT = _iotBeforeHeightMap[code.replaceAll('_', ' ')] ?? 0.0;

      var iotAfterData = iotSesudahMap[code];
      num volIoTNum = iotAfterData?['volume'] ?? 0;
      num hIoTNum = iotAfterData?['height'] ?? 0;
      double volAfterIoT = volIoTNum.toDouble();
      double hAfterIoT = hIoTNum.toDouble();

      results.add(FillingModel(
        transactionId: activeNoBast,
        storageCode: storage,
        tankCode: code,
        timestamp: DateTime.now().toIso8601String(),
        volumeBefore: volBeforeMan,
        heightBefore: hBeforeMan,
        volumeAfter: volAfterMan,
        heightAfter: hAfterMan,
        volumeVariant: volAfterMan - volBeforeMan,
        heightVariant: hAfterMan - hBeforeMan,
        volumeBeforeIoT: volBeforeIoT,
        heightBeforeIoT: hBeforeIoT,
        volumeAfterIoT: volAfterIoT,
        heightAfterIoT: hAfterIoT,
        volumeVariantIoT: volAfterIoT - volBeforeIoT,
        heightVariantIoT: hAfterIoT - hBeforeIoT,
      ));
    }
    return results;
  }

  void goToVerification() async {
    bool isValid = true;
    String errorMessage = "";

    for (String code in activeTankCodes) {
      var ctrls = manualInputControllers[code];
      String displayCode = iotSesudahMap[code]?['display_code'] ?? code;

      String volTxt = ctrls?['volume']?.text.trim() ?? "";
      String heightTxt = ctrls?['height']?.text.trim() ?? "";

      // if (volTxt.isEmpty || heightTxt.isEmpty) {
      //   isValid = false;
      //   errorMessage = "Volume dan Tinggi untuk tangki $displayCode wajib diisi.";
      //   break;
      // }

      double? volVal = double.tryParse(TextConvertHelper().cleanNumber(volTxt));
      double? heightVal =
          double.tryParse(TextConvertHelper().cleanNumber(heightTxt));

      if (volVal == null || heightVal == null) {
        isValid = false;
        errorMessage = "Format angka pada tangki $displayCode tidak valid.";
        break;
      }
    }

    if (!isValid) {
      CustomSnackbar.show(
        title: "Validasi Gagal",
        message: errorMessage,
        backgroundColor: AppColors.alertSoftRed,
        textColor: AppColors.white,
      );
      return;
    }

    try {
      await _repository.updateTransactionStatus(activeNoBast, 'verifikasi_bast');
    } catch (e) {
      print("Warning: Gagal update status tracking: $e");
    }

    List<FillingModel> fillingData = generateFillingModels();

    Map<String, dynamic> dataSesudahLegacy = {};
    manualInputControllers.forEach((code, ctrls) {
      dataSesudahLegacy[code] = {
        'volume': double.tryParse(
            TextConvertHelper().cleanNumber(ctrls['volume']!.text)) ??
            0.0,
        'height': double.tryParse(
            TextConvertHelper().cleanNumber(ctrls['height']!.text)) ??
            0.0,
      };
    });

    String currentStorageName = currentTransaction?.dataSebelum?.storageCode ?? "";
    Get.toNamed(Routes.PENERIMAAAN_VERIFIKASI_BAST, arguments: {
      'noBast': activeNoBast,
      'noPO': activeNoPO,
      'storageCode': currentStorageName,
      'filling_models': fillingData,
      'data_manual_sesudah': dataSesudahLegacy,
      'data_iot_sesudah': iotSesudahMap
    });
  }

  // --- HELPERS ---
  void _handleErrorData(String message) {
    isLoadingData.value = false;
    CustomSnackbar.show(
      title: "Error Data",
      message: message,
      backgroundColor: AppColors.alertSoftRed,
      textColor: AppColors.white,
    );
  }

  void _setInitialSyncTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm:ss', 'id_ID');
    lastSyncTime.value = 'Update: ${formatter.format(now)}';
  }

  void _updateTotalManual() {
    double total = 0.0;
    manualInputControllers.forEach((key, ctrls) {
      String txt = ctrls['volume']?.text ?? '0';
      total += double.tryParse(TextConvertHelper().cleanNumber(txt)) ?? 0.0;
    });
    totalVolumeManualSesudah.value = total;
  }

  double getVolumeManualSebelum(String code) =>
      _manualBeforeVolMap[code.replaceAll('_', ' ')] ?? 0.0;

  double getHeightManualSebelum(String code) =>
      _manualBeforeHeightMap[code.replaceAll('_', ' ')] ?? 0.0;

  double getVolumeManualSesudah(String code) {
    String txt = manualInputControllers[code]?['volume']?.text ?? '0';
    return double.tryParse(TextConvertHelper().cleanNumber(txt)) ?? 0.0;
  }

  double getHeightManualSesudah(String code) {
    String txt = manualInputControllers[code]?['height']?.text ?? '0';
    return double.tryParse(TextConvertHelper().cleanNumber(txt)) ?? 0.0;
  }

  double getVarianVolume(String code) =>
      getVolumeManualSesudah(code) - getVolumeManualSebelum(code);

  double getVarianHeight(String code) =>
      getHeightManualSesudah(code) - getHeightManualSebelum(code);

  @override
  void onClose() {
    _debounceTimers.forEach((key, timer) => timer.cancel());
    manualInputControllers.forEach((key, value) {
      value['volume']?.dispose();
      value['height']?.dispose();
    });
    super.onClose();
  }
}
