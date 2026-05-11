import 'package:e_fuel/modules/home/controllers/home_controller.dart';
import 'package:e_fuel/modules/transactions/penerimaan/services/penerimaan_api_service.dart';
import 'package:get/get.dart';
import '../controllers/penerimaan_setelah_controller.dart';

class PenerimaanSetelahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PenerimaanApiService>(
          () => PenerimaanApiService(),
    );
    Get.lazyPut<PenerimaanSetelahController>(
          () => PenerimaanSetelahController(),
    );
    Get.lazyPut<HomeController>(
          () => HomeController(),
    );
  }
}