import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:path_provider/path_provider.dart'; // Untuk akses folder device
import 'package:path/path.dart' as p;

import 'package:e_fuel/configs/app_lotties.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:signature/signature.dart';

import '../../../configs/app_colors.dart';
import '../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../datas/models/filling/filling_model.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../helpers/connectivity_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../transactions/penerimaan/services/outstanding_service.dart';
import '../../transactions/penerimaan/services/penerimaan_api_service.dart';

class PenerimaanVerifikasiBastController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final PenerimaanApiService _apiService = PenerimaanApiService();

  // Data Utama
  final fillingDataList = <FillingModel>[].obs;
  final ConnectivityHelper _connectivityHelper = Get.find<ConnectivityHelper>();

  // Menampung Data Transaksi Lengkap (Sebelum Pengisian)
  final Rx<TransactionModel?> currentTransaction = Rx<TransactionModel?>(null);

  // Data UI Header
  final totalVolumeDisplay = 0.0.obs;
  final tankListDisplay = <Map<String, String>>[].obs;
  final selectedStorage = "".obs;
  final activeNoBast = "".obs;

  final pageController = PageController();
  final currentPage = 0.obs;

  // --- FORM CONTROLLERS (STEP 2) ---
  final stdPanjangController = TextEditingController(text: "0");
  final stdLebarController = TextEditingController(text: "0");
  final stdTinggiController = TextEditingController(text: "0");

  final actPanjangController = TextEditingController(text: "0");
  final actLebarController = TextEditingController(text: "0");
  final actTinggiController = TextEditingController(text: "0");

  final volumeDiterimaLtrController = TextEditingController();
  final volumePengirimController = TextEditingController(); // Akan diisi otomatis
  final volumeKebunController = TextEditingController();
  final varianController = TextEditingController();

  final catatanGudangController = TextEditingController();
  final signatureGudangController = SignatureController(
    penStrokeWidth: 3, penColor: AppColors.darkText, exportBackgroundColor: AppColors.white,
  );
  final signatureSupirController = SignatureController(
    penStrokeWidth: 3, penColor: AppColors.darkText, exportBackgroundColor: AppColors.white,
  );

  @override
  void onInit() {
    super.onInit();
    _loadTransactionContext();
  }

  Future<void> _loadTransactionContext() async {
    final args = Get.arguments;

    if (args != null) {
      if (args['noBast'] != null) {
        activeNoBast.value = args['noBast'];
        await _loadFullTransactionData(activeNoBast.value);
      }

      // 2. Load Data Pengisian (SESUDAH)
      if (args['filling_models'] != null) {
        List<FillingModel> data = args['filling_models'] as List<FillingModel>;
        fillingDataList.assignAll(data);
        _calculateHeaderData(data);
      }
    }
  }

  Future<void> _loadFullTransactionData(String noBast) async {
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      final outstandingService = OutstandingService(auth.user.username);
      final trx = await outstandingService.getTransactionByNoBast(noBast);

      if (trx != null) {
        currentTransaction.value = trx;

        final detail = trx.dataSebelum;

        if (detail != null) {
          if (detail.storageCode != null) {
            selectedStorage.value = detail.storageCode!;
          }
          if (detail.volumeVendor != null) {
            volumePengirimController.text = detail.volumeVendor!.toStringAsFixed(0);
          }
        }
      }
    }
  }

  void _calculateHeaderData(List<FillingModel> data) {
    double tempTotal = 0.0;
    List<Map<String, String>> tempList = [];

    for (var item in data) {
      tempTotal += item.volumeAfter;
      tempList.add({
        'code': item.tankCode.replaceAll('_', ' '),
        'volume': "${item.volumeAfter.toStringAsFixed(0)} Ltr",
        'height': "${item.heightAfter.toStringAsFixed(0)} cm",
      });
    }

    totalVolumeDisplay.value = tempTotal;
    tankListDisplay.assignAll(tempList);

    // Auto Fill Volume Kebun (Total Hasil Ukur)
    String totalStr = tempTotal.toStringAsFixed(0);
    volumeDiterimaLtrController.text = totalStr;
    volumeKebunController.text = totalStr;

    // Hitung Varian setelah data terisi
    hitungVarian();
  }

  void hitungVarian() {
    double pengirim = double.tryParse(volumePengirimController.text.replaceAll('.', '')) ?? 0;
    double kebun = double.tryParse(volumeKebunController.text.replaceAll('.', '')) ?? 0;

    // Rumus: Kebun - Pengirim
    double varian = kebun - pengirim;
    varianController.text = varian.toStringAsFixed(0);
  }

  void nextPage() {
    // Cek validasi halaman saat ini sebelum lanjut
    if (!_validateCurrentPage()) return;

    if (currentPage.value < 3) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut
      );
    } else {
      submitBast();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      Get.back();
    }
  }

  void onPageChanged(int index) { currentPage.value = index; }

  bool _validateCurrentPage() {
    int page = currentPage.value;

    if (page == 0) return true;

    if (page == 1) {
      return _validateStepPengukuran();
    }

    if (page == 2) return true;
    return true;
  }

  bool _validateStepPengukuran() {
    bool checkEmpty(TextEditingController ctrl, String fieldName) {
      if (ctrl.text.trim().isEmpty) {
        Get.snackbar("Data Kurang", "$fieldName wajib diisi.",
            backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white, snackPosition: SnackPosition.TOP);
        return false;
      }

      if (double.tryParse(ctrl.text.replaceAll('.', '').replaceAll(',', '.')) == null) {
        Get.snackbar("Format Salah", "$fieldName harus berupa angka.",
            backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white, snackPosition: SnackPosition.TOP);
        return false;
      }
      return true;
    }

    // 1. Validasi Ukuran Standar
    if (!checkEmpty(stdPanjangController, "Panjang Standar")) return false;
    if (!checkEmpty(stdLebarController, "Lebar Standar")) return false;
    if (!checkEmpty(stdTinggiController, "Tinggi Standar")) return false;

    // 2. Validasi Ukuran Aktual / Diterima
    if (!checkEmpty(actPanjangController, "Panjang Diterima")) return false;
    if (!checkEmpty(actLebarController, "Lebar Diterima")) return false;
    if (!checkEmpty(actTinggiController, "Tinggi Diterima")) return false;

    // 3. Validasi Volume Pengirim (PENTING untuk Varian)
    if (!checkEmpty(volumePengirimController, "Volume Pengirim")) return false;

    // 4. (Opsional) Validasi Logika: Volume Diterima tidak boleh 0
    double volDiterima = double.tryParse(volumeDiterimaLtrController.text.replaceAll('.', '')) ?? 0;
    if (volDiterima <= 0) {
      Get.snackbar("Data Invalid", "Volume Solar Diterima masih 0. Cek input dimensi.",
          backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white, snackPosition: SnackPosition.TOP);
      return false;
    }

    return true;
  }

  Future<void> submitBast() async {
    if (signatureGudangController.isEmpty || signatureSupirController.isEmpty) {
      Get.snackbar(
          "Data Belum Lengkap",
          "Mohon lengkapi tanda tangan Gudang dan Supir sebelum submit.",
          backgroundColor: AppColors.alertSoftRed,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP
      );
      return;
    }

    bool isConnected = await _connectivityHelper.checkConnection();
    if (!isConnected) {
      _showConnectionErrorDialog();
      return;
    }

    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(AppLotties.confirmation, width: 150, height: 150),
        title: "Konfirmasi Submit",
        message: "Apakah Anda yakin data sudah benar? Proses submit tidak dapat diubah kembali.",

        // Tombol Batal
        secondaryButtonText: "Cek Lagi",
        onSecondaryPressed: () {
          Get.back();
        },

        // Tombol Submit (Langsung proses karena koneksi sudah dicek di awal)
        primaryButtonText: "Ya, Submit",
        onPrimaryPressed: () {
          Get.back();
          _processSubmit();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _processSubmit() async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      // =======================================================================
      // STEP 0: PREPARE DATA & SAVE SIGNATURE LOCAL FIRST
      // =======================================================================
      if (signatureGudangController.isEmpty) {
        throw "Tanda tangan Gudang (Penerima) wajib diisi!";
      }

      if (signatureSupirController.isEmpty) {
        throw "Tanda tangan Supir/Partner wajib diisi!";
      }

      final auth = _loginService.getCurrentAuth();
      final currentTx = currentTransaction.value;

      if (auth == null || currentTx == null) throw "Data user atau transaksi tidak valid.";

      File? fileGudang = await _saveSignature(
          signatureGudangController,
          "ttd_gudang_${activeNoBast.value}.png"
      );

      File? fileSupir = await _saveSignature(
          signatureSupirController,
          "ttd_supir_${activeNoBast.value}.png"
      );

      if (fileGudang == null || fileSupir == null) {
        throw "Gagal memproses gambar tanda tangan. Silakan coba tanda tangan ulang.";
      }

      String userLevel = auth.user.otorisasi.first;
      String kodeUnit = currentTransaction.value?.dataSebelum?.kodeUnit ?? "";
      String docType = currentTransaction.value?.dataSebelum?.docTypeCode ?? "FIN";

      if (kodeUnit.isEmpty) {
        throw "Kode Unit wajib diisi!";
      }

      /// =======================================================================
      // STEP 1: HIT API - CEK KONFIGURASI APPROVAL
      // =======================================================================
      List<KonfigurasiApprovalModel> configList = await _apiService.getKonfigurasiApproval(
        transactionType: docType,
        kodeUnit: kodeUnit,
        statusActive: true,
      );

      KonfigurasiApprovalModel myConfig = configList.firstWhere(
            (config) => config.levelApproval == userLevel,
        orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval.",
      );

      print("✅ Step 1: Validasi Approval Berhasil (ID: ${myConfig.id})");
      print("✅ Step 1: Validasi Approval Berhasil: Step ${myConfig.stepApproval}");

      // =======================================================================
      // STEP 2: HIT API - CREATE INBOUND TANK
      // =======================================================================

      List<Map<String, dynamic>> tanksPayload = fillingDataList.map((item) {
        return {
          "kode_tank": item.tankCode,
          "volume_terkini_liter": item.volumeBefore,
          "tinggi_terkini_cm": item.heightBefore,
          "volume_akhir_liter": item.volumeAfter,
          "tinggi_akhir_cm": item.heightAfter,
          "tinggi_var_cm": item.heightVariant,
          "volume_var_liter": item.volumeVariant,
        };
      }).toList();

      List<Map<String, dynamic>> iotPayload = [];
      for (var item in fillingDataList) {
        iotPayload.add({
          "kode_tank": item.tankCode,
          "iot_volume_terkini_liter": item.volumeBeforeIoT,
          "iot_tinggi_terkini_cm": item.heightBeforeIoT,
          "iot_volume_akhir_liter": item.volumeAfterIoT,
          "iot_tinggi_akhir_cm": item.heightAfterIoT,
          "iot_volume_var_liter": item.volumeVariantIoT,
          "iot_tinggi_var_cm": item.heightVariantIoT,
        });
      }

      double parseTxt(TextEditingController ctrl) =>
          double.tryParse(ctrl.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

      List<Map<String, dynamic>> standarPayload = fillingDataList.map((item) {
        return {
          "kode_tank": item.tankCode,
          "std_panjang_tangki_kebun": parseTxt(stdPanjangController),
          "std_lebar_tangki_kebun": parseTxt(stdLebarController),
          "std_tinggi_tangki_kebun": parseTxt(stdTinggiController),
          "std_panjang_diterima": parseTxt(actPanjangController),
          "std_lebar_diterima": parseTxt(actLebarController),
          "std_tinggi_diterima": parseTxt(actTinggiController),
          "volume_solar_diterima": parseTxt(volumeDiterimaLtrController),
          "volume_tangki_pengirim": parseTxt(volumePengirimController),
          "var_solar_tangki": parseTxt(varianController),
        };
      }).toList();

      Map<String, dynamic> inboundPayload = {
        "no_doc": activeNoBast.value,
        "tanks": tanksPayload,
        "iot_tanks": iotPayload,
        "ukuran_standar_tanks": standarPayload,
      };

      await _apiService.createInboundTank(inboundPayload);
      print("✅ Step 2: Create Inbound Tank Berhasil");

      // =======================================================================
      // STEP 3: HIT API - CREATE TRANSACTION APPROVAL (MULTIPART)
      // =======================================================================

      try {
        print("⏳ Step 3: Mencoba Create Transaction Approval...");
        await _apiService.createTransactionApproval(
          noDoc: activeNoBast.value,
          levelApprovalId: int.tryParse(myConfig.stepApproval.toString()) ?? 0,
          catatan: catatanGudangController.text.isEmpty
              ? "Verifikasi BAST Selesai"
              : catatanGudangController.text,
          imageSign1: fileGudang,
          imageSign2: fileSupir,
        );
        print("✅ Step 3: Transaction Approval Created");
      } catch (e) {
        print("⚠️ Step 3 Warning: Gagal create, mungkin data sudah ada? Lanjut ke Step 4. Error: $e");
      }

      // =======================================================================
      // STEP 4: HIT API - UPDATE STATUS TRANSACTION
      // =======================================================================

      await _apiService.updateStatusTransactionApproval(
        noDoc: activeNoBast.value,
        levelApproval: myConfig.levelApproval ?? "1",
        statusApprove: "APPROVED",
        catatan: catatanGudangController.text.isEmpty
            ? "Verifikasi BAST Selesai"
            : catatanGudangController.text,
        isSign: true,
        isPartnerSign: true,
      );

      print("✅ Step 4: Status Updated");

      // =======================================================================
      // FINAL: Save Local Data & Close
      // =======================================================================

      for (var item in fillingDataList) {
        await _fuelDataService.updateTankManualState(
            item.tankCode,
            item.volumeAfter,
            item.heightAfter
        );
      }

      // Update Status Transaksi di List Outstanding Local
      final outstandingService = OutstandingService(auth.user.username);
      var transaction = await outstandingService.getTransactionByNoBast(activeNoBast.value);

      await outstandingService.updateStatus(
        activeNoBast.value,
        'approval',
        levelApproval: myConfig.levelApproval,
        stepApproval: myConfig.stepApproval,
      );

      if (transaction != null) {
        transaction.status = 'approval';
        await transaction.save();
      }

      Get.back();

      _showResultDialog(
          isSuccess: true,
          message: "Data berhasil disubmit dan diteruskan untuk approval."
      );

    } catch (e) {
      Get.back();
      print("❌ Error Submit: $e");

      if (_isConnectionError(e)) {
        _showConnectionErrorDialog();
      } else {
        _showResultDialog(
            isSuccess: false,
            message: e.toString().replaceAll("Exception:", "").trim()
        );
      }
    }
  }

  Future<File?> _saveSignature(SignatureController controller, String fileName) async {
    if (controller.isEmpty) return null;

    final Uint8List? data = await controller.toPngBytes();
    if (data == null) return null;

    final Directory dir = await getApplicationDocumentsDirectory();
    final String fullPath = p.join(dir.path, fileName);

    final File file = File(fullPath);
    await file.writeAsBytes(data);

    print("Tanda tangan disimpan di: $fullPath");
    return file;
  }

  void _showResultDialog({required bool isSuccess, required String message}) {
    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(
          isSuccess ? AppLotties.success : AppLotties.failed,
          width: 150,
          height: 150,
          repeat: isSuccess ? false : true, // Error biasanya loop, sukses sekali main
        ),
        title: isSuccess ? "Berhasil" : "Gagal Memproses",
        message: message,
        primaryButtonText: isSuccess ? "Selesai" : "Tutup",
        onPrimaryPressed: () {
          Get.back(); // Tutup Dialog

          if (isSuccess) {
            // Jika sukses, pindah halaman
            Get.offNamed(Routes.PENERIMAAN_TRACKING);
          }
        },
      ),
      barrierDismissible: false, // User wajib tekan tombol untuk tutup
    );
  }

  bool _isConnectionError(dynamic e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.error is SocketException;
    }
    return e is SocketException;
  }

  void _showConnectionErrorDialog() {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(
          AppLotties.failed,
          width: 150,
          height: 150,
          repeat: true,
        ),
        title: "Koneksi Bermasalah",
        message: "Gagal terhubung ke server. Pastikan koneksi internet Anda stabil dan coba lagi.",
        primaryButtonText: "Tutup",
        onPrimaryPressed: () => Get.back(),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    stdPanjangController.dispose();
    stdLebarController.dispose();
    stdTinggiController.dispose();
    actPanjangController.dispose();
    actLebarController.dispose();
    actTinggiController.dispose();
    volumeDiterimaLtrController.dispose();

    volumePengirimController.dispose();
    volumeKebunController.dispose();
    varianController.dispose();
    catatanGudangController.dispose();
    signatureGudangController.dispose();
    signatureSupirController.dispose();
    pageController.dispose();
    super.onClose();
  }
}