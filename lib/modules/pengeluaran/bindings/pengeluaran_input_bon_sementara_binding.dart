import 'package:e_fuel/modules/pengeluaran/controllers/pengeluaran_input_bon_sementara_controller.dart';
import 'package:get/get.dart';

class PengeluaranInputBonSementaraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranInputBonSementaraController>(
      () => PengeluaranInputBonSementaraController(),
    );
  }
}
