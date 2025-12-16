import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../configs/app_colors.dart';
import '../../../datas/models/filling/filling_model.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_sensor_service.dart';
import '../../fuel/services/master_data_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../transactions/outstanding_service.dart';
import '../services/draft_penerimaan_service.dart';

class PenerimaanSetelahController extends GetxController {
  // Services
  final _loginService = Get.find<LoginService>();
  final _sensorService = Get.find<FuelSensorService>();
  final MasterDataService _masterDataService = MasterDataService();

  // Data Transaksi
  TransactionModel? currentTransaction;
  String activeNoBast = "";
  String _currentUsername = "";

  // UI State
  final isRefreshing = false.obs;
  final isLoadingData = true.obs;
  final lastSyncTime = ''.obs;
  final headerPageIndex = 0.obs;

  // --- DATA SEBELUM (SNAPSHOT DARI HIVE) ---
  final manualBeforeList = <Map<String, dynamic>>[].obs;
  final totalManualBefore = 0.0.obs;
  final iotBeforeList = <Map<String, dynamic>>[].obs;
  final totalIotBefore = 0.0.obs;

  // Map untuk akses O(1) saat generate model
  final Map<String, double> _manualBeforeVolMap = {};
  final Map<String, double> _manualBeforeHeightMap = {};
  final Map<String, double> _iotBeforeVolMap = {};
  final Map<String, double> _iotBeforeHeightMap = {};
  final Map<String, Timer> _debounceTimers = {};

  // --- DATA SESUDAH (INPUT MANUAL + IOT LIVE) ---
  final activeTankCodes = <String>[].obs;
  final iotSesudahMap = <String, Map<String, dynamic>>{}.obs;
  final manualInputControllers = <String, Map<String, TextEditingController>>{}.obs;
  final totalVolumeManualSesudah = 0.0.obs;

