import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../configs/app_lotties.dart';
import '../widgets/dialog/dialog_flexible.dart';

class ConnectivityHelper extends GetxService {

  Future<bool> checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      await _showNoConnectionDialog(); // 👈 Panggil dialog, bukan snackbar
      return false;
    }

    return true;
  }

  Future<void> _showNoConnectionDialog() async {
    if (Get.isDialogOpen ?? false) {
      return;
    }

    await Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieFailed(),
        title: 'Koneksi Terputus!',
        message: 'Aplikasi memerlukan koneksi internet untuk proses ini. Harap hubungkan perangkat Anda ke jaringan yang stabil.',
        primaryButtonText: 'Tutup',
        onPrimaryPressed: Get.back,
        secondaryButtonText: null,
        onSecondaryPressed: null,
      ),
      barrierDismissible: false,
    );
  }
}