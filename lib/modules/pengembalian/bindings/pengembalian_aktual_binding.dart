import 'package:get/get.dart';
import '../controllers/pengembalian_aktual_controller.dart';

class PengembalianAktualBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengembalianAktualController>(() => PengembalianAktualController());
  }
}
