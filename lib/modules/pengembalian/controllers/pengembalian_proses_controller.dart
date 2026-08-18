import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../configs/app_colors.dart';
import '../../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../services/pengembalian_service.dart';
import '../../../../widgets/dialog/dialog_flexible.dart';
import '../../../../widgets/component/custom_camera_view.dart';
import 'pengembalian_controller.dart';

class PengembalianProsesController extends GetxController {
  final PengembalianService _service = Get.find<PengembalianService>();

  late PengembalianSolarModel data;
  
  final isLoading = false.obs;

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
      varianLiterController.text = data.varianLiter.toString();
    } else {
      Get.back();
      Get.snackbar('Error', 'Data transaksi tidak ditemukan');
    }
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
      Get.snackbar('Error', 'Gagal mengambil gambar: $e',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final lastIndex = file.path.lastIndexOf(RegExp(r'.jp'));
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
        quality: 60,
        minWidth: 1024,
        minHeight: 1024,
      );

      await file.delete();
      return result != null ? File(result.path) : null;
    } catch (e) {
      return file; 
    }
  }

  void removeImage(int index) {
    if (index == 1) foto1Path.value = null;
    if (index == 2) foto2Path.value = null;
    if (index == 3) foto3Path.value = null;
  }

  void submit() {
    // Validate inputs
    int varianInput = int.tryParse(varianLiterController.text) ?? 0;
    
    if (varianInput <= 0) {
      _showError('Varian Liter harus lebih dari 0.');
      return;
    }

    if (varianInput > data.varianLiter) {
      _showError('Varian Liter tidak boleh melebihi sisa liter (${data.varianLiter}).');
      return;
    }

    if (foto1Path.value == null || foto2Path.value == null || foto3Path.value == null) {
      _showError('Wajib melampirkan ke-3 foto.');
      return;
    }

    if (keteranganController.text.isEmpty) {
      _showError('Keterangan wajib diisi.');
      return;
    }

    Get.dialog(
      DialogFlexible(
        title: 'Konfirmasi Submit',
        message: 'Apakah Anda yakin ingin memproses Pengembalian Solar ini ke server?',
        primaryButtonText: 'Ya, Submit',
        onPrimaryPressed: () {
          Get.back(); // close dialog
          _processSubmit(varianInput);
        },
        secondaryButtonText: 'Batal',
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  Future<void> _processSubmit(int varianInput) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
      barrierDismissible: false,
    );

    try {
      bool success = await _service.submitPengembalian(
        data: data,
        varianLiterPengembalian: varianInput,
        keterangan: keteranganController.text,
        foto1Path: foto1Path.value,
        foto2Path: foto2Path.value,
        foto3Path: foto3Path.value,
      );

      Get.back(); // close loading dialog

      if (success) {
        Get.snackbar(
          'Sukses', 
          'Pengembalian Solar berhasil disubmit',
          backgroundColor: Colors.green, 
          colorText: Colors.white,
        );
        Get.until((route) => Get.currentRoute == '/pengembalian');
        
        // Refresh list
        try {
           final listController = Get.find<PengembalianController>();
           listController.fetchData();
        } catch(e) {}

      }
    } catch (e) {
      Get.back(); // close loading
      String displayError = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Gagal', 
        displayError,
        backgroundColor: AppColors.alertSoftRed, 
        colorText: Colors.white, 
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Peringatan',
      message,
      backgroundColor: AppColors.alertSoftRed,
      colorText: Colors.white,
    );
  }
}
