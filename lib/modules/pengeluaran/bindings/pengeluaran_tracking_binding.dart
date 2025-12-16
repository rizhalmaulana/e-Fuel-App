import 'package:e_fuel/modules/pengeluaran/controllers/pengeluaran_tracking_controller.dart';
import 'package:get/get.dart';

class PengeluaranTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranTrackingController>(
          () => PengeluaranTrackingController(),
    );
  }
}