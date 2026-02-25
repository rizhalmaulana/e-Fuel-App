import 'package:e_fuel/modules/report/controllers/report_detail_penerimaan_controller.dart';
import 'package:get/get.dart';

class ReportDetailPenerimaanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportDetailPenerimaanController>(
          () => ReportDetailPenerimaanController(),
    );
  }
}