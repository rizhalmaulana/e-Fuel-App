import 'package:get/get.dart';
import '../controllers/pengembalian_loading_controller.dart';

class PengembalianLoadingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengembalianLoadingController>(() => PengembalianLoadingController());
  }
}
