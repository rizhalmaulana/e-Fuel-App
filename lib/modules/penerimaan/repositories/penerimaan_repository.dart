import 'dart:convert';
import 'dart:io';

import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import 'package:e_fuel/modules/fuel/services/fuel_sensor_service.dart';
import 'package:e_fuel/modules/fuel/services/master_data_service.dart';
import 'package:e_fuel/modules/transactions/outstanding_service.dart';
import 'package:e_fuel/modules/transactions/penerimaan/services/penerimaan_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  List<VolumeTankDetailModel> getLocalSensorData(String storageCode) {
    return _sensorService.iotData.where((tank) => tank.masterStorage?.kodeStorage == storageCode).toList();
  }

  Future<List<VolumeTankDetailModel>> syncSensorStockWithLocal({
    required String unitId,
    required String storageCode,
  }) async {
    List<VolumeTankDetailModel> masterTanks = await fetchMasterTankDetail(unitId, storageCode);
    if (masterTanks.isEmpty) {
      masterTanks = _fuelDataService.getApiManualTanks()
          .where((t) => t.masterStorage?.kodeStorage == storageCode).toList();
    }

    if (masterTanks.isEmpty) return [];

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<VolumeTankDetailModel> syncedList = [];
    bool isApiSuccess = false;

    await Future.wait(masterTanks.map((tank) async {
      final stockData = await fetchLatestTankStock(
        unitId: unitId,
        tankCode: tank.masterSolarTank?.kodeTank ?? '',
        dateLog: today,
      );

      if (stockData != null) {
        isApiSuccess = true;
        double vol = (stockData['stock_volume'] as num?)?.toDouble() ?? 0.0;
        double h = (stockData['tinggi'] ?? stockData['height'] as num?)?.toDouble() ?? 0.0;

        syncedList.add(VolumeTankDetailModel(
          id: tank.id,
          unit: tank.unit,
          masterStorage: tank.masterStorage,
          masterSolarTank: tank.masterSolarTank,
          volume: vol,
          height: h,
          updatedAt: DateTime.now().toIso8601String(),
          capacity: tank.capacity,
        ));
      } else {
        // Jika API Gagal, gunakan data master (Fallback)
        syncedList.add(VolumeTankDetailModel(
          id: tank.id,
          unit: tank.unit,
          masterStorage: tank.masterStorage,
          masterSolarTank: tank.masterSolarTank,
          volume: tank.volume,
          height: tank.height,
          updatedAt: tank.updatedAt,
          capacity: tank.capacity,
        ));
      }
    }));

    // SAVE TO LOCAL: Jika minimal ada satu API sukses, simpan seluruh snapshot ke Hive
    if (isApiSuccess) {
      await _fuelDataService.saveApiManualTanks(syncedList);
      updateLocalSensorData(syncedList, storageCode);
    }

    return syncedList;
  }

  Future<Map<String, dynamic>?> fetchLatestTankStock({
    required String unitId,
    required String tankCode,
    required String dateLog,
  }) async {
    final response = await _apiService.getLatestStockTanks(
      unitId: unitId,
      tankCode: tankCode,
      dateLog: dateLog,
    );

    debugPrint("DEBUG RESPONSE API: $response");

    if (response != null && response is List && response.isNotEmpty) {
      return response.first;
    }
    return null;
  }

  Future<List<dynamic>> getTankDetails(String unitId, String tankCode, String date) async {
    return await _apiService.getTankStockList(unitId: unitId, tankCode: tankCode, dateLog: date);
  }

  Future<List<dynamic>> getLiveFlowIn(String unitId, String tankCode, String date) async {
    return await _apiService.getFlowInTraffic(unitId: unitId, tankCode: tankCode, dateLog: date);
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