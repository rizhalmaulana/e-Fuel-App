import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:e_fuel/modules/auth/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../helpers/connectivity_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';

import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/master_data_service.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  late TextEditingController usernameController;
  late TextEditingController passwordController;

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var loadingMessage = 'Sedang masuk...'.obs;

  final LoginService _loginService = Get.find<LoginService>();
  final ConnectivityHelper _connectivityHelper = Get.find<ConnectivityHelper>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // --- VALIDATORS ---
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // --- ACTIONS ---
  void forgotPassword() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieOnDevelopment(),
        title: 'Informasi',
        message: 'Fitur Lupa Password masih tahap pengembangan.',
        primaryButtonText: 'Mengerti',
        onPrimaryPressed: Get.back,
      ),
      barrierDismissible: true,
    );
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void _showErrorDialog(String title, String message) {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieFailed(),
        title: title,
        message: message,
        primaryButtonText: 'Mengerti',
        onPrimaryPressed: Get.back,
      ),
      barrierDismissible: true,
    );
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final hasConnection = await _connectivityHelper.checkConnection();
    if (!hasConnection) return;

    isLoading.value = true;
    loadingMessage.value = 'Sedang verifikasi akun...';

    try {
      await _loginService.login(
        usernameController.text,
        passwordController.text,
      );

      await _syncMasterData();
      Get.offAllNamed(Routes.HOME);

    } on DioCustomException catch (e) {
      String title = 'Login Gagal';
      if (e.statusCode == 400 || e.statusCode == 401) {
        title = 'Kredensial Salah';
      } else if (e.statusCode == 500 || e.statusCode == 502) {
        title = 'Kesalahan Server';
      } else if (e.statusCode == null) {
        title = 'Koneksi Terputus';
      }
      _showErrorDialog(title, e.message);

    } catch (e) {
      _showErrorDialog('Terjadi Kesalahan', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncMasterData() async {
    try {
      loadingMessage.value = 'Mengunduh data master...';

      final authData = _loginService.getCurrentAuth();
      final unitId = authData?.user.userKaryawan.unit.kodeUnit;
      final username = authData?.user.username;

      if (unitId != null && unitId.isNotEmpty && username != null) {
        final masterService = MasterDataService();

        // 1. Get Storage Data
        final storages = await masterService.getStorageFromUnit(unitId: unitId);

        if (storages.isNotEmpty) {
          await _fuelDataService.openFuelDataBox(username);
          await _fuelDataService.saveLocalStorages(storages);

          print("✅ [LoginController] Berhasil sync ${storages.length} master storage");
        } else {
          print("ℹ️ [LoginController] Data storage kosong dari server.");
        }
      }
    } catch (e) {
      print("⚠️ [LoginController] Gagal sync master data: $e");
    }
  }
}