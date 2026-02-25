import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_colors.dart';
import '../../../datas/models/filling/filling_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../helpers/calibration_helper.dart';
import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../repositories/penerimaan_setelah_repository.dart';

class PenerimaanSetelahController extends GetxController {
  final _loginService = Get.find<LoginService>();

  late PenerimaanSetelahRepository _repository;

  TransactionModel? currentTransaction;
  String activeNoBast = "";
  String activeNoPO = "";
  String _currentUsername = "";

  final isRefreshing = false.obs;
  final isLoadingData = true.obs;
  final lastSyncTime = ''.obs;

  // --- STATE IoT vs MANUAL ---
  final isSensorApiActive = false.obs;

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
  final manualInputControllers =
      <String, Map<String, TextEditingController>>{}.obs;
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
        final trx = await _repository.getTransaction(activeNoBast);
        currentTransaction = trx;

        String? jsonManualString;
        String? jsonIoTString;

        if (trx != null && trx.dataSebelum != null) {
          jsonManualString = trx.dataSebelum!.manualTankDetailsJson;
          jsonIoTString = trx.dataSebelum!.iotTankDetailsJson;

          if (trx.dataSebelum!.storageCode != null) {
            _initializeTankUI(trx.dataSebelum!.storageCode!);
          }
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

        await _restoreDraft();
        _setInitialSyncTime();

        // AUTO REFRESH IoT SAAT MASUK HALAMAN
        await refreshSensorData();

      } catch (e) {
        Get.snackbar("Error", "Gagal memuat data transaksi: $e");
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

    for (var tank in activeTanks) {
      String code = tank.masterSolarTank?.kodeTank ?? '';
      if (code.isEmpty) continue;

      tempCodes.add(code);
      int tankCapacity = 10000;

      iotSesudahMap[code] = {
        'volume': tank.volume,
        'height': tank.height,
        'display_code': code.replaceAll('_', ' ')
      };

      if (!manualInputControllers.containsKey(code)) {
        final volCtrl = TextEditingController();
        final heightCtrl = TextEditingController();

        volCtrl.addListener(() {
          _updateTotalManual();
          refreshTrigger.value++;
          _saveCurrentProgressToDraft();
        });

        heightCtrl.addListener(() {
          refreshTrigger.value++;
          // Hanya hitung manual jika IoT tidak aktif
          if (!isSensorApiActive.value) {
            _onHeightInputChanged(code, heightCtrl.text, volCtrl, tankCapacity);
          }
          _saveCurrentProgressToDraft();
        });

        manualInputControllers[code] = {
          'volume': volCtrl,
          'height': heightCtrl
        };
      }
    }
    activeTankCodes.assignAll(tempCodes);
    _updateTotalManual();
  }

