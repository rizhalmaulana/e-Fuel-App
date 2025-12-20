import 'package:e_fuel/modules/pengeluaran/controllers/pengeluaran_bpb_harian_controller.dart';
import 'package:get/get.dart';

class PengeluaranBpbHarianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranBpbHarianController>(
          () => PengeluaranBpbHarianController(),
    );
  }
}
