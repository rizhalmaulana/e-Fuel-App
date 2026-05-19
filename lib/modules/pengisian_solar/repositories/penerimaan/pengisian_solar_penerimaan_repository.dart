import 'package:e_fuel/modules/fuel/services/fuel_sensor_service.dart';
import 'package:e_fuel/modules/transactions/outstanding_service.dart';
import 'package:e_fuel/modules/transactions/penerimaan/services/penerimaan_api_service.dart';
import 'package:get/get.dart';

import '../../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../../datas/models/volume_storage/volume_storage.dart';
import '../../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';

class PengisianSolarPenerimaanRepository {
  final PenerimaanApiService _penerimaanService = Get.find<PenerimaanApiService>();
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  late OutstandingService _outstandingService;

  PengisianSolarPenerimaanRepository(String username) {
    _outstandingService = OutstandingService(username);
  }

  // --- SENSOR OPERATIONS ---
  Future<VolumeStorage> getDataStockStorage({required String unitId, required String storageCode, required String dateLog}) async {
    return await _penerimaanService.fetchLatestStockStorage(
        unitId: unitId,
        storageCode: storageCode,
        dateLog: dateLog
    );
  }

  Future<List<dynamic>> getDetailStorageTank({
    required String unitId,
    required String storageCode,
  }) async {
    return await _penerimaanService.getDetailStorageTank(unitId: unitId, storageCode: storageCode);
  }

  Future<void> getDetailTanks({required String unitId, required String storageCode}) async {
    await _sensorService.fetchDataDetailTank(unitId: unitId, targetStorageCode: storageCode);
  }

  List<VolumeTankDetailModel> getLocalSensorData(String storageCode) {
    return _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();
  }

  // --- TRANSACTION STATUS OPERATIONS ---
  Future<void> updateTransactionStatus(String noBast, String status) async {
    await _outstandingService.updateStatus(noBast, status);
    
    TransactionModel? transaction = await _outstandingService.getTransactionByNoBast(noBast);
    if (transaction != null) {
      transaction.status = status;
      await transaction.save();
    }
  }
}