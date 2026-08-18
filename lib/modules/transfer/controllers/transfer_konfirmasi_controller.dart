import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../widgets/component/custom_camera_view.dart';
import '../../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../services/transfer_offline_service.dart';
import '../../../../datas/models/transfer/transfer_solar_model.dart';
import '../controllers/transfer_controller.dart';

class TransferKonfirmasiController extends GetxController {
  final TransferSolarModel data;
  
  TransferKonfirmasiController({required this.data});

  late final TextEditingController aktualController;
  late final TextEditingController pengambilanController;
  
  final isTakingPhotoAlatBerat = false.obs;
  final isTakingPhotoOperator = false.obs;
  
  final fotoAlatBerat = Rx<File?>(null);
  final fotoOperator = Rx<File?>(null);

  final varianValue = 0.obs;

  @override
  void onInit() {
    super.onInit();
    aktualController = TextEditingController(text: '0');
    pengambilanController = TextEditingController(text: data.aktualLiter.toString());
    
    _calculateVarian();
    aktualController.addListener(_calculateVarian);
  }

  @override
  void onClose() {
    aktualController.removeListener(_calculateVarian);
    aktualController.dispose();
    pengambilanController.dispose();
    super.onClose();
  }

  void _calculateVarian() {
    int pengambilan = (data.aktualLiter).toInt();
    int aktual = int.tryParse(aktualController.text.replaceAll('.', '')) ?? 0;
    varianValue.value = pengambilan - aktual;
  }

  String get varianText {
    if (varianValue.value > 0) {
      return "+${varianValue.value}";
    }
    return varianValue.value.toString();
  }

  Future<void> takePhoto(bool isAlatBerat) async {
    try {
      if (isAlatBerat) {
        isTakingPhotoAlatBerat.value = true;
      } else {
        isTakingPhotoOperator.value = true;
      }

      final String? resultPath = await Get.to(() => CustomCameraView(
            label: isAlatBerat ? "Foto Alat Berat" : "Foto Operator",
          ));

      if (resultPath == null) {
        return;
      }

      File originalFile = File(resultPath);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        if (isAlatBerat) {
          fotoAlatBerat.value = compressedFile;
        } else {
          fotoOperator.value = compressedFile;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    } finally {
      isTakingPhotoAlatBerat.value = false;
      isTakingPhotoOperator.value = false;
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

  void submit() async {
    int aktual = int.tryParse(aktualController.text.replaceAll('.', '')) ?? 0;
    int pengambilan = (data.aktualLiter).toInt();

    if (aktualController.text.isEmpty) {
      _showError('Aktual Pengisian wajib diisi.');
      return;
    }

    if (aktual <= 0) {
      _showError('Aktual Pengisian tidak boleh 0 atau kurang.');
      return;
    }

    if (aktual > pengambilan) {
      _showError('Aktual Pengisian tidak boleh lebih dari Pengambilan (Varian minus).');
      return;
    }

    if (fotoAlatBerat.value == null) {
      _showError('Wajib melampirkan foto Alat Berat.');
      return;
    }

    if (fotoOperator.value == null) {
      _showError('Wajib melampirkan foto Operator.');
      return;
    }

    Get.defaultDialog(
      title: 'Konfirmasi',
      titleStyle: AppFonts.fUrbanistBold16,
      middleText: 'Apakah Anda yakin data Aktual Pengisian dan Foto sudah benar?',
      middleTextStyle: AppFonts.fUrbanistRegular14,
      textConfirm: 'Ya, Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryOrange,
      cancelTextColor: AppColors.primaryOrange,
      onConfirm: () {
        Get.back(); // close dialog
        _processSubmit(aktual);
      },
    );
  }

  void _processSubmit(int aktual) async {
    // Tampilkan Loading
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
      barrierDismissible: false,
    );

    // Proses Simpan Offline
    try {
      TransferOfflineService offlineService = Get.find<TransferOfflineService>();
      await offlineService.updateToOfflineSubmitted(
        id: data.id,
        aktualLiter: aktual,
        varianLiter: varianValue.value,
        foto1Path: data.foto1Path ?? '', // already assigned in Proses Controller
        foto2Path: fotoAlatBerat.value!.path,
        foto3Path: fotoOperator.value!.path,
      );

      Get.back(); // close dialog
      
      Get.snackbar(
        'Sukses',
        'Data Aktual Pengisian Solar berhasil disimpan secara offline',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh list in TransferController
      if (Get.isRegistered<TransferController>()) {
        Get.find<TransferController>().loadLocalData();
      }

      // Back to Transfer View
      Get.until((route) => Get.currentRoute == '/transfer' || route.isFirst);
      
    } catch (e) {
      Get.back();
      _showError('Gagal menyimpan data secara lokal.');
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
