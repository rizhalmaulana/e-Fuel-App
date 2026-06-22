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
import '../../../widgets/component/custom_snackbar.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_fonts.dart';
import '../../../datas/constant/value_key_static.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart'; // Import Model
import '../../../datas/models/widgets/penerimaan_step.dart';
import '../../../helpers/calibration_helper.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/master_data_service.dart';

class PenerimaanController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final FlowProcessService _stepService = Get.find<FlowProcessService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final MasterDataService _masterDataService = MasterDataService();

  late PenerimaanRepository _repository;
  RxList<PenerimaanStep> get masterSteps => _stepService.steps;
  RxInt get currentStepId => _stepService.currentStepId;
  RxString get progressTitle => _stepService.currentStepTitle;

  final Map<String, Timer> _debounceTimers = {};
  Map<String, dynamic> administrativeData = {};

  final activeTanks = <VolumeTankDetailModel>[].obs;
  String _currentStorageCode = '';
  String selectedUnitCode = '';

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

  bool _isInjectingApiData = false;

  @override
  void onInit() {
    super.onInit();
    _loadInitialContext();
    _initializeRepository();
    updateLastSyncTime();
  }

  void _initializeRepository() {
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _fuelDataService.openFuelDataBox(auth.user.username);
      _repository = PenerimaanRepository(auth.user.username);
      _initializeData();
      _loadInitialData();
    } else {
      _loginService.initializeSessionFromHive().then((success) {
        if (success) {
          final newAuth = _loginService.getCurrentAuth();
          _repository = PenerimaanRepository(newAuth!.user.username);
          _initializeData();
          _loadInitialData();
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      });
    }
  }

  void updateLastSyncTime() {
    final now = DateTime.now();
    lastSyncTime.value =
    "${TextConvertHelper().getDayName(now.weekday)}, "
        "${DateFormat('dd MMM yyyy').format(now)} "
        "pukul ${DateFormat('HH:mm:ss').format(now)}";
  }

  void _loadInitialContext() {
    final auth = _loginService.getCurrentAuth();
    selectedUnitCode = auth?.currentKodeUnit ?? '';

    if (Get.arguments != null) {
      final args = Get.arguments as Map;

      if (args.containsKey('administrative_data')) {
        administrativeData = Map<String, dynamic>.from(args['administrative_data']);
        _currentStorageCode = administrativeData['storage_code'] ?? '';
      }

      if (_currentStorageCode.isEmpty && args.containsKey('storage_code')) {
        _currentStorageCode = args['storage_code'] ?? '';
      }
    }

    if (_currentStorageCode == 'Pilih Lokasi Storage' || _currentStorageCode.isEmpty) {
      debugPrint("⚠️ Storage Code Invalid. Mencoba ambil dari Local Service...");
      _currentStorageCode = _fuelDataService.getLastSelectedStorageCode();
    }

    debugPrint("✅ _loadInitialContext → unit='$selectedUnitCode' storage='$_currentStorageCode'");
  }

  void _initializeData() {
    if (_currentStorageCode.isEmpty) return;

    final cached = _fuelDataService.getApiManualTanks()
        .where((t) => t.masterStorage?.kodeStorage == _currentStorageCode)
        .toList();

    if (cached.isNotEmpty) {
      activeTanks.assignAll(cached);
      _initializeInputForms(cached);
      _buildSnapshotFromTanks(cached);
      debugPrint("📦 Cache: ${cached.length} tangki dari '$_currentStorageCode'");
    }
  }

  Future<void> _loadInitialData() async {
    final storages = _repository.getAvailableStorages();
    storageLocations.assignAll(storages);

    // Fallback: jika _currentStorageCode masih kosong, ambil dari last selected storage
    if (_currentStorageCode.isEmpty) {
      final lastStorage = _fuelDataService.getLastSelectedStorage();
      if (lastStorage.isNotEmpty) {
        _currentStorageCode = _getStorageCode(lastStorage);
        selectedStorage.value = lastStorage;
        debugPrint("📀 Fallback ke last selected storage: $_currentStorageCode");
      }
    }

    // Pastikan selectedUnitCode juga terisi
    if (selectedUnitCode.isEmpty) {
      final auth = _loginService.getCurrentAuth();
      selectedUnitCode = auth?.currentKodeUnit ?? '';
      debugPrint("🔄 Ambil unit code dari auth: $selectedUnitCode");
    }

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['is_new_transaction'] == true) {
        if (args.containsKey('administrative_data')) {
          administrativeData = Map<String, dynamic>.from(args['administrative_data']);
        }
        final argStorage = administrativeData['storage_code'] as String? ?? '';
        if (argStorage.isNotEmpty) {
          _currentStorageCode = argStorage;
          selectedStorage.value = storageLocations.firstWhere(
                (s) => s.contains(argStorage),
            orElse: () => argStorage,
          );
        }
      }
    } else if (storageLocations.isNotEmpty &&
        selectedStorage.value == 'Pilih Lokasi Storage') {
      selectedStorage.value = storageLocations.first;
    }

    // Pastikan _currentStorageCode terisi jika masih kosong
    if (_currentStorageCode.isEmpty) {
      _currentStorageCode = _getStorageCode(selectedStorage.value);
    }

    debugPrint("🏭 _loadInitialData → storage='$_currentStorageCode' unit='$selectedUnitCode'");

    await _checkAndRestoreDraft();
    await refreshData();
  }

  Future<void> _checkAndRestoreDraft() async {
    final draft = await _repository.getDraft();
    if (draft == null) return;
    if (draft.storageCode != _getStorageCode(selectedStorage.value)) return;
    if (draft.manualTankDetailsJson == null) return;

    try {
      final list = jsonDecode(draft.manualTankDetailsJson!) as List;
      for (final item in list) {
        final String code = (item['tank_code'] as String).replaceAll('_', ' ');
        if (manualInputControllers.containsKey(code)) {
          manualInputControllers[code]?['volume']?.text = item['volume_manual'].toString();
          manualInputControllers[code]?['height']?.text = item['height_manual'].toString();
        }
      }
      _updateManualTotalVolume();
    } catch (e) {
      debugPrint("Gagal restore draft: $e");
    }
  }

  Future<void> refreshData() async {
    debugPrint("🔄 refreshData() unit='$selectedUnitCode' storage='$_currentStorageCode'");

    if (selectedUnitCode.isEmpty) {
      final auth = _loginService.getCurrentAuth();
      selectedUnitCode = auth?.currentKodeUnit ?? '';
      if (selectedUnitCode.isEmpty) {
        debugPrint("❌ selectedUnitCode masih kosong, tidak bisa refresh.");
        return;
      }
    }
    if (_currentStorageCode.isEmpty) {
      final lastStorage = _fuelDataService.getLastSelectedStorage();
      if (lastStorage.isNotEmpty) {
        _currentStorageCode = _getStorageCode(lastStorage);
        selectedStorage.value = lastStorage;
        debugPrint("📀 refreshData: pakai last storage $_currentStorageCode");
      } else {
        debugPrint("❌ _currentStorageCode kosong, tidak bisa refresh.");
        return;
      }
    }

    isRefreshing.value = true;
    try {
      // Step 1: Ambil master tangki jika belum ada
      if (activeTanks.isEmpty) {
        debugPrint("📡 Fetching master tanks...");
        final masterTanks = await _masterDataService.getTankDetailFromStorage(
          unitId: selectedUnitCode,
          storageId: _currentStorageCode,
        );

        debugPrint("📡 Master tanks diterima: ${masterTanks.length}");

        if (masterTanks.isEmpty) {
          debugPrint("⚠️ Tidak ada master tank untuk storage '$_currentStorageCode'");
          isSensorApiActive.value = false;
          return;
        }

        activeTanks.assignAll(masterTanks);
        _initializeInputForms(masterTanks);
        _buildSnapshotFromTanks(masterTanks);
        await _fuelDataService.saveApiManualTanks(masterTanks);
      }

      // Step 2: Ambil stok terbaru per tangki
      final bool success = await _fetchAndFillLatestStock(selectedUnitCode, activeTanks);
      isSensorApiActive.value = success;

      if (!success) {
        // Sensor mati: tampilkan data dari master sebagai snapshot awal
        _buildSnapshotFromTanks(activeTanks);
        debugPrint("ℹ️ Sensor API tidak aktif → mode manual");
      }

      updateLastSyncTime();
    } catch (e) {
      debugPrint("❌ refreshData error: $e");
      isSensorApiActive.value = false;
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<bool> _fetchAndFillLatestStock(
      String unitId,
      List<VolumeTankDetailModel> tanks,
      ) async {
    if (tanks.isEmpty) return false;

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool anyDataFound = false;
    double totalVolume = 0.0;

    final sorted = _sortTanksByCode(
      List<VolumeTankDetailModel>.from(tanks),
          (t) => t.masterSolarTank?.kodeTank ?? '',
    );

    final List<Map<String, dynamic>> results =
    List.filled(sorted.length, <String, dynamic>{});

    _isInjectingApiData = true;

    await Future.wait(sorted.asMap().entries.map((entry) async {
      final int idx = entry.key;
      final VolumeTankDetailModel tank = entry.value;

      final String tankCode = tank.masterSolarTank?.kodeTank ?? '';
      final String formattedKey = tankCode.replaceAll('_', ' ');
      final int capacity = tank.capacity;

      double vol = 0.0;
      double height = 0.0;

      final stockData = await _repository.fetchLatestTankStock(
        unitId: unitId,
        tankCode: tankCode,
        dateLog: today,
      );

      debugPrint("📊 Stock[$tankCode]: $stockData");

      if (stockData != null) {
        anyDataFound = true;

        vol = _toDouble(stockData['stock_volume']) ??
            _toDouble(stockData['volume']) ??
            0.0;

        height = _toDouble(stockData['tinggi']) ??
            _toDouble(stockData['height']) ??
            0.0;

        if (height == 0 && vol > 0) {
          height = CalibrationHelper.getHeightByVolume(capacity, vol).toDouble();
          debugPrint("🔄 Reverse height $tankCode: ${height.toInt()} mm");
        }
      }

      results[idx] = {
        'code': formattedKey,
        'volume': vol,
        'height': height,
        'capacity': capacity,
      };

      // Isi controller secara "silent" agar tidak memicu listener kalibrasi
      if (manualInputControllers.containsKey(formattedKey)) {
        final ctrls = manualInputControllers[formattedKey]!;
        _silentSetText(ctrls['volume']!, TextConvertHelper().formatNumber(vol));
        _silentSetText(ctrls['height']!, height > 0 ? height.toInt().toString() : '');
      }
    }));

    _isInjectingApiData = false;

    final validResults = results.where((e) => e.isNotEmpty).toList();
    for (final r in validResults) {
      totalVolume += (r['volume'] as num).toDouble();
    }

    totalVolumeIoT.value = totalVolume;
    tankListIoT.assignAll(validResults);
    tankListManualSnapshot.assignAll(validResults);
    _updateManualTotalVolume();

    debugPrint("✅ Fetch selesai: found=$anyDataFound total=$totalVolume tank=${validResults.length}");
    return anyDataFound;
  }

  void _buildSnapshotFromTanks(List<VolumeTankDetailModel> tanks) {
    final sorted = _sortTanksByCode(
      List<VolumeTankDetailModel>.from(tanks),
          (t) => t.masterSolarTank?.kodeTank ?? '',
    );

    tankListManualSnapshot.assignAll(sorted.map((t) => {
      'code': (t.masterSolarTank?.kodeTank ?? '').replaceAll('_', ' '),
      'volume': t.volume,
      'height': t.height,
      'capacity': t.capacity,
    }).toList());

    _updateManualTotalVolume();
  }

  // void _calculateIoTData(List<VolumeTankDetailModel> tanks) {
  //   final sortedTanks = _sortTanksByCode(tanks, (t) => t.masterSolarTank?.kodeTank ?? '');
  //   double tempTotal = 0.0;
  //   List<Map<String, dynamic>> tempList = [];
  //   for (var tank in sortedTanks) {
  //     double vol = tank.volume ?? 0.0;
  //     double h = tank.height ?? 0.0;
  //     tempTotal += vol;
  //     tempList.add({
  //       'code': (tank.masterSolarTank?.kodeTank ?? '').replaceAll('_', ' '),
  //       'volume': vol,
  //       'height': h,
  //       'last_update': 'Live'
  //     });
  //   }
  //   totalVolumeIoT.value = tempTotal;
  //   tankListIoT.assignAll(tempList);
  // }

  // void _calculateManualSnapshotData(List<VolumeTankDetailModel> tanks) {
  //   tanks.sort((a, b) => (a.masterSolarTank?.kodeTank ?? '').compareTo(b.masterSolarTank?.kodeTank ?? ''));
  //   List<Map<String, dynamic>> tempList = [];
  //   for (var tank in tanks) {
  //     String tankCode = tank.masterSolarTank?.kodeTank ?? '';
  //     final manualState = _repository.getManualTankInput(tankCode);
  //     double vol = manualState['volume']!;
  //     double h = manualState['height']!;
  //     tempList.add({
  //       'code': tankCode.replaceAll('_', ' '),
  //       'volume': vol,
  //       'height': h,
  //     });
  //   }
  //   tankListManualSnapshot.assignAll(tempList);
  // }

  void _initializeInputForms(List<VolumeTankDetailModel> tanks) {
    final sorted = _sortTanksByCode(
      List<VolumeTankDetailModel>.from(tanks),
          (t) => t.masterSolarTank?.kodeTank ?? '',
    );

    for (final tank in sorted) {
      final String tankCode = tank.masterSolarTank?.kodeTank ?? '';
      final String key = tankCode.replaceAll('_', ' ');
      final int cap = tank.capacity;

      if (!manualInputControllers.containsKey(key)) {
        final volCtrl = TextEditingController();
        final heightCtrl = TextEditingController();

        volCtrl.addListener(_updateManualTotalVolume);
        heightCtrl.addListener(() {
          if (!isSensorApiActive.value && !_isInjectingApiData) {
            _onHeightInputChanged(key, heightCtrl.text, volCtrl, cap);
          }
        });

        manualInputControllers[key] = {'volume': volCtrl, 'height': heightCtrl};
      }
    }
    _updateManualTotalVolume();
  }

  void _onHeightInputChanged(
      String key,
      String heightText,
      TextEditingController volCtrl,
      int capacity,
      ) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(milliseconds: 800), () async {
      if (isSensorApiActive.value) return;

      final String clean = heightText.replaceAll('.', '').replaceAll(',', '.');
      if (clean.isEmpty) {
        _silentSetText(volCtrl, '');
        _updateManualTotalVolume();
        return;
      }

      final double? mm = double.tryParse(clean);
      if (mm == null || mm <= 0) return;

      try {
        double? liter = await _repository.getLiterFromCalibration(capacity, mm);
        liter ??= CalibrationHelper.getVolumeByHeight(capacity, mm.toInt());

        if (liter > 0) {
          _silentSetText(volCtrl, TextConvertHelper().formatNumber(liter));
          debugPrint("📐 Kalibrasi '$key': ${mm.toInt()} mm → ${liter.toStringAsFixed(1)} L");

          final int idx = tankListManualSnapshot.indexWhere((t) => t['code'] == key);
          if (idx != -1) {
            final updated = Map<String, dynamic>.from(tankListManualSnapshot[idx]);
            updated['volume'] = liter;
            updated['height'] = mm;
            tankListManualSnapshot[idx] = updated;
          }
        }
      } catch (e) {
        debugPrint("⚠️ Kalibrasi error '$key': $e");
      }
      _updateManualTotalVolume();
    });
  }

  bool _validateInputs() {
    if (selectedStorage.value.isEmpty ||
        selectedStorage.value == 'Pilih Storage' ||
        selectedStorage.value == 'Pilih Lokasi Storage') {
      CustomSnackbar.show(
        title: "Terjadi kesalahan",
        message: "Silahkan pilih Storage Tank dahulu.",
        backgroundColor: AppColors.alertSoftRed,
        textColor: Colors.white,
      );
      return false;
    }

    if (isSensorApiActive.value) return true;

    for (final tank in tankListManualSnapshot) {
      final String code = tank['code']!;
      final ctrls = manualInputControllers[code];
      if (ctrls == null) continue;
      final String h = ctrls['height']!.text;
      if (h.isEmpty || h == '0') {
        CustomSnackbar.show(
          title: "Data Belum Lengkap",
          message: "Tinggi tangki $code wajib diisi.",
          backgroundColor: AppColors.alertSoftRed,
          textColor: Colors.white,
        );
        return false;
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
            ? "Apakah Sounding Stok Solar (Sensor) sudah sesuai?"
            : "Apakah Sounding Stok Solar (Manual) sudah sesuai?",
        secondaryButtonText: "Batal",
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: "Submit",
        onPrimaryPressed: () { Get.back(); submitFinalTransaction(); },
      ),
      barrierDismissible: false,
    );
  }

  void _updateManualTotalVolume() {
    double total = 0;
    manualInputControllers.forEach((_, ctrls) {
      final String v = ctrls['volume']!.text.replaceAll('.', '').replaceAll(',', '.');
      total += double.tryParse(v) ?? 0;
    });
    manualTotalVolume.value = total;
  }

  Future<void> submitFinalTransaction() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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

      List<Map<String, dynamic>> manualData = [];
      List<Map<String, dynamic>> iotData = [];

      final localTanks = _repository.getLocalSensorData(_currentStorageCode);

      if (isSensorApiActive.value) {
        iotData = tankListIoT.map((t) => {
          'tank_code': (t['code'] as String).replaceAll(' ', '_'),
          'volume_iot': t['volume'],
          'height_iot': t['height'],
        }).toList();

        manualData = iotData.map((t) => {
          'tank_code': t['tank_code'],
          'volume_manual': t['volume_iot'],
          'height_manual': t['height_iot'],
        }).toList();
      } else {
        for (final tank in tankListManualSnapshot) {
          final String code = tank['code']!;
          final ctrls = manualInputControllers[code];
          if (ctrls == null) continue;
          final double vol = double.tryParse(ctrls['volume']!.text.replaceAll('.', '')) ?? 0;
          final double h = double.tryParse(ctrls['height']!.text.replaceAll(',', '.')) ?? 0;
          manualData.add({
            'tank_code': code.replaceAll(' ', '_'),
            'volume_manual': vol,
            'height_manual': h,
          });
        }

        iotData = localTanks.map((e) => {
          'tank_code': e.masterSolarTank?.kodeTank ?? '',
          'volume_iot': e.volume,
          'height_iot': e.height,
        }).toList();
      }

      final String rawStorage = selectedStorage.value;
      final String finalStorageCode = _getStorageCode(rawStorage);
      final adminData = administrativeData;

      final Map<String, dynamic> formMap = {
        'doc_type_code': ValueKeyStatic.CODE_TRANSACTION_PENERIMAAN,
        'kode_unit': auth.currentKodeUnit ?? "",
        'storage_code': finalStorageCode,
        'purch_no': adminData['purch_no'],
        'vendor_spb': adminData['vendor_spb'],
        'input_type': isSensorApiActive.value ? "A" : "M",
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
        'iot_tank_details': jsonEncode(iotData),
        'manual_tank_details': jsonEncode(manualData),
        'volume_terkini_liter': 0,
      };

      final List<File?> files = [
        adminData['path_foto_doc'] != null ? File(adminData['path_foto_doc']) : null,
        adminData['path_foto_depan'] != null ? File(adminData['path_foto_depan']) : null,
        adminData['path_foto_samping'] != null ? File(adminData['path_foto_samping']) : null,
      ];

      final response = await _repository.submitTransaction(formMap, files);
      final String noBast = response['no_doc'] ?? "-";

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

      final trx = TransactionModel(
        noBast: noBast,
        dateCreated: DateTime.now().toIso8601String(),
        status: 'pengisian_solar',
        dataSebelum: dataSebelum,
      );

      await _repository.saveLocalTransaction(trx);
      await _repository.updateLocalTransactionDetails(noBast, manualData, iotData);
      await _repository.deleteDraft();

      Get.back();
      Get.offNamed(Routes.PENGISIAN_SOLAR, arguments: {
        'noBast': noBast,
        'noPO': adminData['purch_no'],
        'noPolisi': adminData['nopol_vendor'],
        'manual_json_backup': jsonEncode(manualData),
        'iot_json_backup': jsonEncode(iotData),
        'tanggal': adminData['date_inbound'],
        'waktu_sounding': DateFormat('yyyy-MM-dd HH:MM:ss').format(DateTime.now()),
        'status': 'pengisian_solar',
        'storage_code': finalStorageCode,
      });
    } catch (e) {
      Get.back();
      _handleError(e);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _handleError(Object e) {
    String msg = e.toString().replaceAll(RegExp(r'(Exception:|Error:)'), '').trim();
    if (msg.contains("Timeout") || msg.contains("time out")) msg = "RTO: Server tidak merespon.";
    else if (msg.contains("SocketException")) msg = "Koneksi internet bermasalah.";
    else if (msg.length > 100) msg = "${msg.substring(0, 100)}...";
    CustomSnackbar.show(
      title: "Gagal Submit",
      message: msg,
      backgroundColor: AppColors.alertSoftRed,
      textColor: Colors.white,
    );
  }

  String _getStorageCode(String full) {
    final parts = full.split(' - ');
    return parts.length > 1 ? parts.last.trim() : full.trim();
  }

  List<T> _sortTanksByCode<T>(List<T> tanks, String Function(T) getCode) {
    return List.from(tanks)..sort((a, b) {
      final int na = int.tryParse(getCode(a).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final int nb = int.tryParse(getCode(b).replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return na.compareTo(nb);
    });
  }

  /// Set teks controller tanpa memicu listener (cegah loop kalibrasi)
  void _silentSetText(TextEditingController ctrl, String value) {
    if (ctrl.text == value) return;
    ctrl.removeListener(_updateManualTotalVolume);
    ctrl.text = value;
    ctrl.selection = TextSelection.fromPosition(TextPosition(offset: value.length));
    ctrl.addListener(_updateManualTotalVolume);
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  @override
  void onClose() {
    _debounceTimers.forEach((_, t) => t.cancel());
    manualInputControllers.forEach((_, ctrls) {
      ctrls['volume']?.dispose();
      ctrls['height']?.dispose();
    });
    super.onClose();
  }
}
