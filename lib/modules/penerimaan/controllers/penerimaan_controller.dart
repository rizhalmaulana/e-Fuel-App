import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:e_fuel/modules/master_flow_process/services/flow_process_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_fonts.dart';
import '../../../datas/constant/value_key_static.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/widgets/penerimaan_step.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/fuel_sensor_service.dart';

import '../../fuel/services/master_data_service.dart';
import '../../transactions/outstanding_service.dart';
import '../../transactions/penerimaan/services/penerimaan_api_service.dart';
import '../services/draft_penerimaan_service.dart';

class PenerimaanController extends GetxController {
  // Inject Services
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  final FlowProcessService _stepService = Get.find<FlowProcessService>();
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final PenerimaanApiService _apiService = PenerimaanApiService();
  late DraftPenerimaanService _draftService;
  final Map<String, Timer> _debounceTimers = {};
  final MasterDataService _masterDataService = MasterDataService(); // Instance service

  RxList<PenerimaanStep> get masterSteps => _stepService.steps;
  RxInt get currentStepId => _stepService.currentStepId;
  RxString get progressTitle => _stepService.currentStepTitle;

  // Menampung data dari controller sebelumnya
  Map<String, dynamic> administrativeData = {};

  // UI State Variables
  final isRefreshing = false.obs;
  final lastSyncTime = ''.obs;
  final selectedStorage = 'Pilih Lokasi Storage'.obs;
  final storageLocations = <String>[].obs;
  final isSubmitting = false.obs;

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

    // Listener jika data sensor berubah (dari API)
    ever(_sensorService.iotData, (_) {
      if (selectedStorage.value != 'Pilih Lokasi Storage') {
        _calculateIoTData(selectedStorage.value);
      }
    });

    ever(selectedStorage, (val) {
      _calculateAllData(val);
    });

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;

