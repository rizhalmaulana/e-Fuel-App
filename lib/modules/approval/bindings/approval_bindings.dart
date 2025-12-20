import 'package:e_fuel/modules/approval/controllers/approval_controller.dart';
import 'package:get/get.dart';

class ApprovalBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApprovalController>(
          () => ApprovalController(),
    );
  }
}