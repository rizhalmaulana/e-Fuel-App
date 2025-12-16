import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../auth/services/login_service.dart';
import '../../../transactions/outstanding_service.dart';

class PengisianSolarPenerimaanController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();

  final noBast = '-'.obs;
  final noPO = '-'.obs;
  final noPolisi = '-'.obs;
  final tanggal = '-'.obs;
  final status = '-'.obs;

  String? manualJsonBackup;
  String? iotJsonBackup;

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
    manualJsonBackup = args['manual_json_backup'];
    iotJsonBackup = args['iot_json_backup'];
  }

  Future<void> saveAndExit() async {
    final auth = _loginService.getCurrentAuth();
    final username = auth?.user.username ?? "";

    if (username.isNotEmpty && noBast.value != '-') {
      try {
        final outstandingService = OutstandingService(username);
        await outstandingService.updateStatus(
            noBast.value,
            'pengisian_solar'
        );
      } catch (e) {
        print("Error saving exit status: $e");
      }
    }
    // Kembali ke Home
    Get.offAllNamed(Routes.HOME);
  }

  Future<void> finishTransaction() async {
    final auth = _loginService.getCurrentAuth();
    final username = auth?.user.username ?? "";

    // Validasi basic
    if (username.isEmpty || noBast.value == '-') {
      _goToNextPage();
      return;
    }

    try {
      final outstandingService = OutstandingService(username);
      await outstandingService.updateStatus(
          noBast.value,
          'setelah_pengisian'
      );
    } catch (e) {
      print("Error update status pengisian: $e");
    }

    _goToNextPage();
  }

  void _goToNextPage() {
    Get.offAllNamed(
        Routes.PENERIMAAN_SETELAH,
        arguments: {
          'noBast': noBast.value,
          'manual_json_backup': manualJsonBackup,
          'iot_json_backup': iotJsonBackup,
        }
    );
  }
}