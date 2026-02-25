import 'package:e_fuel/modules/report/controllers/report_detail_pengeluaran_controller.dart';
import 'package:get/get.dart';

class ReportDetailPengeluaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportDetailPengeluaranController>(
          () => ReportDetailPengeluaranController(),
    );
  }
}