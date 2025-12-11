import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/penerimaan/services/outstanding_service.dart';

class PengisianSolarController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();

  final noBast = '-'.obs;
  final noPO = '-'.obs;
  final noPolisi = '-'.obs;
  final tanggal = '-'.obs;
  final status = '-'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    noBast.value = args['noBast'] ?? '-';
    noPO.value = args['noPO'] ?? '-';
    noPolisi.value = args['noPolisi'] ?? '-';
    tanggal.value = args['tanggal'] ?? '-';
    status.value = args['status'] ?? 'pengisian_solar';
  }

  Future<void> finishTransaction() async {
    final auth = _loginService.getCurrentAuth();
    final username = auth?.user.username ?? "";

    if (username.isEmpty || noBast.value == '-') {
      Get.offAllNamed(Routes.PENERIMAAN_SETELAH, arguments: {'noBast': noBast.value});
      return;
    }

    try {
      final outstandingService = OutstandingService(username);
      await outstandingService.updateStatus(noBast.value, 'setelah_pengisian');

    } catch (e) {
      print("Error finishing transaction step: $e");
    }

    Get.offAllNamed(
        Routes.PENERIMAAN_SETELAH,
        arguments: {'noBast': noBast.value}
    );
  }
}