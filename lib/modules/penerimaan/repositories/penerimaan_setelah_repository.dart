import 'dart:async';
import 'dart:convert';

import 'package:e_fuel/modules/fuel/services/fuel_sensor_service.dart';
import 'package:e_fuel/modules/fuel/services/master_data_service.dart';
import 'package:e_fuel/modules/transactions/outstanding_service.dart';
import 'package:get/get.dart';

import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../services/draft_penerimaan_service.dart';

class PenerimaanSetelahRepository {
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  final MasterDataService _masterDataService = MasterDataService();

  late OutstandingService _outstandingService;
  late DraftPenerimaanService _draftService;

  PenerimaanSetelahRepository(String username) {
    _outstandingService = OutstandingService(username);
    _draftService = DraftPenerimaanService(username);
  }

  // --- TRANSACTION OPERATIONS ---
  Future<TransactionModel?> getTransaction(String noBast) async {
    return await _outstandingService.getTransactionByNoBast(noBast);
  }

  Future<void> updateTransactionStatus(String noBast, String status) async {
    await _outstandingService.updateStatus(noBast, status);
  }

  // --- SENSOR & MASTER DATA ---
  Future<void> refreshSensorData({required String unitId, required String storageCode}) async {
    await _sensorService.refreshData(unitId: unitId, targetStorageCode: storageCode);
  }

  List<VolumeTankDetailModel> getLocalSensorData(String storageCode) {
    return _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();
  }

  Future<double?> getLiterFromCalibration(int capacity, double heightMm) async {
    return await _masterDataService.getLiterFromCalibration(
        kapasitas: capacity,
        tinggiMm: heightMm
    );
  }

  // --- DRAFT OPERATIONS ---
  Future<void> saveDraft(String noBast, Map<String, dynamic> formData) async {
    await _draftService.saveDraftSesudah(noBast, formData);
  }

  Future<Map<dynamic, dynamic>?> getDraft(String noBast) async {
    return await _draftService.getDraftSesudah(noBast);
  }

  // --- HELPER PARSING ---
  List<Map<String, dynamic>> parseManualJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) {
        return {
          'code': (item['tank_code'] ?? '').replaceAll('_', ' '),
          'volume': (item['volume_manual'] as num).toDouble(),
          'height': (item['height_manual'] as num).toDouble(),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> parseIotJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) {
        return {
          'code': (item['tank_code'] ?? '').replaceAll('_', ' '),
          'volume': ((item['volume_iot'] ?? item['volume'] ?? 0) as num).toDouble(),
          'height': ((item['height_iot'] ?? item['height'] ?? 0) as num).toDouble(),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}