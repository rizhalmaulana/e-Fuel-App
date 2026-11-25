import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../configs/app_colors.dart';
import '../../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../../../../widgets/component/custom_camera_view.dart';
import '../../../../widgets/dialog/dialog_flexible.dart';
import '../../../../helpers/network_error_helper.dart';
import '../../../helpers/lotties_helper.dart';
import '../services/pengembalian_service.dart';
import 'pengembalian_controller.dart';

class PengembalianProsesController extends GetxController {
  final PengembalianService _service = Get.find<PengembalianService>();

  late PengembalianSolarModel data;
  
  final isLoading = false.obs;
  bool _isSubmitting = false;

  final foto1Path = RxnString();
  final foto2Path = RxnString();
  final foto3Path = RxnString();

  final keteranganController = TextEditingController();
  final varianLiterController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is PengembalianSolarModel) {
      data = Get.arguments as PengembalianSolarModel;
      varianLiterController.text = data.varianLiterTransfer.toString();
    } else {
      Get.back();
      Get.snackbar('Error', 'Data transaksi tidak ditemukan');
    }
  }

  @override
  void onClose() {
    keteranganController.dispose();
    varianLiterController.dispose();
    super.onClose();
  }

  Future<void> pickImage(int index, String label) async {
    try {
      final String? resultPath = await Get.to(() => CustomCameraView(
            label: label,
          ));

      if (resultPath != null) {
        File originalFile = File(resultPath);
        File? compressedFile = await _compressImage(originalFile);

        if (compressedFile != null) {
          if (index == 1) foto1Path.value = compressedFile.path;
          if (index == 2) foto2Path.value = compressedFile.path;
          if (index == 3) foto3Path.value = compressedFile.path;
        }
      }
    } catch (e) {
      DialogFlexible.showInfo(
        title: 'Gagal Mengambil Foto',
        message: 'Kamera tidak merespons. Silakan coba lagi.',
        color: AppColors.alertSoftRed,
        icon: Icons.camera_alt_outlined,
      );
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final lastIndex = file.path.lastIndexOf(RegExp(r'\.jp', caseSensitive: false));
      if (lastIndex == -1) return file; 

      final splitted = file.path.substring(0, (lastIndex));
      final outPath = "${splitted}_compressed.jpg";

      final outCheck = File(outPath);
      if (await outCheck.exists()) {
        await outCheck.delete();
      }

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 75,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (result != null) {
        await file.delete();
        return File(result.path);
      }
      return file;
    } catch (e) {
      return file; 
    }
  }

  void removeImage(int index) {
    if (index == 1) foto1Path.value = null;
    if (index == 2) foto2Path.value = null;
    if (index == 3) foto3Path.value = null;
  }

  Future<void> submit() async {
    if (_isSubmitting) return;

    // Dismiss keyboard and lingering snackbars
    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    // Parse sebagai double agar nilai desimal (misal 81.04) tidak berubah menjadi 0
    final double varianInput =
        double.tryParse(varianLiterController.text.trim().replaceAll(',', '.')) ??
            data.varianLiterTransfer.toDouble();

    if (foto1Path.value == null) {
      _showError('Wajib melampirkan Foto Pengambilan Solar.');
      return;
    }

    _isSubmitting = true;
    try {
      final bool? confirm = await Get.dialog<bool>(
        DialogFlexible(
          title: 'Konfirmasi Submit',
          message: 'Apakah Anda yakin ingin menyelesaikan proses pengembalian solar ini?',
          primaryButtonText: 'Ya, Submit',
          secondaryButtonText: 'Batal',
          logo: LottiesHelper().getLottieConfirmation(),
        ),
        barrierDismissible: false,
      );

      if (confirm == true) {
        await Future.delayed(const Duration(milliseconds: 150));
        await _doSubmit(varianInput);
      }
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> _doSubmit(double varianInput) async {
    final closeLoading = DialogFlexible.showLoading(
      title: "Memproses Pengembalian...",
      subtitle: "Mohon tunggu sebentar",
      color: AppColors.primary,
    );

    try {
      bool success = await _service.submitPengembalian(
        data: data,
        varianLiterPengembalian: varianInput,
        keterangan: keteranganController.text.isEmpty ? "-" : keteranganController.text,
        foto1Path: foto1Path.value,
      );

      closeLoading();

      if (success) {
        Get.snackbar(
          'Berhasil',
          'Pengembalian Solar Selesai',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.until((route) => Get.currentRoute == '/pengembalian');
        
        // Refresh list
        try {
           final listController = Get.find<PengembalianController>();
           listController.fetchData();
        } catch(e) {}
      } else {
        DialogFlexible.showInfo(
          title: 'Gagal Submit',
          message: 'Gagal mengirim pengembalian. Periksa koneksi internet dan coba lagi.',
          color: AppColors.alertSoftRed,
          icon: Icons.error_outline_rounded,
        );
      }
    } catch (e) {
      closeLoading();
      DialogFlexible.showInfo(
        title: 'Gagal Submit',
        message: NetworkErrorHelper.getFriendlyErrorMessage(e),
        color: AppColors.alertSoftRed,
        icon: Icons.error_outline_rounded,
      );
    } finally {
      closeLoading();
    }
  }

  void _showError(String message) {
    DialogFlexible.showInfo(
      title: 'Data Belum Lengkap',
      message: message,
      color: AppColors.primary,
      icon: Icons.warning_amber_rounded,
    );
  }
}
