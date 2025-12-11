import 'package:e_fuel/helpers/connectivity_helper.dart';
import 'package:e_fuel/modules/auth/services/login_user_service.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../services/login_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginUserService>(() => LoginUserService());
    Get.lazyPut<ConnectivityHelper>(() => ConnectivityHelper());
    Get.lazyPut<LoginController>(() => LoginController());
  }
}