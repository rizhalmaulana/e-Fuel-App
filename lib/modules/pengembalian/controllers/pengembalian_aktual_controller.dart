import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PengembalianAktualController extends GetxController {
  final isLoading = false.obs;
  
  final totalVolume = '4.784'.obs;
  final tank1Volume = '4.784'.obs;
  final tank2Volume = '0'.obs;
  
  final tank1Tinggi = '844'.obs;
  final tank2Tinggi = '844'.obs;

  void refreshStock() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      Get.snackbar(
        'Sukses',
        'Data stok tangki berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }

  void submit() {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF003366))),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      Get.back(); // close dialog
      
      Get.snackbar(
        'Berhasil',
        'Pengembalian Solar Selesai',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Temp: go back to home
      Get.offAllNamed('/home');
    });
  }
}
