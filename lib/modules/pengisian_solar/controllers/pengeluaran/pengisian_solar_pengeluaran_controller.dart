import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../configs/app_colors.dart';
import '../../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../../datas/models/pengeluaran/pengeluaran_model.dart';
import '../../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../../../helpers/connectivity_helper.dart';
import '../../../../helpers/network_error_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/component/custom_camera_view.dart';
import '../../../auth/services/login_service.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../home/services/home_service.dart';
import '../../../transactions/outstanding_service.dart';
import '../../../../helpers/lotties_helper.dart';
import '../../../../widgets/dialog/dialog_flexible.dart';
import '../../../transactions/pengeluaran/services/pengeluaran_api_service.dart';

class PengisianSolarPengeluaranController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final PengeluaranApiService _apiService = PengeluaranApiService();

  final HomeService _homeService = Get.find<HomeService>();
  final HomeController _homeController = Get.find<HomeController>();

  // Arguments Data
  final noDoc = '-'.obs;
  final noIO = '-'.obs;
  final costCenter = '-'.obs;
  final unitIO = '-'.obs;
  final noPolisi = '-'.obs;
  final namaSupir = '-'.obs;
  final tanggal = '-'.obs;
  final jumlahSolarArg = '-'.obs;
  final KmPengisian = '-'.obs;
  final status = '-'.obs;
  final tipeUnit = '-'.obs;
  final statusSupir = 'Internal'.obs;
  final messageResponse = ''.obs;
  final dateLogResponse = ''.obs;
  final isManualInput = false.obs;
  final isTamu = false.obs;
  final isVendor = false.obs;

  final List<String> jenisPengeluaranOptions = ['Bon Sementara', 'BPB'];
  final selectedJenisPengeluaran = 'Bon Sementara'.obs;

  // Input Data State
  final estimasiSolarC = TextEditingController();
  final aktualSolarC = TextEditingController();
  final varianSolarC = TextEditingController();
  final warehouseNoteController = TextEditingController();

  // Photo State
  var fotoSupir = Rxn<File>();
  var fotoDispenser = Rxn<File>();
  var isTakingPhoto = false.obs;

  // User Info
  late String _currentUserUnitCode;
  late String _currentInternalOrder;
  late String _ratioArg;
  late String _hmKmAkhirArg;
  late String _tanggalAkhirArg;

  String get currentDocType => 'FOT';

  final isSensorApiActive = false.obs;
  final isRefreshingSensor = false.obs;
  final isSubmitting = false.obs;
  String activeStorageCode = "";

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    _loadArguments();

    aktualSolarC.addListener(_calculateVarian);
  }

  @override
  void onClose() {
    estimasiSolarC.dispose();
    aktualSolarC.dispose();
    varianSolarC.dispose();
    warehouseNoteController.dispose();
    super.onClose();
  }

  void _loadArguments() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final Map<String, dynamic> payload = args['payload'] ?? {};

    noDoc.value = args['noDoc'] ?? '-';
    unitIO.value = args['unitIO'] ?? (payload['tipe_unit_io'] ?? args['tipe_unit_io'] ?? '-').toString();

    final String rawTanggal = args['tanggal']?.toString() ?? '';
    tanggal.value = rawTanggal.isNotEmpty
        ? (rawTanggal.contains('T')
            ? rawTanggal.split('T').first
            : (rawTanggal.contains(' ') ? rawTanggal.split(' ').first : rawTanggal))
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    status.value = args['status'] ?? 'pengisian_solar_pengeluaran';

    // Parse data murni dari payload
    noIO.value = payload['no_io']?.toString() ?? args['no_io'] ?? '-';
    costCenter.value = payload['cost_center']?.toString() ?? '-';
    noPolisi.value = payload['nopol_check']?.toString() ?? '-';
    namaSupir.value = payload['supir_check']?.toString() ?? '-';
    KmPengisian.value = (payload['km_pengisian'] ?? '0').toString();
    jumlahSolarArg.value = (payload['jumlah_pengisian_solar'] ?? '0').toString();
    tipeUnit.value = (payload['tipe_unit_io'] ?? args['tipe_unit_io'] ?? '-').toString();
    statusSupir.value = payload['status_supir']?.toString() ?? 'Internal';

    _currentInternalOrder = noIO.value;
    _ratioArg = (payload['ratio_input'] ?? payload['ratio'] ?? '0').toString();
    _hmKmAkhirArg = (payload['hm_km_akhir'] ?? '0').toString();
    _tanggalAkhirArg = (payload['tanggal_akhir'] ?? '').toString();

    String initialDocType = payload['jenis_pengeluaran'] ?? args['jenis_pengeluaran'] ?? payload['doc_type'] ?? 'FOT';
    selectedJenisPengeluaran.value = (initialDocType == 'BPB') ? 'BPB' : 'Bon Sementara';
    
    isManualInput.value = args['isManualInput'] ?? false;
    isTamu.value = unitIO.value.toUpperCase().contains('TAMU');
    // Kategori VENDOR dikirim dari form Pengeluaran; fallback ke payload
    // kategori_kendaraan ('VEN') bila dibuka dari jalur lain (tracking/draft).
    isVendor.value = (args['isVendor'] as bool?) ??
        (payload['kategori_kendaraan']?.toString().toUpperCase() == 'VEN');

    // Ambil storage code aktif dari Home Controller
    String rawStorage = _homeController.selectedStorage.value;
    activeStorageCode = rawStorage.contains('-') ? rawStorage.split('-').last.trim() : rawStorage.trim();

    estimasiSolarC.text = jumlahSolarArg.value;
    aktualSolarC.text = "";

    // Hitung varian awal berdasarkan estimasi (aktual = 0, varian = -estimasi)
    _calculateVarian();

    if (!isManualInput.value && !isTamu.value) {
      refreshSensorMonitoring();
    }
  }

  Future<void> refreshSensorMonitoring() async {
    if (isRefreshingSensor.value) return;
    isRefreshingSensor.value = true;

    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final stockStorageData = await _apiService.fetchLatestStockStorage(
          unitId: _currentUserUnitCode,
          storageCode: activeStorageCode,
          internalOrder: _currentInternalOrder,
          dateLog: today
      );

      if (stockStorageData != null && stockStorageData.success && stockStorageData.errorCode.isEmpty) {
        double flowOut = stockStorageData.volume;

        isSensorApiActive.value = true;
        messageResponse.value = stockStorageData.message;
        dateLogResponse.value = stockStorageData.dateLog;

        aktualSolarC.text = flowOut % 1 == 0
            ? flowOut.toInt().toString()
            : flowOut.toStringAsFixed(2);

        _calculateVarian();
      } else if (stockStorageData != null && !stockStorageData.success && stockStorageData.dateLog.isNotEmpty) {
        isSensorApiActive.value = false;

        messageResponse.value = stockStorageData.message;
        dateLogResponse.value = stockStorageData.dateLog;
      } else {
        isSensorApiActive.value = false;
        messageResponse.value = stockStorageData?.message ?? '';
      }
    } catch (e) {
      print("Gagal refresh sensor pengeluaran: $e");
      isSensorApiActive.value = false;
    } finally {
      isRefreshingSensor.value = false;
    }
  }

  void _loadUserInfo() {
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _currentUserUnitCode = auth.currentKodeUnit ?? "E000";
    } else {
      _currentUserUnitCode = "E000";
    }
  }

  void _calculateVarian() {
    double estimasi = double.tryParse(estimasiSolarC.text.replaceAll(',', '.')) ?? 0;
    String cleanAktual = aktualSolarC.text.replaceAll(',', '.');
    double aktual = double.tryParse(cleanAktual) ?? 0;
    double result = double.parse((aktual - estimasi).toStringAsFixed(2));

    String formatted = result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(2);

    varianSolarC.text = formatted;
  }

  void removePhoto(bool isSupir) {
    if (isSupir) {
      fotoSupir.value = null;
    } else {
      fotoDispenser.value = null;
    }
  }

  // --- SUBMIT LOGIC ---
  Future<void> showSubmitConfirmation() async {
    if (isSubmitting.value) return;
    if (!isManualInput.value) {
      if (fotoDispenser.value == null) {
        DialogFlexible.showInfo(
          title: "Data Belum Lengkap",
          message: "Foto Dispenser wajib dilampirkan.",
          color: AppColors.primaryOrange,
          icon: Icons.warning_amber_rounded,
        );
        return;
      }
      if (fotoSupir.value == null) {
        DialogFlexible.showInfo(
          title: "Data Belum Lengkap",
          message: "Foto Supir wajib dilampirkan.",
          color: AppColors.primaryOrange,
          icon: Icons.warning_amber_rounded,
        );
        return;
      }
    }

    final aktualVal = double.tryParse(aktualSolarC.text.replaceAll(',', '.')) ?? 0;
    if (aktualSolarC.text.trim().isEmpty || aktualVal <= 0) {
      DialogFlexible.showInfo(
        title: "Data Belum Lengkap",
        message: "Aktual Pengeluaran Solar wajib diisi lebih dari 0.",
        color: AppColors.primaryOrange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    final confirm = await DialogFlexible.showConfirm(
      logo: LottiesHelper().getLottieQuestion(),
      title: "Konfirmasi Submit",
      message: "Pastikan data solar dan foto sudah sesuai. Lanjutkan submit?",
      primaryColor: AppColors.primaryOrange,
      cancelText: "Cek Lagi",
      confirmText: "Ya, Submit",
    );

    if (confirm) {
      await Future.delayed(const Duration(milliseconds: 150));
      submitTransaction();
    }
  }

  Future<void> takePhoto(bool isSupir) async {
    try {
      isTakingPhoto.value = true;

      // Label kamera dinamis
      String labelCamera = isSupir ? "Supir" : "Angka Meter Dispenser";

      final String? resultPath = await Get.to(() => CustomCameraView(
        label: labelCamera,
      ));

      // Jika user cancel / back
      if (resultPath == null) {
        isTakingPhoto.value = false;
        return;
      }

      File originalFile = File(resultPath);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        if (isSupir) {
          fotoSupir.value = compressedFile;
        } else {
          fotoDispenser.value = compressedFile;
        }
      }
    } catch (e) {
      DialogFlexible.showInfo(
        title: "Gagal Mengambil Foto",
        message: "Kamera tidak merespons. Silakan coba lagi.",
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

  Future<void> submitTransaction() async {
    if (isSubmitting.value) return;
    if (!await ConnectivityHelper.validateNetwork()) return;

    isSubmitting.value = true;
    final closeLoading = DialogFlexible.showLoading(
      title: "Mengirim Data...",
      subtitle: "Mohon tunggu sebentar",
      color: AppColors.primaryOrange,
    );

    try {
      print("=== MULAI SUBMIT PENGELUARAN ===");
      final auth = _loginService.getCurrentAuth();
      if (auth == null) throw "Data user tidak valid.";
      if (auth.user.otorisasi.isEmpty) {
        throw "Akun Anda tidak memiliki otorisasi approval.";
      }

      String userLevel = auth.user.otorisasi.first;
      String kodeUnit = auth.currentKodeUnit ?? "";

      print("-> Step 1: getKonfigurasiApproval (transactionType: $currentDocType, kodeUnit: $kodeUnit)");
      List<KonfigurasiApprovalModel> configList = await _apiService.getKonfigurasiApproval(
        transactionType: currentDocType,
        kodeUnit: kodeUnit,
        statusActive: true,
      );

      KonfigurasiApprovalModel myConfig = configList.firstWhere(
            (config) => config.levelApproval == userLevel,
        orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval untuk tipe $currentDocType.",
      );
      print("-> Step 1 Selesai. Config ditemukan: level ${myConfig.levelApproval}");

      String finalNoDoc = noDoc.value;
      double estimasiSolar = double.tryParse(estimasiSolarC.text.replaceAll(',', '.')) ?? 0;
      double finalSolar = double.tryParse(aktualSolarC.text.replaceAll(',', '.')) ?? 0;
      double finalVarianLiter = double.tryParse(varianSolarC.text.replaceAll(',', '.')) ?? 0;
      double finalKm = double.tryParse(KmPengisian.value.replaceAll(',', '.')) ?? 0;

      print("-> Step 2: createTransactionApproval (noDoc: $finalNoDoc)");
      await _apiService.createTransactionApproval(
          noDoc: finalNoDoc,
          kodeUnit: _currentUserUnitCode,
          transactionType: currentDocType // FOT or BPB
      );
      print("-> Step 2 Selesai");

      await Future.delayed(const Duration(milliseconds: 500));

      print("-> Step 3: updateStatusTransactionApproval (isBpb: ${selectedJenisPengeluaran.value == 'BPB'})");
      if (selectedJenisPengeluaran.value == 'BPB') {
        await _apiService.updateStatusTransactionApprovalBpb(
          noDoc: finalNoDoc,
          levelApproval: myConfig.levelApproval ?? "1",
          statusApprove: 'APPROVED',
          catatan: "Verifikasi Langsung Tanpa TTD (BPB)",
          isSign: false,
          isPartnerSign: false,
        );
      } else {
        await _apiService.updateStatusTransactionApproval(
          noDoc: finalNoDoc,
          levelApproval: myConfig.levelApproval ?? "1",
          statusApprove: 'APPROVED',
          catatan: "Verifikasi Langsung Tanpa TTD ($currentDocType)",
          isSign: false,
          isPartnerSign: false,
        );
      }
      print("-> Step 3 Selesai");

      await Future.delayed(const Duration(milliseconds: 200));

      // 4. Upload Images
      print("-> Step 4: uploadImagePengeluaran (isManualInput: ${isManualInput.value})");
      if (!isManualInput.value) {
        await _apiService.uploadImagePengeluaran(
          noDoc: finalNoDoc,
          foto2: fotoDispenser.value!,  // foto dispenser/angka meter
          foto3: fotoSupir.value!,      // foto supir
        );
      }
      print("-> Step 4 Selesai");

      // 5. Update Aktual Liter
      print("-> Step 5: updateAktualLiterPengeluaran");
      if (selectedJenisPengeluaran.value == 'BPB') {
        await _apiService.updateAktualLiterPengeluaranBPB(
            noDoc: finalNoDoc,
            aktual: finalSolar,
            varianLiter: finalVarianLiter
        );
      } else {
        await _apiService.updateAktualLiterPengeluaran(
            noDoc: finalNoDoc,
            aktual: finalSolar,
            varianLiter: finalVarianLiter
        );
      }
      print("-> Step 5 Selesai");

      print("-> Step 6: updateUnitAfterTransaction (statusSupir: ${statusSupir.value})");
      if (statusSupir.value == 'Internal') {
        String currentUnit = _homeController.selectedUnitCode.value;
        String currentStorageName = _homeController.selectedStorage.value;
        String storageCode = currentStorageName.contains('-')
            ? currentStorageName.split('-').last.trim()
            : currentStorageName.trim();

        await _homeService.updateUnitAfterTransaction(
            noIO.value,
            double.tryParse(KmPengisian.value.replaceAll(',', '.')) ?? 0, // Pakai KmPengisian
            _tanggalAkhirArg,
            double.tryParse(aktualSolarC.text.replaceAll(',', '.')) ?? 0, // Pakai Aktual Liter
            _ratioArg,
            unitCodeOverride: currentUnit,
            storageCodeOverride: storageCode
        );
      }
      print("-> Step 6 Selesai");

      Map<String, dynamic> payload = {
        "no_io": noIO.value,
        "unit_io": unitIO.value,
        "nopol_check": noPolisi.value,
        "status_supir": statusSupir.value,
        "supir_check": namaSupir.value,
        "km_pengisian": finalKm,
        "jumlah_pengisian_solar": estimasiSolar,
        "aktual_liter": finalSolar,
        "varian_liter": finalVarianLiter
      };

      // try {
      //   String prettyPayload = const JsonEncoder.withIndent('  ').convert(payload);
      //   print("====== PAYLOAD SUBMIT PENGELUARAN ======\n$prettyPayload\n========================================");
      // } catch (e) {
      //   print("Payload: $payload");
      // }

      print("-> Step 7: _updateLocalStatus");
      await _updateLocalStatus(currentDocType, finalNoDoc, payload, fotoDispenser.value?.path ?? '', fotoSupir.value?.path ?? '');
      print("-> Step 7 Selesai");

      print("=== SUBMIT PENGELUARAN BERHASIL ===");
      closeLoading();
      Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieSuccess(),
          title: "Berhasil",
          message: "Data pengeluaran berhasil disubmit!",
          primaryColor: AppColors.primaryOrange,
          secondaryColor: AppColors.secondaryOrange,
          primaryButtonText: "Kembali ke Beranda",
          onPrimaryPressed: () {
            Get.back();
            Get.offAllNamed(Routes.HOME);
          },
        ),
        barrierDismissible: false,
      );

    } catch (e, stackTrace) {
      closeLoading();
      print("Error Submit Pengeluaran: $e");
      print("Stack Trace: $stackTrace");
      DialogFlexible.showInfo(
        title: "Gagal Submit",
        message: NetworkErrorHelper.getFriendlyErrorMessage(e),
        color: AppColors.alertSoftRed,
        icon: Icons.error_outline_rounded,
      );
    } finally {
      isSubmitting.value = false;
      closeLoading();
    }
  }

  Future<void> _updateLocalStatus(String docTypeValue, String noDoc, Map<String, dynamic> payload, String pDispenser, String pSupir) async {
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      final outstandingService = OutstandingService(auth.user.username);
      final pengeluaranDetail = PengeluaranModel(
        docType: docTypeValue,
        noDoc: noDoc,
        noIo: payload['no_io'],
        unitIO: payload['unit_io'],
        nopolCheck: payload['nopol_check'],
        statusSupir: payload['status_supir'],
        supirCheck: payload['supir_check'],
        kmPengisian: payload['km_pengisian'],
        liter: payload['jumlah_pengisian_solar'],
        varian: payload['varian_liter'],
        jumlahPengisianSolar: payload['aktual_liter'],
        userName: auth.user.username,
        dateOutbound: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        pathFoto1: pDispenser,
        pathFoto2: pSupir,
        pathFoto3: pSupir,
      );
      final trx = TransactionPengeluaranModel(
        noBast: noDoc,
        status: 'selesai',
        dateCreated: DateTime.now().toIso8601String(),
        dataPengeluaran: pengeluaranDetail,
      );
      await outstandingService.saveTransactionPengeluaran(trx);
    }
  }

  Future<void> saveAndExit() async {
    Get.back();
    Get.offAllNamed(Routes.HOME);
  }
}