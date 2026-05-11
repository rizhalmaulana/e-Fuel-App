import 'dart:io';
import 'package:get/get.dart';
import '../helpers/lotties_helper.dart';
import '../widgets/dialog/dialog_flexible.dart';

class ConnectivityHelper {

  /// Cek koneksi internet secara diam-diam (TANPA dialog).
  /// Gunakan ini untuk loading awal atau background sync —
  /// agar UI tidak diblokir saat offline.
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Cek koneksi internet DAN tampilkan dialog jika offline.
  /// Gunakan ini hanya untuk aksi eksplisit user yang butuh internet:
  /// - Tombol Refresh (pull-to-refresh)
  /// - Submit transaksi (Penerimaan, Pengeluaran)
  /// - Approval
  ///
  /// JANGAN gunakan untuk loading awal Home/halaman — gunakan [isConnected()] saja.
  static Future<bool> validateNetwork() async {
    bool hasInternet = await isConnected();

    if (!hasInternet) {
      return await _showNoConnectionDialog();
    }

    return true;
  }

  static Future<bool> _showNoConnectionDialog() async {
    if (Get.isDialogOpen == true) {
      return false;
    }

    final result = await Get.dialog<bool>(
      DialogFlexible(
        logo: LottiesHelper().getLottieFailed(),
        title: 'Koneksi Terputus!',
        message: 'Aplikasi memerlukan koneksi internet stabil untuk melakukan proses ini. Silakan cek jaringan Anda.',
        primaryButtonText: 'Tutup',
        onPrimaryPressed: () {
          Get.back(result: false);
        },
        secondaryButtonText: "Coba Lagi",
        onSecondaryPressed: () {
          Get.back(result: true);
        },
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      return await validateNetwork();
    }

    return false;
  }
}