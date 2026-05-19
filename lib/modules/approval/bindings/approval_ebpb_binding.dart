import 'package:get/get.dart';
import '../controllers/approval_ebpb_controller.dart';

class ApprovalEbpbBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApprovalEbpbController>(
      () => ApprovalEbpbController(),
    );
  }
}