  // TRIGGER UI UPDATE (PENTING AGAR VARIAN UPDATE REALTIME)
  final refreshTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      String? noBastArg = Get.arguments['noBast'];
      if (noBastArg != null && noBastArg.isNotEmpty && noBastArg != '-') {
        _loadTransactionData(noBastArg);
      } else {
        _handleErrorData("No. Dokumen tidak ditemukan.");
      }
    } else {
      _handleErrorData("Data argumen navigasi kosong.");
    }
  }

  void _handleErrorData(String message) {
    isLoadingData.value = false;
    Get.snackbar("Error Data", message, backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white);
  }

  void _setInitialSyncTime() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID');
    lastSyncTime.value = 'Terakhir sync ${formatter.format(now)}';
  }

  Future<void> _loadTransactionData(String noBast) async {
    activeNoBast = noBast;
    isLoadingData.value = true;

    // Pastikan session auth siap
    final auth = await _loginService.getAuthOrLoad();
    _currentUsername = auth?.user.username ?? "";

    if (_currentUsername.isNotEmpty && activeNoBast.isNotEmpty) {
      try {
        final outstandingService = OutstandingService(_currentUsername);

        // 1. Coba ambil Transaksi dari Hive Lokal
        final trx = await outstandingService.getTransactionByNoBast(activeNoBast);
        currentTransaction = trx;

        String? jsonManualString;
        String? jsonIoTString;

        // 2. Prioritas 1: Ambil JSON dari Hive (jika sudah tersimpan)
        if (trx != null && trx.dataSebelum != null) {
          jsonManualString = trx.dataSebelum!.manualTankDetailsJson;
          jsonIoTString = trx.dataSebelum!.iotTankDetailsJson;

          // Init UI Tangki (Sesudah) berdasarkan storage code di Hive
          if (trx.dataSebelum!.storageCode != null) {
            _initializeTankUI(trx.dataSebelum!.storageCode!);
          }
        }

        // 3. Prioritas 2 (BACKUP): Ambil JSON dari Arguments (jika Hive kosong/belum sync)
        // Ini solusi agar data langsung tampil setelah flow pengisian
        if ((jsonManualString == null || jsonManualString.isEmpty) && Get.arguments is Map) {
          jsonManualString = Get.arguments['manual_json_backup'];
        }
        if ((jsonIoTString == null || jsonIoTString.isEmpty) && Get.arguments is Map) {
          jsonIoTString = Get.arguments['iot_json_backup'];
        }

        // 4. PARSE MANUAL DATA (SEBELUM) -> Masukkan ke List & Map Helper
        if (jsonManualString != null && jsonManualString.isNotEmpty) {
          try {
            List<dynamic> list = jsonDecode(jsonManualString);
            double tempTotal = 0;
            List<Map<String, dynamic>> tempList = [];

            // Bersihkan map helper
            _manualBeforeVolMap.clear();
            _manualBeforeHeightMap.clear();

            for (var item in list) {
              String code = item['tank_code'];
              // Parsing aman (handle int/double)
              double vol = (item['volume_manual'] as num).toDouble();
              double h = (item['height_manual'] as num).toDouble();

              tempTotal += vol;
              tempList.add({
                'code': code.replaceAll('_', ' '),
                'volume': vol,
                'height': h
              });

              // Simpan ke Map untuk perhitungan Varian nanti
              _manualBeforeVolMap[code] = vol;
              _manualBeforeHeightMap[code] = h;
            }

            // Update Observable UI
            manualBeforeList.assignAll(tempList);
            totalManualBefore.value = tempTotal;
          } catch (e) {
            print("Error parsing Manual JSON: $e");
          }
        }

        // 5. PARSE IOT DATA (SEBELUM) -> Masukkan ke List & Map Helper
        if (jsonIoTString != null && jsonIoTString.isNotEmpty) {
          try {
            List<dynamic> list = jsonDecode(jsonIoTString);
            double tempTotal = 0;
            List<Map<String, dynamic>> tempList = [];

            _iotBeforeVolMap.clear();
            _iotBeforeHeightMap.clear();

            for (var item in list) {
              String code = item['tank_code'];
              // Parsing aman (handle keys yang mungkin beda dari API vs Lokal)
              num volNum = item['volume_iot'] ?? item['volume'] ?? 0;
              num hNum = item['height_iot'] ?? item['height'] ?? 0;

              double vol = volNum.toDouble();
              double h = hNum.toDouble();

              tempTotal += vol;
              tempList.add({
                'code': code.replaceAll('_', ' '),
                'volume': vol,
                'height': h
              });

              _iotBeforeVolMap[code] = vol;
              _iotBeforeHeightMap[code] = h;
            }

            // Update Observable UI
            iotBeforeList.assignAll(tempList);
            totalIotBefore.value = tempTotal;
          } catch (e) {
            print("Error parsing IoT JSON: $e");
          }
        }

        // 6. Restore Draft Inputan User (Jika user pernah input data "Sesudah" sebelumnya)
        final draftService = DraftPenerimaanService(_currentUsername);
        final draftData = await draftService.getDraftSesudah(activeNoBast);

        if (draftData != null) {
          print("📦 Draft ditemukan, merestore data inputan sesudah...");
          draftData.forEach((tankCode, values) {
            if (manualInputControllers.containsKey(tankCode)) {
              if (values is Map) {
                manualInputControllers[tankCode]?['volume']?.text = values['volume'] ?? '';
                manualInputControllers[tankCode]?['height']?.text = values['height'] ?? '';
              }
            }
          });
          _updateTotalManual();
        }

      } catch (e) {
        print("Error loading transaction data: $e");
        Get.snackbar("Error", "Gagal memuat data transaksi: $e");
      }
    }

    // Selesai loading
    isLoadingData.value = false;
  }

  void _initializeTankUI(String storageName) {
    String storageCode = storageName.split(' - ').length > 1 ? storageName.split(' - ').last : storageName;

    // Filter IoT Data (StorageToTankModel)
    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();

    // Sort
    activeTanks.sort((a, b) => (a.masterSolarTank?.kodeTank ?? '').compareTo(b.masterSolarTank?.kodeTank ?? ''));

    List<String> tempCodes = [];

    for (var tank in activeTanks) {
      String code = tank.masterSolarTank?.kodeTank ?? '';
      if (code.isEmpty) continue;

      tempCodes.add(code);

      // int tankCapacity = tank.masterSolarTank?.capacity ?? 10000
      int tankCapacity = 10000; // Sementara

      iotSesudahMap[code] = {
        'volume': tank.volume,
        'height': tank.height,
        'display_code': code.replaceAll('_', ' ')
      };

      if (!manualInputControllers.containsKey(code)) {
        final volCtrl = TextEditingController();
        final heightCtrl = TextEditingController();

        // Listener Total & Draft (Existing)
        volCtrl.addListener(() {
          _updateTotalManual();
          refreshTrigger.value++;
          _saveCurrentProgressToDraft();
        });

        // [UPDATE] Listener Height -> Trigger API Kalibrasi
        heightCtrl.addListener(() {
          refreshTrigger.value++;

          _onHeightInputChanged(code, heightCtrl.text, volCtrl, tankCapacity);
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

  void _onHeightInputChanged(String tankCode, String heightText, TextEditingController volCtrl, int capacity) {
    if (_debounceTimers.containsKey(tankCode)) {
      _debounceTimers[tankCode]?.cancel();
    }

    _debounceTimers[tankCode] = Timer(const Duration(milliseconds: 800), () async {
      String cleanHeight = heightText.replaceAll('.', '').replaceAll(',', '.');

      if (cleanHeight.isEmpty) {
        volCtrl.text = "";
        return;
      }

      double? heightMm = double.tryParse(cleanHeight);

      if (heightMm != null && heightMm > 0) {
        // Panggil API
        final literResult = await _masterDataService.getLiterFromCalibration(
            kapasitas: capacity,
            tinggiMm: heightMm
        );

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

    final draftService = DraftPenerimaanService(_currentUsername);
    draftService.saveDraftSesudah(activeNoBast, formData);
  }

  void _updateTotalManual() {
    double total = 0.0;
    manualInputControllers.forEach((key, ctrls) {
      String txt = ctrls['volume']?.text ?? '0';
      total += double.tryParse(TextConvertHelper().cleanNumber(txt)) ?? 0.0;
    });
    totalVolumeManualSesudah.value = total;
  }

  double getVolumeManualSebelum(String code) => _manualBeforeVolMap[code] ?? 0.0;
  double getHeightManualSebelum(String code) => _manualBeforeHeightMap[code] ?? 0.0;

  double getVolumeManualSesudah(String code) {
    String txt = manualInputControllers[code]?['volume']?.text ?? '0';
    return double.tryParse(TextConvertHelper().cleanNumber(txt)) ?? 0.0;
  }

  double getHeightManualSesudah(String code) {
    String txt = manualInputControllers[code]?['height']?.text ?? '0';
    return double.tryParse(TextConvertHelper().cleanNumber(txt)) ?? 0.0;
  }

  double getVarianVolume(String code) => getVolumeManualSesudah(code) - getVolumeManualSebelum(code);
  double getVarianHeight(String code) => getHeightManualSesudah(code) - getHeightManualSebelum(code);

  Future<void> refreshSensorData() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      String storage = currentTransaction?.dataSebelum?.storageCode ?? "";
      final auth = _loginService.getCurrentAuth();
      final unitId = auth?.user.userKaryawan.unit.kodeUnit ?? '';

      await _sensorService.refreshData(
          unitId: unitId,
          targetStorageCode: storage
      );

      _initializeTankUI(storage);
      _setInitialSyncTime();
    } catch (e) {
      print("Error refresh: $e");
    } finally {
      isRefreshing.value = false;
    }
  }

  List<FillingModel> generateFillingModels() {
    List<FillingModel> results = [];
    String storage = currentTransaction?.dataSebelum?.storageCode ?? "";

    for (String code in activeTankCodes) {
      // Manual Data
      double volBeforeMan = getVolumeManualSebelum(code);
      double hBeforeMan = getHeightManualSebelum(code);
      double volAfterMan = getVolumeManualSesudah(code);
      double hAfterMan = getHeightManualSesudah(code);

      // IoT Data
      double volBeforeIoT = _iotBeforeVolMap[code] ?? 0.0;
      double hBeforeIoT = _iotBeforeHeightMap[code] ?? 0.0;

      // IoT Sesudah (Live Data)
      var iotAfterData = iotSesudahMap[code];

      // FIX ERROR INT/DOUBLE: Pakai safe casting
      num volIoTNum = iotAfterData?['volume'] ?? 0;
      num hIoTNum = iotAfterData?['height'] ?? 0;

      double volAfterIoT = volIoTNum.toDouble();
      double hAfterIoT = hIoTNum.toDouble();

      results.add(FillingModel(
        transactionId: activeNoBast,
        storageCode: storage,
        tankCode: code,
        timestamp: DateTime.now().toIso8601String(),

        // Manual Comparisons
        volumeBefore: volBeforeMan,
        heightBefore: hBeforeMan,
        volumeAfter: volAfterMan,
        heightAfter: hAfterMan,
        volumeVariant: volAfterMan - volBeforeMan,
        heightVariant: hAfterMan - hBeforeMan,

        // IoT Comparisons
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
        errorMessage = "Volume dan Tinggi untuk tangki $displayCode wajib diisi.";
        break;
      }

      double? volVal = double.tryParse(TextConvertHelper().cleanNumber(volTxt));
      double? heightVal = double.tryParse(TextConvertHelper().cleanNumber(heightTxt));

      if (volVal == null || heightVal == null) {
        isValid = false;
        errorMessage = "Format angka pada tangki $displayCode tidak valid.";
        break;
      }

      // if (volVal < 0 || heightVal < 0) {
      //   isValid = false;
      //   errorMessage = "Nilai tangki $displayCode tidak boleh negatif.";
      //   break;
      // }
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
      final auth = _loginService.getCurrentAuth();
      if (auth != null && activeNoBast.isNotEmpty) {
        final outstandingService = OutstandingService(auth.user.username);
        await outstandingService.updateStatus(activeNoBast, 'verifikasi_bast');
      }
    } catch (e) {
      print("Warning: Gagal update status tracking: $e");
    }

    List<FillingModel> fillingData = generateFillingModels();

    Map<String, dynamic> dataSesudahLegacy = {};
    manualInputControllers.forEach((code, ctrls) {
      dataSesudahLegacy[code] = {
        'volume': double.tryParse(TextConvertHelper().cleanNumber(ctrls['volume']!.text)) ?? 0.0,
        'height': double.tryParse(TextConvertHelper().cleanNumber(ctrls['height']!.text)) ?? 0.0,
      };
    });

    Get.toNamed(
        Routes.PENERIMAAAN_VERIFIKASI_BAST,
        arguments: {
          'noBast': activeNoBast,
          'filling_models': fillingData,
          'data_manual_sesudah': dataSesudahLegacy,
          'data_iot_sesudah': iotSesudahMap
        }
    );
  }

  @override
  void onClose() {
    _debounceTimers.forEach((key, timer) => timer.cancel()); // Cleanup Timer
    manualInputControllers.forEach((key, value) {
      value['volume']?.dispose();
      value['height']?.dispose();
    });
    super.onClose();
  }
}