import 'package:e_fuel/modules/fuel/services/fuel_sensor_service.dart';
import 'package:e_fuel/modules/transactions/outstanding_service.dart';
import 'package:get/get.dart';

import '../../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';

class PengisianSolarPenerimaanRepository {
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  late OutstandingService _outstandingService;

  PengisianSolarPenerimaanRepository(String username) {
    _outstandingService = OutstandingService(username);
  }

  // --- SENSOR OPERATIONS ---
  Future<void> refreshSensorData({required String unitId, required String storageCode}) async {
    await _sensorService.refreshData(unitId: unitId, targetStorageCode: storageCode);
  }

  List<VolumeTankDetailModel> getLocalSensorData(String storageCode) {
    return _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();
  }

  // --- TRANSACTION STATUS OPERATIONS ---
  Future<void> updateTransactionStatus(String noBast, String status) async {
    // 1. Update ke Outstanding Service
    await _outstandingService.updateStatus(noBast, status);

    // 2. Pastikan objek TransactionModel lokal juga di-update dan di-save ke Hive
    TransactionModel? transaction = await _outstandingService.getTransactionByNoBast(noBast);
    if (transaction != null) {
      transaction.status = status;
      await transaction.save();
    }
  }
}