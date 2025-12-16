import 'package:e_fuel/modules/pengisian_solar/controllers/penerimaan/pengisian_solar_penerimaan_controller.dart';
import 'package:e_fuel/modules/pengisian_solar/controllers/pengeluaran/pengisian_solar_pengeluaran_controller.dart';
import 'package:get/get.dart';

class PengisianSolarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengisianSolarPenerimaanController>(
          () => PengisianSolarPenerimaanController(),
    );

    Get.lazyPut<PengisianSolarPengeluaranController>(
          () => PengisianSolarPengeluaranController(),
    );
  }
}