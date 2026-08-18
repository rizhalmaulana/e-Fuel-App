import 'package:get/get.dart';
import '../controllers/pengembalian_controller.dart';
import '../services/pengembalian_service.dart';

class PengembalianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengembalianService>(() => PengembalianService());
    Get.lazyPut<PengembalianController>(() => PengembalianController());
  }
}
