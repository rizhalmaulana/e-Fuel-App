import 'package:e_fuel/modules/pengeluaran/controllers/pengeluaran_verifikasi_doc_controller.dart';
import 'package:get/get.dart';

class PengeluaranVerifikasiDocBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranVerifikasiDocController>(
          () => PengeluaranVerifikasiDocController(),
    );
  }
}