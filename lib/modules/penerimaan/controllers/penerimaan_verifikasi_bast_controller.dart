import 'dart:async';
import 'dart:io';

import 'package:e_fuel/configs/app_lotties.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/component/custom_snackbar.dart';
import 'package:lottie/lottie.dart';
import 'package:signature/signature.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../datas/models/filling/filling_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../helpers/connectivity_helper.dart';
import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';
import '../repositories/penerimaan_verifikasi_bast_repository.dart';

class PenerimaanVerifikasiBastController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();

  late PenerimaanVerifikasiBastRepository _repository;

  final fillingDataList = <FillingModel>[].obs;
  final Rx<TransactionModel?> currentTransaction = Rx<TransactionModel?>(null);

  // UI Header
  final totalVolumeDisplay = 0.0.obs;
  final totalVolumeReceived = 0.0.obs;
  final tankListDisplay = <Map<String, String>>[].obs;
  final selectedStorage = "".obs;
  final activeNoBast = "".obs;
  final activeNoPO = "".obs;
  final isSensorApiActive = false.obs;

  final pageController = PageController();
  final currentPage = 0.obs;

  // Form Controllers
  final volumePengirimController = TextEditingController();
  final volumeKebunController = TextEditingController();
  final varianController = TextEditingController();

  final catatanGudangController = TextEditingController();
  final signatureGudangController = SignatureController(
    penStrokeWidth: 3, penColor: AppColors.darkText, exportBackgroundColor: AppColors.white,
  );

  final signaturePartnerController = SignatureController(
    penStrokeWidth: 3, penColor: AppColors.darkText, exportBackgroundColor: AppColors.white,
  );

  final securityNameController = TextEditingController();
  final signatureSecurityController = SignatureController(
    penStrokeWidth: 3, penColor: AppColors.darkText, exportBackgroundColor: AppColors.white,
  );

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
    _loadTransactionContext();
  }

  void _initializeRepository() {
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _repository = PenerimaanVerifikasiBastRepository(auth.user.username);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  // Load Data Sebelumnya pada Halaman Sebelumnya
  Future<void> _loadTransactionContext() async {
    final args = Get.arguments;
    if (args != null) {
      // STORAGE CODE LANGSUNG DARI ARGUMEN
      if (args['storageCode'] != null) {
        selectedStorage.value = args['storageCode'];
      }

      // NOMOR BAST, NOMOR PO & LOAD FULL DATA TRANSAKSI
      if (args['noBast'] != null && args['noPO'] != null) {
        activeNoBast.value = args['noBast'];
        activeNoPO.value = args['noPO'];
        await _loadFullTransactionData(activeNoBast.value);
      }

      // DATA TANGKI
      if (args['filling_models'] != null) {
        List<FillingModel> data = args['filling_models'] as List<FillingModel>;
        fillingDataList.assignAll(data);
        _calculateHeaderData(data);
      } else {
        await _reconstructFillingDataFromDraft();
      }
    }
  }

  Future<void> _reconstructFillingDataFromDraft() async {
    if (currentTransaction.value == null) return;

    final trx = currentTransaction.value!;
    final detailSebelum = trx.dataSebelum;

    if (detailSebelum == null) return;

    try {
      Map<String, double> volBeforeMap = _repository.parseDetailJson(detailSebelum.manualTankDetailsJson, 'volume_manual', 'height_manual');
      Map<String, double> heightBeforeMap = _repository.parseDetailJsonHeight(detailSebelum.manualTankDetailsJson, 'height_manual');
      Map<String, double> volBeforeIoTMap = _repository.parseDetailJson(detailSebelum.iotTankDetailsJson, 'volume_iot', 'height_iot');
      Map<String, double> heightBeforeIoTMap = _repository.parseDetailJsonHeight(detailSebelum.iotTankDetailsJson, 'height_iot');

      final draftSesudah = await _repository.getDraftSesudah(activeNoBast.value);

      if (draftSesudah == null || draftSesudah.isEmpty) return;

      List<FillingModel> restoredList = [];

      draftSesudah.forEach((tankCodeRaw, values) {
        String tankCode = tankCodeRaw.toString();
        double volAfter = 0.0;
        double hAfter = 0.0;

        if (values is Map) {
          volAfter = double.tryParse(TextConvertHelper().cleanNumber(values['volume'] ?? '0')) ?? 0.0;
          hAfter = double.tryParse(TextConvertHelper().cleanNumber(values['height'] ?? '0')) ?? 0.0;
        }

        double volBefore = volBeforeMap[tankCode] ?? 0.0;
        double hBefore = heightBeforeMap[tankCode] ?? 0.0;
        double volIoTBefore = volBeforeIoTMap[tankCode] ?? 0.0;
        double hIoTBefore = heightBeforeIoTMap[tankCode] ?? 0.0;

        restoredList.add(FillingModel(
            transactionId: activeNoBast.value,
            storageCode: detailSebelum.storageCode ?? "",
            tankCode: tankCode,
            timestamp: DateTime.now().toIso8601String(),

            volumeBefore: volBefore,
            heightBefore: hBefore,
            volumeAfter: volAfter,
            heightAfter: hAfter,
            volumeVariant: volAfter - volBefore,
            heightVariant: hAfter - hBefore,

            volumeBeforeIoT: volIoTBefore,
            heightBeforeIoT: hIoTBefore,
            volumeAfterIoT: volIoTBefore,
            heightAfterIoT: hIoTBefore,
            volumeVariantIoT: 0,
            heightVariantIoT: 0
        ));
      });

      fillingDataList.assignAll(restoredList);
      _calculateHeaderData(restoredList);

    } catch (e) {
      CustomSnackbar.show(
        title: "Error Data",
        message: "Gagal memulihkan data pengukuran: $e",
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  Future<void> _loadFullTransactionData(String noBast) async {
    final trx = await _repository.getTransaction(noBast);

    if (trx != null) {
      currentTransaction.value = trx;
      final detail = trx.dataSebelum;
      if (detail != null) {
        if (detail.storageCode != null && detail.storageCode!.isNotEmpty) {
          selectedStorage.value = detail.storageCode!;
        }

        if (detail.volumeVendor != null) {
          volumePengirimController.text = TextConvertHelper().formatNumber(detail.volumeVendor!);
          hitungVarian(); // Trigger perhitungan varian awal
        }
      }
    }
  }

  void _calculateHeaderData(List<FillingModel> data) {
    double tempTotalAfter = 0.0;
    double tempTotalReceived = 0.0;
    List<Map<String, String>> tempList = [];

    for (var item in data) {
      tempTotalAfter += item.volumeAfter;
      tempTotalReceived += item.volumeVariant;

      tempList.add({
        'code': item.tankCode.replaceAll('_', ' '),
        'volume': "${TextConvertHelper().formatNumber(item.volumeAfter)} L",
        'height': "${TextConvertHelper().formatNumber(item.heightAfter)} mm",
      });

      if (selectedStorage.value.isEmpty && item.storageCode.isNotEmpty) {
        selectedStorage.value = item.storageCode;
      }
    }

    totalVolumeDisplay.value = tempTotalAfter;
    totalVolumeReceived.value = tempTotalReceived;
    tankListDisplay.assignAll(tempList);

    volumeKebunController.text = TextConvertHelper().formatNumber(tempTotalReceived);
    hitungVarian();
  }

  void hitungVarian() {
    double pengirim = double.tryParse(volumePengirimController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    double kebun = double.tryParse(volumeKebunController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

    // Varian adalah sisa solar di Pengirim (Pengirim - Diterima Kebun)
    double varian = kebun - pengirim;
    varianController.text = TextConvertHelper().formatNumber(varian);
  }

  void nextPage() {
    if (!_validateCurrentPage()) return;
    if (currentPage.value < 3) {
      pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      submitBast();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    } else {
      Get.back();
    }
  }

  void onPageChanged(int index) { currentPage.value = index; }

  bool _validateCurrentPage() {
    if (currentPage.value == 1) return _validateStepPengukuran();
    if (currentPage.value == 2) return _validateStepGudang();
    if (currentPage.value == 3) return _validateStepPartner();
    return true;
  }

  bool _validateStepPengukuran() {
    if (volumePengirimController.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: "Data Kurang",
        message: "Volume Pengirim wajib diisi.",
        backgroundColor: AppColors.alertSoftRed,
        textColor: AppColors.white,
      );
      return false;
    }

    double volDiterima = double.tryParse(volumeKebunController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    if (volDiterima <= 0) {
      CustomSnackbar.show(
        title: "Data Invalid",
        message: "Volume Solar Diterima masih 0 atau minus. Pastikan data pengukuran valid.",
        backgroundColor: AppColors.alertSoftRed,
        textColor: AppColors.white,
      );
      return false;
    }
    return true;
  }

  bool _validateStepGudang() {
    if (signatureGudangController.isEmpty) {
      CustomSnackbar.show(
        title: "Tanda Tangan Kosong",
        message: "Mohon lengkapi Tanda Tangan Bagian Gudang.",
        backgroundColor: AppColors.alertSoftRed,
        textColor: AppColors.white,
      );
      return false;
    }
    return true;
  }

  bool _validateStepPartner() {
    if (signaturePartnerController.isEmpty) {
      CustomSnackbar.show(
        title: "Tanda Tangan Kosong",
        message: "Mohon lengkapi Tanda Tangan Supir / Partner Pengirim.",
        backgroundColor: AppColors.alertSoftRed,
        textColor: AppColors.white,
      );
      return false;
    }

    if (signatureSecurityController.isEmpty) {
      CustomSnackbar.show(
        title: "Tanda Tangan Kosong",
        message: "Mohon lengkapi Tanda Tangan Security.",
        backgroundColor: AppColors.alertSoftRed,
        textColor: AppColors.white,
      );
      return false;
    }
    return true;
  }

  Future<void> submitBast() async {
    if (!await ConnectivityHelper.validateNetwork()) return;

    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(AppLotties.confirmation, width: 150, height: 150),
        title: "Konfirmasi Submit",
        message: "Apakah Anda yakin data dan tanda tangan sudah benar?",
        primaryColor: AppColors.primary,
        secondaryButtonText: "Cek Lagi",
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: "Ya, Submit",
        onPrimaryPressed: () {
          Get.back();
          Future.delayed(const Duration(milliseconds: 300), () {
            _processSubmit();
          });
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _processSubmit() async {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 24),
              Text("Memproses Verifikasi...", style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final auth = _loginService.getCurrentAuth();
      final currentTx = currentTransaction.value;
      if (auth == null || currentTx == null) throw "Data tidak valid.";

      // Validate Approval Config
      File? fileGudang = await _repository.saveSignatureToFile(signatureGudangController, "ttd_gudang_${activeNoBast.value}.png");
      File? filePartner = await _repository.saveSignatureToFile(signaturePartnerController, "ttd_partner_${activeNoBast.value}.png");
      File? fileSecurity = await _repository.saveSignatureToFile(signatureSecurityController, "ttd_security_${activeNoBast.value}.png");

      if (fileGudang == null || filePartner == null || fileSecurity == null) throw "Gagal menyimpan Tanda Tangan.";

      String userLevel = auth.user.otorisasi.first;
      String kodeUnit = currentTransaction.value?.dataSebelum?.kodeUnit ?? "";
      String docType = currentTransaction.value?.dataSebelum?.docTypeCode ?? "FIN";

      // Validate Approval Config
      List<KonfigurasiApprovalModel> configList = await _repository.getKonfigurasiApproval(
        transactionType: docType, kodeUnit: kodeUnit, statusActive: true,
      );

      KonfigurasiApprovalModel myConfig = configList.firstWhere(
            (config) => config.levelApproval == userLevel,
        orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval.",
      );

      // Prepare Payload
      List<Map<String, dynamic>> tanksPayload = fillingDataList.map((item) {
        return {
          "kode_tank": item.tankCode,
          "volume_terkini_liter": item.volumeBeforeIoT ?? 0.0,
          "tinggi_terkini_cm": item.heightBeforeIoT ?? 0.0,
          "volume_akhir_liter": item.volumeAfterIoT ?? 0.0,
          "tinggi_akhir_cm": item.heightAfterIoT ?? 0.0,
          "tinggi_var_cm": item.heightVariantIoT ?? 0.0,
          "volume_var_liter": item.volumeVariantIoT ?? 0.0,
          "volume_manual_liter": item.volumeAfter,
          "tinggi_manual_cm": item.heightAfter,
          "volume_manual_var": item.volumeVariant,
          "tinggi_manual_var": item.heightVariant,
          "input_type": "M",
        };
      }).toList();

      // Submit Inbound Tank
        await _repository.createInboundTank({
        "no_doc": activeNoBast.value,
        "no_po": activeNoPO.value,
        "tanks": tanksPayload,
      });

      // Create Approval
      try {
        await _repository.createTransactionApproval(
          noDoc: activeNoBast.value, kodeUnit: kodeUnit, transactionType: docType,
        );
      } catch (e) { print("Warning create approval: $e"); }

      // Update Status & Upload Sign
      await _repository.updateStatusTransactionApproval(
        noDoc: activeNoBast.value,
        levelApproval: myConfig.levelApproval ?? "1",
        statusApprove: "APPROVED",
        catatan: catatanGudangController.text.isEmpty ? "Verifikasi BAST Selesai" : catatanGudangController.text,
        isSign: true, isPartnerSign: true,
      );

      await _repository.uploadSignatureTransactionApproval(
        noDoc: activeNoBast.value,
        levelApproval: myConfig.levelApproval ?? "1",
        imageSign1: fileGudang, imageSign2: fileSecurity,
      );

      // Post Data for Security, and signature
      await _repository.uploadSignatureSecurity(
        noDoc: activeNoBast.value,
        imageSign3: fileSecurity,
        securityName: securityNameController.text.isEmpty ? "Security" : securityNameController.text,
      );

      // Save Local & Update Status Local
      for (var item in fillingDataList) {
        await _repository.saveManualTankInput(tankCode: item.tankCode, volume: item.volumeAfter, height: item.heightAfter);
      }

      await _repository.updateLocalTransactionStatus(
        activeNoBast.value,
        'approval_kasie',
        levelApproval: myConfig.levelApproval,
        stepApproval: myConfig.stepApproval,
      );

      Get.back();
      _showResultDialog(isSuccess: true, message: "Dokumen berhasil disetujui dan diteruskan.");

    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      String errorMessage = (e is String) ? e : TextConvertHelper().handleApiError(e);
      print("ERROR SUBMIT BAST: $e");

      _showResultDialog(isSuccess: false, message: errorMessage);
    }
  }

  void _showResultDialog({required bool isSuccess, required String message}) {
    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(
            isSuccess ? AppLotties.success : AppLotties.failed,
            width: 150,
            height: 150,
            repeat: !isSuccess
        ),
        title: isSuccess ? "Berhasil" : "Gagal Memproses",
        message: message,
        primaryButtonText: isSuccess ? "Selesai" : "Tutup",
        onPrimaryPressed: () {
          Get.back();

          if (isSuccess) {
            Get.offAllNamed(Routes.HOME);
          }
          // isSuccess bernilai false (Gagal), maka tidak melakukan apa-apa lagi
          // setelah Get.back(), sehingga user tetap berada di halaman form (stay).
        },
      ),
      barrierDismissible: false, // User tidak bisa klik sembarang tempat untuk menutup dialog
    );
  }

  @override
  void onClose() {
    volumePengirimController.dispose(); volumeKebunController.dispose();
    varianController.dispose(); catatanGudangController.dispose(); securityNameController.dispose();
    signatureGudangController.dispose(); signatureSecurityController.dispose();
    signaturePartnerController.dispose();pageController.dispose();
    super.onClose();
  }
}