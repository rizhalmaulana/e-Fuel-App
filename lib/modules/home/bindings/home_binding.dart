import 'package:e_fuel/modules/penerimaan/controllers/penerimaan_tracking_controller.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PenerimaanTrackingController>(
          () => PenerimaanTrackingController(),
    );

    Get.lazyPut<HomeController>(
          () => HomeController(),
    );
  }
}