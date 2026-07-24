import 'dart:io';
import 'package:get/get.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';

class SplashController extends GetxController {
  final _loginService = Get.find<LoginService>();
  final _shorebirdUpdater = ShorebirdUpdater();

  final isChecking = true.obs;
  final isDownloading = false.obs;
  final isUpdateReady = false.obs;
  final statusText = "Memeriksa pembaruan...".obs;

  @override
  void onInit() {
    super.onInit();
    _checkUpdatesAndNavigate();
  }

  Future<void> _checkUpdatesAndNavigate() async {
    final startTime = DateTime.now();
    try {
      // 1. Cek koneksi internet
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

      if (!hasInternet) {
        // Jika tidak ada internet, langsung masuk aplikasi (offline mode)
        await _navigateToAppWithDelay(startTime);
        return;
      }

      // 2. Cek apakah Shorebird didukung pada perangkat ini
      final isSupported = _shorebirdUpdater.isAvailable;
      if (!isSupported) {
        await _navigateToAppWithDelay(startTime);
        return;
      }

      // 3. Cek pembaruan
      statusText.value = "Memeriksa pembaruan sistem...";
      final updateStatus = await _shorebirdUpdater.checkForUpdate();

      if (updateStatus == UpdateStatus.outdated) {
        // Ada patch baru!
        isChecking.value = false;
        isDownloading.value = true;
        statusText.value = "Pembaruan sistem tersedia.\nMengunduh pembaruan baru...\nMohon jangan menutup aplikasi.";

        // Unduh patch
        await _shorebirdUpdater.update();

        // Selesai unduh
        isDownloading.value = false;
        isUpdateReady.value = true;
        statusText.value = "Pembaruan berhasil dipasang!\nSilakan klik tombol di bawah untuk memuat ulang aplikasi.";
      } else if (updateStatus == UpdateStatus.restartRequired) {
        // Patch sudah terunduh sebelumnya dan tinggal butuh restart
        isChecking.value = false;
        isUpdateReady.value = true;
        statusText.value = "Pembaruan siap diterapkan!\nSilakan klik tombol di bawah untuk memuat ulang aplikasi.";
      } else {
        // upToDate atau unavailable
        await _navigateToAppWithDelay(startTime);
      }
    } catch (e) {
      print("Error checking updates: $e");
      // Jika terjadi kesalahan apa pun, langsung arahkan ke Home/Login agar user tidak tertahan
      await _navigateToAppWithDelay(startTime);
    }
  }

  Future<void> _navigateToAppWithDelay(DateTime startTime) async {
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed.inMilliseconds));
    }
    await _navigateToApp();
  }

  Future<void> _navigateToApp() async {
    isChecking.value = false;
    isDownloading.value = false;
    
    // Cek status login
    bool isLoggedIn = false;
    try {
      isLoggedIn = await _loginService.initializeSessionFromHive();
    } catch (_) {}

    if (isLoggedIn) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void restartApp() {
    if (Platform.isAndroid) {
      exit(0); // Memaksa proses aplikasi berhenti sepenuhnya agar patch Shorebird diterapkan saat cold start berikutnya
    } else {
      SystemNavigator.pop(); // Menutup aplikasi secara aman di platform lain
    }
  }
}
