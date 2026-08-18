import 'package:get/get.dart';
import '../controllers/pengembalian_proses_controller.dart';

class PengembalianProsesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengembalianProsesController>(
      () => PengembalianProsesController(),
    );
  }
}
