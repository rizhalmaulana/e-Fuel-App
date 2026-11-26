import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
  /// - Submit transaksi (Penerimaan, Pengeluaran, Pengembalian)
  /// - Upload Transfer Solar
  /// - Approval
  ///
  /// JANGAN gunakan untuk loading awal Home/halaman — gunakan [isConnected()] saja.
  static Future<bool> validateNetwork({
    String? title,
    String? message,
  }) async {
    final status = await checkNetworkStatus();

    if (status != NetworkCheckStatus.connected) {
      return await _showNoConnectionDialog(
        status: status,
        title: title,
        message: message,
      );
    }

    return true;
  }

  static bool _isNoConnectionDialogShowing = false;

  static Future<bool> _showNoConnectionDialog({
    NetworkCheckStatus status = NetworkCheckStatus.noNetwork,
    String? title,
    String? message,
  }) async {
    if (_isNoConnectionDialogShowing) {
      return false;
    }

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    final resolvedTitle = title ??
        (status == NetworkCheckStatus.slowOrUnreachable
            ? 'Jaringan Tidak Stabil'
            : 'Tidak Ada Jaringan');
    final resolvedMessage = message ??
        (status == NetworkCheckStatus.slowOrUnreachable
            ? 'Sinyal internet terlalu lambat atau tidak merespons. Silakan periksa jaringan Anda dan coba lagi.'
            : 'Aplikasi memerlukan koneksi internet aktif untuk melakukan proses ini. Silakan cek jaringan Anda dan coba lagi.');

    _isNoConnectionDialogShowing = true;
    bool? result;
    try {
      result = await Get.dialog<bool>(
        Builder(
          builder: (dialogCtx) => DialogFlexible(
            logo: LottiesHelper().getLottieFailed(),
            title: resolvedTitle,
            message: resolvedMessage,
            primaryColor: AppColors.alertSoftRed,
            primaryButtonText: 'Tutup',
            onPrimaryPressed: () {
              if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                Navigator.of(dialogCtx, rootNavigator: true).pop(false);
              }
            },
            secondaryButtonText: "Coba Lagi",
            onSecondaryPressed: () {
              if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                Navigator.of(dialogCtx, rootNavigator: true).pop(true);
              }
            },
          ),
        ),
        barrierDismissible: false,
      );
    } finally {
      _isNoConnectionDialogShowing = false;
    }

    if (result == true) {
      // Beri jeda singkat agar dialog sebelumnya benar-benar selesai tertutup
      // sebelum menampilkan ulang dialog bila jaringan masih offline.
      await Future.delayed(const Duration(milliseconds: 150));
      return await validateNetwork(title: title, message: message);
    }

    return false;
  }
}