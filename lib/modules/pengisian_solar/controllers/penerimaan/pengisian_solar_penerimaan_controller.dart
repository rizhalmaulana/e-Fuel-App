import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../routes/app_pages.dart';
import '../../../auth/services/login_service.dart';
import '../../repositories/penerimaan/pengisian_solar_penerimaan_repository.dart';

class PengisianSolarPenerimaanController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();

  // Ubah ke Repository yang baru
  late PengisianSolarPenerimaanRepository _repository;

  // Data Dokumen
  final noBast = '-'.obs;
  final noPO = '-'.obs;
  final noPolisi = '-'.obs;
  final tanggal = '-'.obs;
  final status = '-'.obs;
  final waktuSounding  = '-'.obs;

  // Data Volume
  final initialVolume = 0.0.obs;
  final currentVolume = 0.0.obs;
  final volumeVendor = 0.0.obs;

  // State
  final isRefreshingSensor = false.obs;
  final lastUpdateSensor = '-'.obs;


  String? manualJsonBackup;
  String? iotJsonBackup;
  String activeStorageCode = "";

  @override
  void onInit() {
    super.onInit();

    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _repository = PengisianSolarPenerimaanRepository(auth.user.username);
    }

    _loadArguments();
    refreshSensorMonitoring();
  }

  void _loadArguments() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    noBast.value = args['noBast'] ?? '-';
    noPO.value = args['noPO'] ?? '-';
    noPolisi.value = args['noPolisi'] ?? '-';
    tanggal.value = args['tanggal'] ?? '-';
    status.value = args['status'] ?? 'pengisian_solar';
    waktuSounding.value = args['waktu_sounding'] ?? '-';
    manualJsonBackup = args['manual_json_backup'];
    iotJsonBackup = args['iot_json_backup'];
    activeStorageCode = args['storage_code'] ?? "";

    // Hitung volume awal
    _calculateInitialVolume();

    // Set current volume sama dengan initial dulu
    currentVolume.value = initialVolume.value;
  }

  void _calculateInitialVolume() {
    try {
      double total = 0;
      bool useManualData = false;

      debugPrint("Json Manual: $manualJsonBackup");
      debugPrint("Json IoT: $iotJsonBackup");

      if (manualJsonBackup != null && manualJsonBackup!.isNotEmpty) {
        List<dynamic> list = jsonDecode(manualJsonBackup!);

        if (list.isNotEmpty) {
          for (var item in list) {
            if (item['volume_manual'] != null) {
              total += (item['volume_manual'] as num).toDouble();
            }
          }

          if (total > 0) {
            useManualData = true;
          }
        }
      }

      if (!useManualData && iotJsonBackup != null && iotJsonBackup!.isNotEmpty) {
        total = 0;
        List<dynamic> list = jsonDecode(iotJsonBackup!);
        for (var item in list) {
          if (item['volume_iot'] != null) {
            total += (item['volume_iot'] as num).toDouble();
          } else if (item['volume'] != null) {
            total += (item['volume'] as num).toDouble();
          }
        }
      }

      initialVolume.value = total;

    } catch (e) {
      print("Error parsing initial volume: $e");
    }
  }

  Future<void> refreshSensorMonitoring() async {
    if (isRefreshingSensor.value) return;
    isRefreshingSensor.value = true;

    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final auth = _loginService.getCurrentAuth();

      if (auth?.currentKodeUnit != null && activeStorageCode.isNotEmpty) {
        await _repository.getDetailTanks(
            unitId: auth!.currentKodeUnit!,
            storageCode: activeStorageCode
        );

        final stockStorageData = await _repository.getDataStockStorage(
            unitId: auth.currentKodeUnit!,
            storageCode: activeStorageCode,
            dateLog: today
        );

        if (stockStorageData.totalStockVolume != 0) {
          currentVolume.value = stockStorageData.totalStockVolume;
          lastUpdateSensor.value = DateFormat('yyyy-MM-dd HH:MM:ss').format(DateTime.now());
        } else {
          currentVolume.value = 0.0;
          lastUpdateSensor.value = DateFormat('yyyy-MM-dd HH:MM:ss').format(DateTime.now());
        }
      }
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print("Gagal refresh sensor: $e");
    } finally {
      isRefreshingSensor.value = false;
    }
  }

  Future<void> saveAndExit() async {
    if (noBast.value != '-') {
      try {
        // Panggil update status melalui Repository baru
        await _repository.updateTransactionStatus(noBast.value, 'pengisian_solar');
      } catch (e) {
        print("Error saving exit status: $e");
      }
    }
    Get.offAllNamed(Routes.HOME);
  }

  Future<void> finishTransaction() async {
    if (noBast.value == '-') {
      _goToNextPage();
      return;
    }

    try {
      await _repository.updateTransactionStatus(noBast.value, 'setelah_pengisian');
    } catch (e) {
      print("Error update status pengisian: $e");
    }

    _goToNextPage();
  }

  void _goToNextPage() {
    Get.offAllNamed(
        Routes.PENERIMAAN_SETELAH,
        arguments: {
          'noBast': noBast.value,
          'noPO': noPO.value,
          'manual_json_backup': manualJsonBackup,
          'iot_json_backup': iotJsonBackup,
        }
    );
  }
}