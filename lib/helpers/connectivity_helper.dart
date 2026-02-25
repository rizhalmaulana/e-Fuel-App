import 'dart:io';
import 'package:get/get.dart';
import '../helpers/lotties_helper.dart';
import '../widgets/dialog/dialog_flexible.dart';

class ConnectivityHelper {

  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<bool> validateNetwork() async {
    bool hasInternet = await isConnected();

    if (!hasInternet) {
      // Tunggu aksi user di dialog, lalu kembalikan hasilnya ke controller
      return await _showNoConnectionDialog();
    }

    return true; // Koneksi berhasil
  }

  static Future<bool> _showNoConnectionDialog() async {
    if (Get.isDialogOpen == true) {
      return false;
    }

    // Tahan eksekusi dan tunggu hasil (result) dari aksi Get.back() di dalam dialog
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

    // Jika user memilih Coba Lagi (result == true), validasi ulang secara rekursif
    if (result == true) {
      return await validateNetwork();
    }

    // Jika user memilih Tutup (result == false / null), batalkan semua proses
    return false;
  }
}