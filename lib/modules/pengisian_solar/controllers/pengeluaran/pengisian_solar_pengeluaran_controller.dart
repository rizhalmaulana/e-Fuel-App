import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../auth/services/login_service.dart';
import '../../../transactions/outstanding_service.dart';

class PengisianSolarPengeluaranController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();

  final noDoc = '-'.obs;
  final noIO = '-'.obs;
  final unitIO = '-'.obs;
  final noPolisi = '-'.obs;
  final namaSupir = '-'.obs;
  final tanggal = '-'.obs;
  final jumlahSolar = '-'.obs;
  final KmPengisian = '-'.obs;
  final status = '-'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    noDoc.value = args['noDoc'] ?? '-';
    noIO.value = args['noIO'] ?? '-';
    unitIO.value = args['unitIO'] ?? '-';
    noPolisi.value = args['noPolisi'] ?? '-';
    namaSupir.value = args['supir_check'] ?? '-';
    tanggal.value = args['tanggal'] ?? '-';
    KmPengisian.value = (args['km_pengisian'] ?? '-').toString();
    jumlahSolar.value = (args['jumlah_pengisian_solar'] ?? '-').toString();
    status.value = args['status'] ?? 'pengisian_solar';
  }

  Future<void> saveAndExit() async {
    final auth = _loginService.getCurrentAuth();
    final username = auth?.user.username ?? "";

    if (username.isNotEmpty && noDoc.value != '-') {
      try {
        final outstandingService = OutstandingService(username);
        await outstandingService.updateStatusPengeluaran(
            noDoc.value,
            'pengisian_solar_pengeluaran'
        );
      } catch (e) {
        print("Error saving exit status pengeluaran: $e");
      }
    }
    Get.offAllNamed(Routes.HOME);
  }

  Future<void> finishTransaction() async {
    final auth = _loginService.getCurrentAuth();
    final username = auth?.user.username ?? "";

    if (username.isNotEmpty && noDoc.value != '-') {
      try {
        final outstandingService = OutstandingService(username);
        await outstandingService.updateStatusPengeluaran(
            noDoc.value,
            'verifikasi_pengeluaran'
        );
      } catch (e) {
        print("Error update status pengisian pengeluaran: $e");
      }
    }

    Get.offNamed(
        Routes.PENGELUARAN_VERIFIKASI_DOC,
        arguments: {
          'noDoc': noDoc.value,
          'noIO': noIO.value,
          'unitIO': unitIO.value,
          'noPolisi': noPolisi.value,
          'nama_supir': namaSupir.value,
          'tanggal': tanggal.value,
          'jumlah_pengisian_solar': jumlahSolar.value,
          'km_pengisian': KmPengisian.value
        }
    );
  }
}