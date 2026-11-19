import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../widgets/component/custom_camera_view.dart';
import '../../../../widgets/dialog/dialog_flexible.dart';
import '../../../../configs/app_colors.dart';
import '../views/transfer_loading_view.dart' as transfer_loading;
import '../../../../datas/models/transfer/transfer_solar_model.dart';

class TransferProsesController extends GetxController {
  final TransferSolarModel data;

  TransferProsesController({required this.data});

  late final TextEditingController namaUnitController;
  late final TextEditingController noKendaraanController;
  late final TextEditingController noTransaksiController;
  late final TextEditingController noIOController;
  late final TextEditingController totalLiterController;
  late final String dateInbound;

  final isTakingPhoto = false.obs;
  final fotoOdometer = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    namaUnitController = TextEditingController(text: data.namaUnit);
    noKendaraanController = TextEditingController(text: data.nopolCheck);
    noTransaksiController = TextEditingController(text: data.noDoc);
    noIOController = TextEditingController(text: data.noIo);
    totalLiterController = TextEditingController(text: data.aktualLiter.toString());
    dateInbound = data.dateInbound;
  }

  @override
  void onClose() {
    namaUnitController.dispose();
    noKendaraanController.dispose();
    noTransaksiController.dispose();
    noIOController.dispose();
    totalLiterController.dispose();
    super.onClose();
  }

  Future<void> takeOdometerPhoto() async {
    try {
      isTakingPhoto.value = true;

      final String? resultPath = await Get.to(() => const CustomCameraView(
            label: "Foto Odometer Kendaraan",
          ));

      if (resultPath == null) {
        isTakingPhoto.value = false;
        return;
      }

      File originalFile = File(resultPath);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        fotoOdometer.value = compressedFile;
      }
    } catch (e) {
      DialogFlexible.showInfo(
        title: 'Gagal Mengambil Foto',
        message: 'Kamera tidak merespons. Silakan coba lagi.',
        color: AppColors.alertSoftRed,
        icon: Icons.camera_alt_outlined,
      );
    } finally {
      isTakingPhoto.value = false;
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
        quality: 75,
        minWidth: 1024,
        minHeight: 1024,
      );

      await file.delete();
      return result != null ? File(result.path) : null;
    } catch (e) {
      return file; 
    }
  }

  void submit() {
    if (fotoOdometer.value == null) {
      DialogFlexible.showInfo(
        title: 'Foto Belum Dilampirkan',
        message: 'Foto Odometer kendaraan wajib dilampirkan.',
        color: AppColors.primaryOrange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    // Save foto1 path to model temporarily before going to loading
    data.foto1Path = fotoOdometer.value!.path;

    // Arahkan ke halaman Loading Transfer
    Get.to(() => transfer_loading.TransferLoadingView(data: data));
  }
}
