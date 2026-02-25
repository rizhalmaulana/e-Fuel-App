import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart'; // Tambahkan Import Ini
import 'package:e_fuel/modules/master_flow_process/services/flow_process_service.dart';
import 'package:e_fuel/modules/penerimaan/repositories/penerimaan_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_fonts.dart';
import '../../../datas/constant/value_key_static.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart'; // Import Model
import '../../../datas/models/widgets/penerimaan_step.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';

class PenerimaanController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final FlowProcessService _stepService = Get.find<FlowProcessService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>(); // Inject Service Data

  late PenerimaanRepository _repository;

  RxList<PenerimaanStep> get masterSteps => _stepService.steps;
  RxInt get currentStepId => _stepService.currentStepId;
  RxString get progressTitle => _stepService.currentStepTitle;

  final Map<String, Timer> _debounceTimers = {};
  Map<String, dynamic> administrativeData = {};

  final isRefreshing = false.obs;
  final lastSyncTime = ''.obs;
  final selectedStorage = 'Pilih Lokasi Storage'.obs;
  final storageLocations = <String>[].obs;
  final isSubmitting = false.obs;

  final isSensorApiActive = false.obs;

  final totalVolumeIoT = 0.0.obs;
  final tankListIoT = <Map<String, dynamic>>[].obs;

  final totalVolumeManualSnapshot = 0.0.obs;
  final tankListManualSnapshot = <Map<String, dynamic>>[].obs;

  final manualInputControllers = <String, Map<String, TextEditingController>>{}.obs;
  final manualTotalVolume = 0.0.obs;
  final headerPageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
    updateLastSyncTime();

    ever(selectedStorage, (val) {
      if(val != 'Pilih Lokasi Storage') _calculateAllData(val);
    });
  }

  void _initializeRepository() {
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _repository = PenerimaanRepository(auth.user.username);
      _loadInitialData();
    } else {
      _loginService.initializeSessionFromHive().then((success) {
        if (success) {
          final newAuth = _loginService.getCurrentAuth();
          _repository = PenerimaanRepository(newAuth!.user.username);
          _loadInitialData();
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      });
    }
  }

  Future<void> _loadInitialData() async {
    final storages = _repository.getAvailableStorages();
    storageLocations.assignAll(storages);

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('is_new_transaction') && args['is_new_transaction'] == true) {
        administrativeData = args['administrative_data'];
        if (administrativeData.containsKey('storage_code')) {
          final argStorage = administrativeData['storage_code'];
          selectedStorage.value = storageLocations.firstWhere(
                  (s) => s.contains(argStorage),
              orElse: () => argStorage
          );
        }
      }
    } else if (storageLocations.isNotEmpty && selectedStorage.value == 'Pilih Lokasi Storage') {
      selectedStorage.value = storageLocations.first;
    }

    await _checkAndRestoreDraft();

    // AUTO REFRESH IoT SAAT MASUK HALAMAN
    await refreshData();
  }

  Future<void> _checkAndRestoreDraft() async {
    final draft = await _repository.getDraft();

    if (draft != null && draft.storageCode == _getStorageCode(selectedStorage.value)) {
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

    try {
      final authData = _loginService.getCurrentAuth();

      // SIMULASI API SENSOR
      bool apiCallSuccess = false; // Set false untuk simulasi manual input

      if (apiCallSuccess && authData?.currentKodeUnit != null) {
        isSensorApiActive.value = true;
        await _repository.refreshSensorData(
            unitId: authData!.currentKodeUnit!,
            storageCode: _currentStorageCode
        );

        // Refresh UI berdasarkan data baru
        _calculateAllData(selectedStorage.value);
        Get.snackbar("Sukses", "Data sensor berhasil diperbarui",
            backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } else {
        isSensorApiActive.value = false;
        // Tetap lakukan kalkulasi ulang untuk memastikan data manual ter-load
        _calculateAllData(selectedStorage.value);
        Get.snackbar("Koneksi Sensor", "Gagal terhubung ke sensor. Mode input manual aktif.",
            backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      }

      updateLastSyncTime();

    } catch (e) {
      debugPrint("Refresh Error: $e");
      isSensorApiActive.value = false;
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> _calculateAllData(String storageName) async {
    String storageCode = _getStorageCode(storageName);
    final authData = _loginService.getCurrentAuth();

    // Cek Memory Sensor (Prioritas Utama)
    var activeTanks = _repository.getLocalSensorData(storageCode);

    // Jika Memory Kosong, Cek Cache Lokal (FuelDataService - Master Data)
    // Ini perbaikan utamanya: Ambil data master tangki yang tersimpan di Hive
    if (activeTanks.isEmpty) {
      final cachedTanks = _fuelDataService.getApiManualTanks();
      // Filter sesuai storage yang dipilih
      activeTanks = cachedTanks.where((t) => t.masterStorage?.kodeStorage == storageCode).toList();

      // Update Memory Repository agar sinkron
      if (activeTanks.isNotEmpty) {
        _repository.updateLocalSensorData(activeTanks, storageCode);
      }
    }

    // Jika Cache Masih Kosong & Ada Koneksi, Tarik dari API Master Data
    if (activeTanks.isEmpty && authData?.currentKodeUnit != null) {
      isRefreshing.value = true;
      try {
        final apiTanks = await _repository.fetchMasterTankDetail(
            authData!.currentKodeUnit!,
            storageCode
        );

        if (apiTanks.isNotEmpty) {
          _repository.updateLocalSensorData(apiTanks, storageCode);
          activeTanks = apiTanks;

          // Simpan ke Cache Lokal untuk penggunaan offline berikutnya
          // Note: Logic saveApiManualTanks di service menimpa data lama,
          // idealnya kita append, tapi untuk sekarang cukup.
          // _fuelDataService.saveApiManualTanks(apiTanks);
        }
      } catch (e) {
        debugPrint("Master Tank Load Error: $e");
      } finally {
        isRefreshing.value = false;
      }
    }

    // Update UI dengan List yang PASTI sudah terisi (atau kosong jika memang data server 0)
    _calculateIoTData(activeTanks);
    _calculateManualSnapshotData(activeTanks);
    _initializeInputForms(activeTanks);
  }

  // Refactor: Menerima List langsung agar tidak query ulang
  void _calculateIoTData(List<VolumeTankDetailModel> tanks) {
    tanks.sort((a, b) => (a.masterSolarTank?.kodeTank ?? '').compareTo(b.masterSolarTank?.kodeTank ?? ''));

    double tempTotal = 0.0;
    List<Map<String, dynamic>> tempList = [];

    for (var tank in tanks) {
      double vol = tank.volume ?? 0.0;
      double h = tank.height ?? 0.0;
      tempTotal += vol;

      tempList.add({
        'code': (tank.masterSolarTank?.kodeTank ?? '').replaceAll('_', ' '),
        'volume': vol,
        'height': h,
        'last_update': 'Live'
      });
    }
    totalVolumeIoT.value = tempTotal;
    tankListIoT.assignAll(tempList);
  }

  // Refactor: Menerima List langsung
  void _calculateManualSnapshotData(List<VolumeTankDetailModel> tanks) {
    tanks.sort((a, b) => (a.masterSolarTank?.kodeTank ?? '').compareTo(b.masterSolarTank?.kodeTank ?? ''));

    List<Map<String, dynamic>> tempList = [];

    for (var tank in tanks) {
      String tankCode = tank.masterSolarTank?.kodeTank ?? '';

      // Ambil data snapshot terakhir user (jika ada)
      final manualState = _repository.getManualTankInput(tankCode);
      double vol = manualState['volume']!;
      double h = manualState['height']!;

      tempList.add({
        'code': tankCode.replaceAll('_', ' '),
        'volume': vol,
        'height': h,
      });
    }
    tankListManualSnapshot.assignAll(tempList);
  }

  // Refactor: Menerima List langsung
  void _initializeInputForms(List<VolumeTankDetailModel> tanks) {
    for (var tank in tanks) {
      String tankCode = tank.masterSolarTank?.kodeTank ?? '';
      String formattedCode = tankCode.replaceAll('_', ' ');
      int tankCapacity = 10000; // Bisa diambil dari model jika ada

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
        final literResult = await _repository.getLiterFromCalibration(capacity, heightMm);
        if (literResult != null) {
          volCtrl.text = TextConvertHelper().formatNumber(literResult);
        }
      }
    });
  }

  bool _validateInputs() {
    if (isSensorApiActive.value) return true;

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
        message: isSensorApiActive.value
            ? "Data akan diambil otomatis dari sensor. Lanjutkan?"
            : "Apakah Anda yakin data pengukuran tangki sudah benar?",
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

  Future<void> submitFinalTransaction() async {
    if (isSubmitting.value) return;
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
              Text("Mengirim Data", style: AppFonts.fUrbanistBold16),
              const SizedBox(height: 8),
              Text("Mohon tunggu...", style: AppFonts.fUrbanistRegular12),
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
      List<Map<String, dynamic>> iotDataToSubmit = [];

      final activeTanks = _repository.getLocalSensorData(_currentStorageCode);

      if (isSensorApiActive.value) {
        iotDataToSubmit = activeTanks.map((e) => {
          'tank_code': e.masterSolarTank?.kodeTank ?? '',
          'volume_iot': e.volume,
          'height_iot': e.height,
        }).toList();

        manualDataToSubmit = activeTanks.map((e) => {
          'tank_code': e.masterSolarTank?.kodeTank ?? '',
          'volume_manual': e.volume,
          'height_manual': e.height,
        }).toList();

      } else {
        for (var tank in tankListManualSnapshot) {
          String code = tank['code']!;
          var controllers = manualInputControllers[code];
          if (controllers != null) {
            double vol = double.tryParse(controllers['volume']!.text.replaceAll('.', '')) ?? 0.0;
            double height = double.tryParse(controllers['height']!.text.replaceAll(',', '.')) ?? 0.0;

            manualDataToSubmit.add({
              'tank_code': code.replaceAll(' ', '_'),
              'volume_manual': vol,
              'height_manual': height,
            });
          }
        }

        iotDataToSubmit = activeTanks.map((e) => {
          'tank_code': e.masterSolarTank?.kodeTank ?? '',
          'volume_iot': e.volume,
          'height_iot': e.height,
        }).toList();
      }

      String rawStorage = selectedStorage.value;
      String finalStorageCode = _getStorageCode(rawStorage);
      final adminData = administrativeData;

      final Map<String, dynamic> formMap = {
        'doc_type_code': ValueKeyStatic.CODE_TRANSACTION_PENERIMAAN,
        'kode_unit': auth.currentKodeUnit ?? "",
        'storage_code': finalStorageCode,
        'purch_no': adminData['purch_no'],
        'vendor_spb': adminData['vendor_spb'],
        'input_type': (isSensorApiActive.value) ? "A" : "M",
        'volume_vendor': adminData['volume_vendor'] ?? 0,
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
        'selisih_vol_tera': adminData['selisih_vol_tera'] ?? 0,
        'date_inbound': adminData['date_inbound'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'dtime_before': adminData['dtime_before'] ?? DateTime.now().toIso8601String(),
        'iot_tank_details': jsonEncode(iotDataToSubmit),
        'manual_tank_details': jsonEncode(manualDataToSubmit),
        'volume_terkini_liter': 0,
      };

      List<File?> filesToUpload = [
        adminData['path_foto_doc'] != null ? File(adminData['path_foto_doc']) : null,
        adminData['path_foto_depan'] != null ? File(adminData['path_foto_depan']) : null,
        adminData['path_foto_samping'] != null ? File(adminData['path_foto_samping']) : null,
      ];

      final responseData = await _repository.submitTransaction(formMap, filesToUpload);
      String noBastResult = responseData['no_doc'] ?? "-";

      final dataSebelum = PenerimaanSebelumModel(
        docTypeCode: formMap['doc_type_code'],
        kodeUnit: formMap['kode_unit'],
        storageCode: rawStorage,
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
        selisihVolumeTerra: TextConvertHelper().parseToDouble(formMap['selisih_vol_tera']),
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

      final newTransaction = TransactionModel(
        noBast: noBastResult,
        dateCreated: DateTime.now().toIso8601String(),
        status: 'pengisian_solar',
        dataSebelum: dataSebelum,
      );

      await _repository.saveLocalTransaction(newTransaction);
      await _repository.updateLocalTransactionDetails(noBastResult, manualDataToSubmit, iotDataToSubmit);
      await _repository.deleteDraft();

      Get.back();

      Get.offNamed(
          Routes.PENGISIAN_SOLAR,
          arguments: {
            'noBast': noBastResult,
            'noPO': adminData['purch_no'],
            'noPolisi': adminData['nopol_vendor'],
            'manual_json_backup': jsonEncode(manualDataToSubmit),
            'iot_json_backup': jsonEncode(iotDataToSubmit),
            'tanggal': adminData['date_inbound'],
            'status': 'pengisian_solar',
            'storage_code': finalStorageCode,
          }
      );

    } catch (e) {
      Get.back();
      _handleError(e);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _handleError(Object e) {
    String errorMessage = e.toString();

    if (errorMessage.contains("Timeout") || errorMessage.contains("time out")) {
      errorMessage = "RTO: Server tidak merespon.";
    } else if (errorMessage.contains("SocketException")) {
      errorMessage = "Koneksi internet bermasalah.";
    } else {
      errorMessage = errorMessage.replaceAll(RegExp(r'(Exception:|Error:)'), '').trim();
      if (errorMessage.length > 100) errorMessage = "${errorMessage.substring(0, 100)}...";
    }

    Get.snackbar(
        "Gagal Submit",
        errorMessage,
        backgroundColor: AppColors.alertSoftRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: Colors.white)
    );
  }

  String _getStorageCode(String full) {
    return full.split(' - ').length > 1 ? full.split(' - ').last.trim() : full.trim();
  }

  String get _currentStorageCode => _getStorageCode(selectedStorage.value);

  void updateLastSyncTime() {
    final now = DateTime.now();
    final dayName = TextConvertHelper().getDayName(now.weekday);
    final formattedDate = DateFormat('dd MMM yyyy').format(now);
    final formattedHour = DateFormat('HH:mm:ss').format(now);
    lastSyncTime.value = "$dayName, $formattedDate pukul $formattedHour";
  }

  @override
  void onClose() {
    _debounceTimers.forEach((_, timer) => timer.cancel());
    manualInputControllers.forEach((_, value) {
      value['volume']?.dispose();
      value['height']?.dispose();
    });
    super.onClose();
  }
}