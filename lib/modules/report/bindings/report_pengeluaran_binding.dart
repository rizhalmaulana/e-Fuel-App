import 'package:get/get.dart';
import '../controllers/report_pengeluaran_controller.dart';

class ReportPengeluaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportPengeluaranController>(
          () => ReportPengeluaranController(),
    );
  }
}