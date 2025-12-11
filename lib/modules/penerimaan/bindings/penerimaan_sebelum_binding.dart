import 'package:e_fuel/modules/penerimaan/controllers/penerimaan_controller.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/penerimaan_sebelum_controller.dart';

class PenerimaanSebelumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());

    Get.lazyPut<PenerimaanController>(
          () => PenerimaanController(),
    );

    Get.lazyPut<PenerimaanSebelumController>(
          () => PenerimaanSebelumController(),
    );
  }
}