  void _onHeightInputChanged(String tankCode, String heightText,
      TextEditingController volCtrl, int capacity) {
    if (_debounceTimers.containsKey(tankCode)) {
      _debounceTimers[tankCode]?.cancel();
    }

    _debounceTimers[tankCode] =
        Timer(const Duration(milliseconds: 800), () async {
      String cleanHeight = heightText.replaceAll('.', '').replaceAll(',', '.');
      if (cleanHeight.isEmpty) {
        volCtrl.text = "";
        return;
      }

      double? heightMm = double.tryParse(cleanHeight);
      if (heightMm != null && heightMm > 0) {
        final literResult =
            await _repository.getLiterFromCalibration(capacity, heightMm);

        if (literResult != null) {
          volCtrl.text = TextConvertHelper().formatNumber(literResult);
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
  // Future<void> refreshSensorData() async {
  //   if (isRefreshing.value) return;
  //   isRefreshing.value = true;
  //
  //   try {
  //     String storage = currentTransaction?.dataSebelum?.storageCode ?? "";
  //     final auth = _loginService.getCurrentAuth();
  //     if (auth == null) throw "Sesi user berakhir.";
  //
  //     final unitId = auth.currentKodeUnit ?? '';
  //
  //     // SIMULASI API SENSOR (Set true jika API sudah ready)
  //     bool apiCallSuccess = true;
  //
  //     if (apiCallSuccess) {
  //       await _repository.refreshSensorData(unitId: unitId, storageCode: storage);
  //       isSensorApiActive.value = true;
  //       _syncIotToControllers(storage); // Isi otomatis controller text
  //
  //       Get.snackbar("Sukses", "Data sensor berhasil diperbarui",
  //           backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  //     } else {
  //       isSensorApiActive.value = false;
  //       Get.snackbar("Koneksi Sensor", "Gagal terhubung ke sensor. Mode input manual aktif.",
  //           backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  //     }
  //
  //     _setInitialSyncTime();
  //   } catch (e) {
  //     isSensorApiActive.value = false;
  //     print("Error refresh: $e");
  //   } finally {
  //     isRefreshing.value = false;
  //   }
  // }

  // --- LOGIC SENSOR IoT (SIMULASI) ---
  Future<void> refreshSensorData() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;

    try {
      // Simulasi jeda waktu loading (seolah-olah sedang hit API)
      await Future.delayed(const Duration(seconds: 1));

      // (Ubah ke true jika API menyala/sukses, false jika API mati/gagal)
      bool apiCallSuccess = false;

      // Set status reaktif IoT berdasarkan hasil balikan API
      isSensorApiActive.value = apiCallSuccess;

      if (isSensorApiActive.value) {
        // Jalankan fungsi sinkronisasi data IoT ke UI HANYA JIKA AKTIF
        _syncIotToControllersSimulasi();

        Get.snackbar("Koneksi Sukses",
            "Data volume diambil otomatis dari sensor IoT.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      } else {
        // Jika API gagal/mati, jangan jalankan simulasi, beri notifikasi manual
        Get.snackbar("Koneksi Sensor",
            "Gagal terhubung ke sensor. Mode input manual aktif.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      }

      _setInitialSyncTime();
    } catch (e) {
      isSensorApiActive.value = false;
      print("Error refresh: $e");
    } finally {
      isRefreshing.value = false;
    }
  }

  void _syncIotToControllersSimulasi() {
    for (var code in activeTankCodes) {
      if (manualInputControllers.containsKey(code)) {
        double mockVolume = 0.0;
        int tankCapacity = 10000;

        // Jika kodenya mengandung TANK02 atau TANK 2 (Kapasitas 5.000 L)
        if (code.toUpperCase().contains('TANK02') ||
            code.toUpperCase().contains('TANK 2')) {
          mockVolume = 3570.0; // Simulasi dapat 3570 Liter dari API
          tankCapacity = 5000;
        }
        // Jika kodenya TANK01 (Kapasitas 10.000 L)
        else {
          mockVolume = 6540.0; // Simulasi dapat 6540 Liter dari API
          tankCapacity = 10000;
        }

        // Mencari nilai tinggi (mm) yang paling sesuai dari data Excel
        double estimatedHeight =
            CalibrationHelper.getEstimatedHeight(tankCapacity, mockVolume);

        // Format otomatis angka yang didapat dan masukkan ke form Read-Only
        manualInputControllers[code]?['volume']?.text =
            TextConvertHelper().formatNumber(mockVolume);
        manualInputControllers[code]?['height']?.text =
            TextConvertHelper().formatNumber(estimatedHeight);

        // Simpan data ke Map untuk dikirim ke Backend nanti saat tombol Submit ditekan
        iotSesudahMap[code] = {
          'volume': mockVolume,
          'height': estimatedHeight,
          'display_code': code.replaceAll('_', ' ')
        };
      }
    }

    // Update kalkulasi total di bagian Card atas
    _updateTotalManual();
  }

  void _syncIotToControllers(String storageName) {
    String storageCode = storageName.split(' - ').length > 1
        ? storageName.split(' - ').last
        : storageName;
    final activeTanks = _repository.getLocalSensorData(storageCode);

    for (var tank in activeTanks) {
      String code = tank.masterSolarTank?.kodeTank ?? '';

      if (manualInputControllers.containsKey(code)) {
        // Dapatkan Volume REAL dari API IoT (Contoh: 6540 Liter)
        double volIot = tank.volume ?? 0.0;

        // Identifikasi ini Tangki Besar (10KL) atau Kecil (5KL)
        int tankCapacity = 10000; // Default tangki besar
        if (code.toUpperCase().contains('TANK02') ||
            code.toUpperCase().contains('TANK 2')) {
          tankCapacity = 5000; // Tangki kecil
        }

        // Konversi Volume -> Tinggi (Contoh: 6540 Liter -> 1100 mm)
        double estimatedHeight =
            CalibrationHelper.getEstimatedHeight(tankCapacity, volIot);

        // Isi Form Text Field Secara Otomatis! (User tidak perlu ngetik)
        manualInputControllers[code]?['volume']?.text =
            TextConvertHelper().formatNumber(volIot);
        manualInputControllers[code]?['height']?.text =
            TextConvertHelper().formatNumber(estimatedHeight);

        // Simpan ke Map untuk dikirim ke API Submit nanti
        iotSesudahMap[code] = {
          'volume': volIot,
          'height': estimatedHeight,
          'display_code': code.replaceAll('_', ' ')
        };
      }
    }
    _updateTotalManual();
  }

  List<FillingModel> generateFillingModels() {
    List<FillingModel> results = [];
    String storage = currentTransaction?.dataSebelum?.storageCode ?? "";

    for (String code in activeTankCodes) {
      double volBeforeMan = getVolumeManualSebelum(code);
      double hBeforeMan = getHeightManualSebelum(code);
      double volAfterMan = getVolumeManualSesudah(code);
      double hAfterMan = getHeightManualSesudah(code);

      double volBeforeIoT = _iotBeforeVolMap[code] ?? 0.0;
      double hBeforeIoT = _iotBeforeHeightMap[code] ?? 0.0;

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

      if (volTxt.isEmpty || heightTxt.isEmpty) {
        isValid = false;
        errorMessage =
            "Volume dan Tinggi untuk tangki $displayCode wajib diisi.";
        break;
      }

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
      Get.snackbar(
        "Validasi Gagal",
        errorMessage,
        backgroundColor: AppColors.alertSoftRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
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

    // AMBIL NAMA STORAGE SAAT INI
    String currentStorageName = currentTransaction?.dataSebelum?.storageCode ?? "";

    Get.toNamed(Routes.PENERIMAAAN_VERIFIKASI_BAST, arguments: {
      'noBast': activeNoBast,
      'noPO': activeNoPO,
      'storageCode': currentStorageName, // KODE TAMBAHAN
      'filling_models': fillingData,
      'data_manual_sesudah': dataSesudahLegacy,
      'data_iot_sesudah': iotSesudahMap
    });
  }

  // --- HELPERS ---

  void _handleErrorData(String message) {
    isLoadingData.value = false;
    Get.snackbar("Error Data", message,
        backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white);
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
      _manualBeforeVolMap[code] ?? 0.0;

  double getHeightManualSebelum(String code) =>
      _manualBeforeHeightMap[code] ?? 0.0;

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
