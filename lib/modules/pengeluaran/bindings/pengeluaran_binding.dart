import 'package:get/get.dart';
import '../controllers/pengeluaran_controller.dart';

class PengeluaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranController>(
      () => PengeluaranController(),
    );
  }
}
