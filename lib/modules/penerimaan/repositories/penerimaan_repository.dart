import 'dart:convert';
import 'dart:io';

import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import 'package:e_fuel/modules/fuel/services/fuel_sensor_service.dart';
import 'package:e_fuel/modules/fuel/services/master_data_service.dart';
import 'package:e_fuel/modules/transactions/outstanding_service.dart';
import 'package:e_fuel/modules/transactions/penerimaan/services/penerimaan_api_service.dart';
import 'package:get/get.dart';

import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../services/draft_penerimaan_service.dart';

class PenerimaanRepository {
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final MasterDataService _masterDataService = MasterDataService();
  final PenerimaanApiService _apiService = PenerimaanApiService();

  late DraftPenerimaanService _draftService;
  late OutstandingService _outstandingService;

  PenerimaanRepository(String username) {
    _draftService = DraftPenerimaanService(username);
    _outstandingService = OutstandingService(username);
  }

  // --- SENSOR & MASTER DATA OPERATIONS ---
  Future<void> refreshSensorData({required String unitId, required String storageCode}) async {
    await _sensorService.refreshData(unitId: unitId, targetStorageCode: storageCode);
  }

  List<VolumeTankDetailModel> getLocalSensorData(String storageCode) {
    return _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();
  }

  Future<List<VolumeTankDetailModel>> fetchMasterTankDetail(String unitId, String storageCode) async {
    final result = await _masterDataService.getTankDetailFromStorage(
        unitId: unitId,
        storageId: storageCode
    );
    return result.map((e) => e).toList();
  }

  void updateLocalSensorData(List<VolumeTankDetailModel> newTanks, String storageCode) {
    _sensorService.iotData.removeWhere((t) => t.masterStorage?.kodeStorage == storageCode);
    _sensorService.iotData.addAll(newTanks);
  }

  List<String> getAvailableStorages() {
    final rawStorages = _fuelDataService.getLocalStorages();
    return rawStorages
        .expand((unit) => unit.masterStorage)
        .where((s) => s.storageStatus == 'Y')
        .map((s) => "${s.namaStorage} - ${s.kodeStorage}")
        .toList();
  }

  Map<String, double> getManualTankInput(String tankCode) {
    return _fuelDataService.getManualTankInput(tankCode);
  }

  Future<double?> getLiterFromCalibration(int capacity, double heightMm) async {
    return await _masterDataService.getLiterFromCalibration(
        kapasitas: capacity,
        tinggiMm: heightMm
    );
  }

  // --- DRAFT OPERATIONS ---
  Future<PenerimaanSebelumModel?> getDraft() async {
    return await _draftService.getDraftBefore();
  }

  Future<void> deleteDraft() async {
    await _draftService.deleteDraftBefore();
  }

  // --- TRANSACTION OPERATIONS ---
  Future<Map<String, dynamic>> submitTransaction(Map<String, dynamic> formMap, List<File?> photos) async {
    return await _apiService.submitInboundOpen(formMap: formMap, photos: photos);
  }

  Future<void> saveLocalTransaction(TransactionModel transaction) async {
    await _outstandingService.saveTransaction(transaction);
  }

  Future<void> updateLocalTransactionDetails(String noBast, List<Map<String, dynamic>> manualData, List<Map<String, dynamic>> iotData) async {
    var trx = await _outstandingService.getTransactionByNoBast(noBast);
    if (trx != null && trx.dataSebelum != null) {
      trx.dataSebelum!.manualTankDetailsJson = jsonEncode(manualData);
      trx.dataSebelum!.iotTankDetailsJson = jsonEncode(iotData);
      await trx.save();
    }
  }
}