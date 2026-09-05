import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../configs/app_colors.dart';
import '../../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../../../../widgets/component/custom_camera_view.dart';
import '../../../../widgets/dialog/dialog_flexible.dart';
import '../../../helpers/lotties_helper.dart';
import '../services/pengembalian_service.dart';
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
      varianLiterController.text = data.varianLiterTransfer.toString();
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
    int varianInput = int.tryParse(varianLiterController.text.toString()) ?? 0;

    // if (varianInput <= 0) {
    //   _showError('Varian Liter harus lebih dari 0.');
    //   return;
    // }

    // if (varianInput > data.varianLiter) {
    //   _showError('Varian Liter tidak boleh melebihi sisa liter (${data.varianLiter}).');
    //   return;
    // }

    if (foto1Path.value == null) {
      _showError('Wajib melampirkan Foto Pengambilan Solar.');
      return;
    }

    // if (keteranganController.text.isEmpty) {
    //   _showError('Keterangan wajib diisi.');
    //   return;
    // }

    Get.dialog(
      DialogFlexible(
        title: 'Konfirmasi Submit',
        message: 'Apakah Anda yakin ingin menyelesaikan proses pengembalian solar ini?',
        primaryButtonText: 'Ya, Submit',
        onPrimaryPressed: () {
          Get.back();
          _doSubmit(varianInput);
        },
        secondaryButtonText: 'Batal',
        onSecondaryPressed: () => Get.back(),
        logo: LottiesHelper().getLottieConfirmation(),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _doSubmit(int varianInput) async {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Color(0xFF003366)),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  "Memproses pengembalian...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      bool success = await _service.submitPengembalian(
        data: data,
        varianLiterPengembalian: varianInput,
        keterangan: keteranganController.text.isEmpty ? "-" : keteranganController.text,
        foto1Path: foto1Path.value,
      );

      Get.back(); // close loading dialog

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
        Get.snackbar('Gagal', 'Gagal submit pengembalian.', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.back(); // close dialog
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e', backgroundColor: Colors.red, colorText: Colors.white);
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