      if (args.containsKey('is_new_transaction') && args['is_new_transaction'] == true) {
        administrativeData = args['administrative_data'];

        if (administrativeData.containsKey('storage_code')) {
          selectedStorage.value = administrativeData['storage_code'];
          _calculateAllData(selectedStorage.value);
        }
      }
      else if (args.containsKey('isResume')) {
        // Logic resume jika diperlukan
      }
    }
  }

  Future<void> _checkAndRestoreDraft() async {
    final draft = await _draftService.getDraftBefore();

    if (draft != null && draft.storageCode == selectedStorage.value) {
      if (draft.manualTankDetailsJson != null) {
        try {
          List<dynamic> manualList = jsonDecode(draft.manualTankDetailsJson!);

          for (var item in manualList) {
            String code = item['tank_code'];
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

    final authData = _loginService.getCurrentAuth();
    if (authData == null) {
      print("⚠️ [LoginController] Auth Data null, skip sync.");
      return;
    }

    final unitId = authData.currentKodeUnit;
    if (unitId == null) {
      print("⚠️ [LoginController] Data Unit Id null, skip Refresh.");
      return;
    }

    await _sensorService.refreshData(
        unitId: unitId,
        targetStorageCode: _currentStorageCode
    );

    updateLastSyncTime();
    isRefreshing.value = false;
  }

  Future<void> _calculateAllData(String storageName) async {
    String storageCode = _getStorageCode(storageName);
    final authData = _loginService.getCurrentAuth();

    if (authData == null) {
      print("⚠️ [LoginController] Auth Data null, skip sync.");
      return;
    }

    final unitId = authData.currentKodeUnit;
    if (unitId == null) {
      print("⚠️ [LoginController] Data Unit Id null, skip Refresh.");
      return;
    }

    var activeTanks = _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();

    if (activeTanks.isEmpty && unitId.isNotEmpty) {
      try {
        isRefreshing.value = true;

        final apiTanks = await _masterDataService.getTankDetailFromStorage(
            unitId: unitId,
            storageId: storageCode
        );

        if (apiTanks.isNotEmpty) {
          _sensorService.iotData.removeWhere((t) => t.masterStorage?.kodeStorage == storageCode);
          _sensorService.iotData.addAll(apiTanks);

          activeTanks = apiTanks;
        }
      } catch (e) {
        print("Gagal auto-load master tank: $e");
      } finally {
        isRefreshing.value = false;
      }
    }

    _calculateIoTData(storageName);
    _calculateManualSnapshotData(storageName);
    _initializeInputForms(storageName);
  }

  void _calculateIoTData(String storageName) {
    String storageCode = _getStorageCode(storageName);

    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();

    activeTanks.sort((a, b) => (a.masterSolarTank?.kodeTank ?? '').compareTo(b.masterSolarTank?.kodeTank ?? ''));

    double tempTotal = 0.0;
    List<Map<String, dynamic>> tempList = [];

    for (var tank in activeTanks) {
      double vol = tank.volume;
      double h = tank.height;

      tempTotal += vol;
      tempList.add({
        'code': (tank.masterSolarTank?.kodeTank ?? '').replaceAll('_', ' '),
        'volume': vol,
        'height': h,
      });
    }
    totalVolumeIoT.value = tempTotal;
    tankListIoT.assignAll(tempList);
  }

  void _calculateManualSnapshotData(String storageName) {
    String storageCode = _getStorageCode(storageName);

    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();

    activeTanks.sort((a, b) => (a.masterSolarTank?.kodeTank ?? '').compareTo(b.masterSolarTank?.kodeTank ?? ''));

    double tempTotal = 0.0;
    List<Map<String, dynamic>> tempList = [];

    for (var tank in activeTanks) {
      String tankCode = tank.masterSolarTank?.kodeTank ?? '';
      final manualState = _fuelDataService.getManualTankInput(tankCode);

      double vol = manualState['volume']!;
      double h = manualState['height']!;

      tempTotal += vol;

      tempList.add({
        'code': tankCode.replaceAll('_', ' '),
        'volume': vol,
        'height': h,
      });
    }

    totalVolumeManualSnapshot.value = tempTotal;
    tankListManualSnapshot.assignAll(tempList);
  }

  void _initializeInputForms(String storageName) {
    String storageCode = _getStorageCode(storageName);

    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();

    for (var tank in activeTanks) {
      String tankCode = tank.masterSolarTank?.kodeTank ?? '';
      String formattedCode = tankCode.replaceAll('_', ' ');

      // int tankCapacity = tank.masterSolarTank?.capacity ?? 10000;
      int tankCapacity = 10000; // Sementara

      if (!manualInputControllers.containsKey(formattedCode)) {
        final volCtrl = TextEditingController();
        final heightCtrl = TextEditingController();

        volCtrl.addListener(_updateManualTotalVolume);

        heightCtrl.addListener(() {
          _onHeightInputChanged(formattedCode, heightCtrl.text, volCtrl, tankCapacity);
        });

        manualInputControllers[formattedCode] = {
          'volume': volCtrl,
          'height': heightCtrl
        };
      }
    }
    _updateManualTotalVolume();
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
        final literResult = await _masterDataService.getLiterFromCalibration(
            kapasitas: capacity,
            tinggiMm: heightMm
        );

        if (literResult != null) {
          volCtrl.text = TextConvertHelper().formatNumber(literResult);
        }
      }
    });
  }

  bool _validateInputs() {
    for (var tank in tankListManualSnapshot) {
      String code = tank['code']!;
      var controllers = manualInputControllers[code];

      if (controllers != null) {
        String volText = controllers['volume']!.text;
        String heightText = controllers['height']!.text;

        if (volText.isEmpty || heightText.isEmpty) {
          Get.snackbar(
              "Data Belum Lengkap",
              "Volume dan Tinggi untuk tangki $code wajib diisi.",
              backgroundColor: AppColors.alertSoftRed,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(16)
          );
          return false;
        }
      }
    }
    return true;
  }

  Future<void> validateAndProceed() async {
    if (!_validateInputs()) return;

    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieConfirmation(),
        title: "Konfirmasi Submit",
        message: "Apakah Anda yakin data pengukuran tangki sudah benar?",

        secondaryButtonText: "Batal",
        onSecondaryPressed: () => Get.back(),

        primaryButtonText: "Submit",
        onPrimaryPressed: () {
          Get.back();
          submitFinalTransaction();
        },
      ),
      barrierDismissible: false,
    );
  }

  void _updateManualTotalVolume() {
    double tempTotal = 0.0;
    manualInputControllers.forEach((key, value) {
      String text = value['volume']?.text ?? '0';
      String cleanText = text.replaceAll('.', '');

      double vol = double.tryParse(cleanText) ?? 0.0;
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

  Future<void> submitFinalTransaction() async {
    if (isSubmitting.value) return;
    if (!_validateInputs()) return;

    isSubmitting.value = true;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                "Mengirim Data",
                style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Mohon jangan tutup aplikasi saat proses upload...",
                style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final auth = _loginService.getCurrentAuth();
      if (auth == null) throw "Sesi user berakhir.";

      List<Map<String, dynamic>> manualDataToSubmit = [];
      for (var tank in tankListManualSnapshot) {
        String code = tank['code']!;
        var controllers = manualInputControllers[code];

        if (controllers != null) {
          // Parse value
          double volParsed = double.tryParse(controllers['volume']!.text.replaceAll('.', '')) ?? 0.0;
          double heightParsed = double.tryParse(controllers['height']!.text.replaceAll(',', '.')) ?? 0.0;

          manualDataToSubmit.add({
            'tank_code': code.replaceAll(' ', '_'),
            'volume_manual': volParsed,
            'height_manual': heightParsed,
          });
        }
      }

      final currentIotSnapshot = _sensorService.iotData.where((t) =>
      t.masterStorage?.kodeStorage == _getStorageCode(selectedStorage.value)
      ).map((e) => {
        'tank_code': e.masterSolarTank?.kodeTank ?? '',
        'volume_iot': e.volume,
        'height_iot': e.height,
      }).toList();

      String rawStorage = selectedStorage.value;
      String finalStorageCode = _getStorageCode(rawStorage);

      final adminData = administrativeData;

      final Map<String, dynamic> formMap = {
        'doc_type_code': ValueKeyStatic.CODE_TRANSACTION_PENERIMAAN,
        'kode_unit': auth.currentKodeUnit ?? "",
        'storage_code': finalStorageCode,

        'purch_no': adminData['purch_no'],
        'vendor_spb': adminData['vendor_spb'],
        'volume_vendor': adminData['volume_vendor'],
        'density_vendor': adminData['density_vendor'],
        'temp_vendor': adminData['temp_vendor'],
        'nopol_vendor': adminData['nopol_vendor'],
        'supir_vendor': adminData['supir_vendor'],
        'kapasitas_vendor': adminData['kapasitas_vendor'],

        'long': adminData['long'] ?? 0,
        'lat': adminData['lat'] ?? 0,

        'segel_kondisi': adminData['segel_kondisi'],
        'tangki_peka': adminData['tangki_peka'],
        'segel_tangki_bawah': adminData['segel_tangki_bawah'],
        'segel_tangki_atas': adminData['segel_tangki_atas'],
        'terra_vendor': adminData['terra_vendor'],
        'terra_check': adminData['terra_check'],
        'terra_var': adminData['terra_var'],

        'date_inbound': adminData['date_inbound'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'dtime_before': adminData['dtime_before'] ?? DateTime.now().toIso8601String(),

        'iot_tank_details': jsonEncode(currentIotSnapshot),
        'manual_tank_details': jsonEncode(manualDataToSubmit),

        'volume_terkini_liter': 0,
      };

      List<File?> filesToUpload = [];

      if (adminData['path_foto_doc'] != null) {
        filesToUpload.add(File(adminData['path_foto_doc']));
      } else {
        filesToUpload.add(null);
      }

      if (adminData['path_foto_depan'] != null) {
        filesToUpload.add(File(adminData['path_foto_depan']));
      } else {
        filesToUpload.add(null);
      }

      if (adminData['path_foto_samping'] != null) {
        filesToUpload.add(File(adminData['path_foto_samping']));
      } else {
        filesToUpload.add(null);
      }

      final responseData = await _apiService.submitInboundOpen(
          formMap: formMap,
          photos: filesToUpload
      );

      String noBastResult = responseData['no_doc'] ?? "-";

      final dataSebelum = PenerimaanSebelumModel(
        // Map data dari formMap ke Model
        docTypeCode: formMap['doc_type_code'],
        kodeUnit: formMap['kode_unit'],
        storageCode: rawStorage, // Gunakan raw string storage

        purchNo: formMap['purch_no'],
        vendorSpb: formMap['vendor_spb'],
        volumeVendor: TextConvertHelper().parseToDouble(formMap['volume_vendor']),
        densityVendor: TextConvertHelper().parseToDouble(formMap['density_vendor']),
        tempVendor: TextConvertHelper().parseToDouble(formMap['temp_vendor']),
        nopolVendor: formMap['nopol_vendor'],
        supirVendor: formMap['supir_vendor'],
        kapasitasVendor: TextConvertHelper().parseToDouble(formMap['kapasitas_vendor']),

        terraVendor: TextConvertHelper().parseToDouble(formMap['terra_vendor']),
        terraCheck: TextConvertHelper().parseToDouble(formMap['terra_check']),
        terraVar: TextConvertHelper().parseToDouble(formMap['terra_var']),

        segelKondisi: formMap['segel_kondisi'],
        tangkiPeka: formMap['tangki_peka'],
        segelTangkiAtas: formMap['segel_tangki_atas'],
        segelTangkiBawah: formMap['segel_tangki_bawah'],

        dateInbound: formMap['date_inbound'],

        manualTankDetailsJson: formMap['manual_tank_details'],
        iotTankDetailsJson: formMap['iot_tank_details'],

        pathFotoDoc: adminData['path_foto_doc'],
        pathFotoDepan: adminData['path_foto_depan'],
        pathFotoSamping: adminData['path_foto_samping'],
        userName: auth.user.username,
      );

      // 2. Buat Transaction Model Utama
      final newTransaction = TransactionModel(
        noBast: noBastResult,
        dateCreated: DateTime.now().toIso8601String(),
        status: 'pengisian_solar', // Status selanjutnya
        dataSebelum: dataSebelum, // Attach detail sebelum
        // dataSesudah masih null
      );

      // 3. Simpan ke Hive
      final outstandingService = OutstandingService(auth.user.username);
      await outstandingService.saveTransaction(newTransaction);

      String manualJson = jsonEncode(manualDataToSubmit);
      String iotJson = jsonEncode(currentIotSnapshot);

      var trx = await outstandingService.getTransactionByNoBast(noBastResult);
      if (trx != null && trx.dataSebelum != null) {
        trx.dataSebelum!.manualTankDetailsJson = manualJson;
        trx.dataSebelum!.iotTankDetailsJson = iotJson;
        await trx.save();
      }

      await _draftService.deleteDraftBefore();
      Get.back();

      Get.offNamed(
          Routes.PENGISIAN_SOLAR,
          arguments: {
            'noBast': noBastResult,
            'noPO': adminData['purch_no'],
            'noPolisi': adminData['nopol_vendor'],
            'manual_json_backup': jsonEncode(manualDataToSubmit),
            'iot_json_backup': jsonEncode(currentIotSnapshot),
            'tanggal': adminData['date_inbound'],
            'status': 'pengisian_solar',
          }
      );

    } catch (e) {
      Get.back();

      String errorMessage = "";
      String rawError = e.toString();

      if (rawError.contains("Timeout") || rawError.contains("time out")) {
        errorMessage = "Server tidak merespon (RTO). Silakan coba kirim ulang.";
      }
      else if (rawError.contains("SocketException") || rawError.contains("Connection refused") || rawError.contains("Network is unreachable")) {
        errorMessage = "Gagal terhubung. Periksa koneksi internet Anda atau server sedang offline.";
      }
      else if (rawError.contains("500")) {
        errorMessage = "Terjadi gangguan pada server pusat (Error 500). Hubungi admin.";
      } else {
        errorMessage = rawError.replaceAll(RegExp(r'(Exception:|Error:)'), '').trim();

        if (errorMessage.length > 150) {
          errorMessage = "${errorMessage.substring(0, 150)}...";
        }
      }

      Get.snackbar(
          "Gagal Submit",
          errorMessage,
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error_outline, color: Colors.white)
      );

      print("Error Submit Debug: $e");

    } finally {
      isSubmitting.value = false;
    }
  }

  String get _currentStorageCode => _getStorageCode(selectedStorage.value);

  String _getStorageCode(String full) {
    return full.split(' - ').length > 1 ? full.split(' - ').last : full;
  }

  @override
  void onClose() {
    _debounceTimers.forEach((key, timer) => timer.cancel());

    manualInputControllers.forEach((key, value) {
      value['volume']?.dispose();
      value['height']?.dispose();
    });
    super.onClose();
  }

  void updateLastSyncTime() {
    final now = DateTime.now();
    final dayName = TextConvertHelper().getDayName(now.weekday);
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

      await _sensorService.initSensorBox(username);
      await _fuelDataService.openFuelDataBox(username);

      // Ambil data storage lokal
      final existingStorages = _fuelDataService.getLocalStorages();

      // Mapping nama storage ke dropdown
      storageLocations.assignAll(
          existingStorages
              .expand((unit) => unit.masterStorage)
              .where((s) => s.storageStatus == 'Y')
              .map((s) => "${s.namaStorage} - ${s.kodeStorage}")
              .toList()
      );

      // Set default storage jika ada
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