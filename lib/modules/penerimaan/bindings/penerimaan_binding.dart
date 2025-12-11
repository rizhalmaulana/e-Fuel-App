import 'package:get/get.dart';
import '../controllers/penerimaan_controller.dart';

class PenerimaanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PenerimaanController>(
          () => PenerimaanController(),
    );
  }
}