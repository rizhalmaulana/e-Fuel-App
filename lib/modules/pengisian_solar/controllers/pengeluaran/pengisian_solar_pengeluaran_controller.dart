import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../configs/app_colors.dart';
import '../../../../routes/app_pages.dart';
import '../../../auth/services/login_service.dart';
import '../../../transactions/outstanding_service.dart';

class PengisianSolarPengeluaranController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final ImagePicker _picker = ImagePicker();

  final noDoc = '-'.obs;
  final noIO = '-'.obs;
  final unitIO = '-'.obs;
  final noPolisi = '-'.obs;
  final namaSupir = '-'.obs;
  final tanggal = '-'.obs;
  final jumlahSolar = '-'.obs;
  final KmPengisian = '-'.obs;
  final status = '-'.obs;
  final tipeUnit = '-'.obs;

  // [BARU] Variable untuk Foto Supir & Truk
  var fotoSupir = Rxn<File>();
  var fotoTruk = Rxn<File>();
  Map<String, dynamic> fullDataArgs = {};

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    fullDataArgs = Map<String, dynamic>.from(args);

    noDoc.value = args['noDoc'] ?? '-';
    noIO.value = args['noIO'] ?? '-';
    unitIO.value = args['unitIO'] ?? '-';
    noPolisi.value = args['noPolisi'] ?? '-';
    namaSupir.value = args['nama_supir'] ?? '-';
    tanggal.value = args['tanggal'] ?? '-';
    KmPengisian.value = (args['km_pengisian'] ?? '0').toString();
    jumlahSolar.value = (args['jumlah_pengisian_solar'] ?? '0').toString();
    status.value = args['status'] ?? 'pengisian_solar';
    tipeUnit.value = (args['tipe_unit'] ?? '-').toString();
  }

  Future<void> takePhoto(bool isSupir) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 1024,
      );

      if (photo != null) {
        if (isSupir) {
          fotoSupir.value = File(photo.path);
        } else {
          fotoTruk.value = File(photo.path);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil gambar: $e");
    }
  }

  void removePhoto(bool isSupir) {
    if (isSupir) {
      fotoSupir.value = null;
    } else {
      fotoTruk.value = null;
    }
  }

  double _parseToDouble(String value) {
    if (value == '-' || value.isEmpty) return 0.0;
    String cleanValue = value.replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  Future<void> saveAndExit() async {
    final auth = _loginService.getCurrentAuth();
    final username = auth?.user.username ?? "";

    if (username.isNotEmpty && noDoc.value != '-') {
      try {
        final outstandingService = OutstandingService(username);

        double solarVal = _parseToDouble(jumlahSolar.value);
        double kmVal = _parseToDouble(KmPengisian.value);

        if (solarVal > 0 && kmVal > 0) {
          await outstandingService.updateDetailPengeluaran(noDoc.value, solarVal, kmVal);
        }

        await outstandingService.updateStatusPengeluaran(
            noDoc.value,
            'pengisian_solar_pengeluaran'
        );
      } catch (e) {
        print("Error saving exit status pengeluaran: $e");
      }
    }
    Get.offAllNamed(Routes.HOME);
  }

  Future<void> finishTransaction() async {
    if (fotoSupir.value == null || fotoTruk.value == null) {
      Get.snackbar(
        "Foto Belum Lengkap",
        "Harap ambil Foto Supir dan Foto Mobil Truk terlebih dahulu.",
        backgroundColor: AppColors.alertSoftRed,
        colorText: AppColors.white,
      );
      return;
    }

    final auth = _loginService.getCurrentAuth();
    final username = auth?.user.username ?? "";

    if (username.isNotEmpty && noDoc.value != '-') {
      try {
        final outstandingService = OutstandingService(username);

        double solarVal = _parseToDouble(jumlahSolar.value);
        double kmVal = _parseToDouble(KmPengisian.value);

        await outstandingService.updateDetailPengeluaran(noDoc.value, solarVal, kmVal);

        await outstandingService.updateStatusPengeluaran(
            noDoc.value,
            'verifikasi_pengeluaran'
        );
      } catch (e) {
        print("Error update status pengisian pengeluaran: $e");
      }
    }

    // Kirim data foto ke halaman verifikasi
    fullDataArgs['foto_supir'] = fotoSupir.value?.path;
    fullDataArgs['foto_truk'] = fotoTruk.value?.path;

    // Kirim Paket Data Lengkap ke Halaman Verifikasi
    Get.offNamed(
        Routes.PENGELUARAN_VERIFIKASI_DOC,
        arguments: fullDataArgs
    );
  }
}