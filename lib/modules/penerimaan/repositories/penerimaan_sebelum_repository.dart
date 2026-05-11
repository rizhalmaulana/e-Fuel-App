import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import 'package:e_fuel/modules/fuel/services/fuel_sensor_service.dart';
import 'package:e_fuel/modules/penerimaan/services/draft_penerimaan_service.dart';
import 'package:get/get.dart';

import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';

class PenerimaanSebelumRepository {
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  late DraftPenerimaanService _draftService;

  PenerimaanSebelumRepository(String username) {
    _draftService = DraftPenerimaanService(username);
  }

  Future<void> initializeDataBox(String username) async {
    await _fuelDataService.openFuelDataBox(username);
    await _sensorService.initSensorBox(username);
  }

  List<String> getAvailableStorages() {
    final rawStorages = _fuelDataService.getLocalStorages();
    List<String> formattedStorages = [];

    for (var unitData in rawStorages) {
      for (var storage in unitData.masterStorage) {
        if (storage.storageStatus == 'Y') {
          formattedStorages.add("${storage.namaStorage} - ${storage.kodeStorage}");
        }
      }
    }
    return formattedStorages;
  }

  List<VolumeTankDetailModel> getLocalSensorData(String storageCode) {
    return _sensorService.iotData.where(
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();
  }

  Map<String, double> getManualTankInput(String tankCode) {
    return _fuelDataService.getManualTankInput(tankCode);
  }

  Future<PenerimaanSebelumModel?> getDraft() async {
    return await _draftService.getDraftBefore();
  }

  Future<void> deleteDraft() async {
    await _draftService.deleteDraftBefore();
  }
}