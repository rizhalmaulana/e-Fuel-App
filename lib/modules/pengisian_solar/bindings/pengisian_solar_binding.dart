import 'package:e_fuel/modules/pengisian_solar/controllers/pengisian_solar_controller.dart';
import 'package:get/get.dart';

class PengisianSolarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengisianSolarController>(
          () => PengisianSolarController(),
    );
  }
}