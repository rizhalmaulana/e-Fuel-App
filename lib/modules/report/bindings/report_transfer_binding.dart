import 'package:get/get.dart';
import '../controllers/report_transfer_controller.dart';

class ReportTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportTransferController>(
      () => ReportTransferController(),
    );
  }
}
