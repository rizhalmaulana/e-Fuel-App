import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../helpers/lotties_helper.dart';
import '../widgets/dialog/dialog_flexible.dart';
import '../configs/app_colors.dart';

enum NetworkCheckStatus {
  connected,
  noNetwork,
  slowOrUnreachable,
}

class ConnectivityHelper {
  /// Cek cepat apakah perangkat memiliki antarmuka jaringan aktif (Wi-Fi / Seluler).
  static Future<bool> hasNetworkInterface() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.isNotEmpty && !results.every((r) => r == ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  /// Cek status jaringan secara rinci:
  /// - [NetworkCheckStatus.noNetwork]: Wi-Fi & data seluler mati / mode pesawat
  /// - [NetworkCheckStatus.slowOrUnreachable]: Sinyal ada tetapi internet tidak merespons / terlalu lambat
  /// - [NetworkCheckStatus.connected]: Terhubung ke internet
  static Future<NetworkCheckStatus> checkNetworkStatus({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final hasInterface = await hasNetworkInterface();
    if (!hasInterface) {
      return NetworkCheckStatus.noNetwork;
    }

    try {
      final result = await InternetAddress.lookup('google.com').timeout(timeout);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return NetworkCheckStatus.connected;
      }
      return NetworkCheckStatus.slowOrUnreachable;
    } on TimeoutException {
      return NetworkCheckStatus.slowOrUnreachable;
    } on SocketException {
      return NetworkCheckStatus.noNetwork;
    } catch (_) {
      return NetworkCheckStatus.slowOrUnreachable;
    }
  }

  /// Cek koneksi internet secara diam-diam (TANPA dialog).
  /// Gunakan ini untuk loading awal atau background sync —
  /// agar UI tidak diblokir saat offline.
  static Future<bool> isConnected({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final status = await checkNetworkStatus(timeout: timeout);
    return status == NetworkCheckStatus.connected;
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
        primaryColor: AppColors.alertSoftRed,
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