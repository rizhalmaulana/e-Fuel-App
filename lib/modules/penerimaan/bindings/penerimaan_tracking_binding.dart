import 'package:e_fuel/modules/penerimaan/controllers/penerimaan_tracking_controller.dart';
import 'package:get/get.dart';

class PenerimaanTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PenerimaanTrackingController>(
          () => PenerimaanTrackingController(),
    );
  }
}