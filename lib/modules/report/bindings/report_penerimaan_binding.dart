import 'package:get/get.dart';
import '../controllers/report_penerimaan_controller.dart';

class ReportPenerimaanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportPenerimaanController>(
          () => ReportPenerimaanController(),
    );
  }
}