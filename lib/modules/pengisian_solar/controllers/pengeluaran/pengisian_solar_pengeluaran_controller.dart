import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../../datas/models/pengeluaran/pengeluaran_model.dart';
import '../../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../../../helpers/connectivity_helper.dart';
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
    unitIO.value = args['unitIO'] ?? '-';
    tanggal.value = args['tanggal'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
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
    _ratioArg = (payload['ratio'] ?? '0').toString();
    _hmKmAkhirArg = (payload['hm_km_akhir'] ?? '0').toString();
    _tanggalAkhirArg = (payload['tanggal_akhir'] ?? '').toString();

    String initialDocType = payload['doc_type'] ?? 'FOT';
    selectedJenisPengeluaran.value = (initialDocType == 'BPB') ? 'BPB' : 'Bon Sementara';

    // Ambil storage code aktif dari Home Controller
    String rawStorage = _homeController.selectedStorage.value;
    activeStorageCode = rawStorage.contains('-') ? rawStorage.split('-').last.trim() : rawStorage.trim();

    estimasiSolarC.text = jumlahSolarArg.value;
    aktualSolarC.text = "";

    refreshSensorMonitoring();
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

      if (stockStorageData!.success && stockStorageData.errorCode.isEmpty) {
        double flowOut = stockStorageData.volume;

        isSensorApiActive.value = true;
        messageResponse.value = stockStorageData.message;
        dateLogResponse.value = stockStorageData.dateLog;

        aktualSolarC.text = flowOut % 1 == 0
            ? flowOut.toInt().toString()
            : flowOut.toStringAsFixed(2).replaceAll('.', ',');

        _calculateVarian();
      } else if (!stockStorageData.success && stockStorageData.dateLog.isNotEmpty) {
        isSensorApiActive.value = false;

        messageResponse.value = stockStorageData.message;
        dateLogResponse.value = stockStorageData.dateLog;
      } else {
        isSensorApiActive.value = false;
        messageResponse.value = stockStorageData.message;
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
      _currentUserUnitCode = auth.currentKodeUnit!;
    } else {
      _currentUserUnitCode = "E000";
    }
  }

  void _calculateVarian() {
    double estimasi = double.tryParse(estimasiSolarC.text.replaceAll(',', '.')) ?? 0;
    String cleanAktual = aktualSolarC.text.replaceAll(',', '.');
    double aktual = double.tryParse(cleanAktual) ?? 0;
    double result = aktual - estimasi;

    String formatted = result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(2).replaceAll('.', ',');

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
  void showSubmitConfirmation() {
    if (fotoDispenser.value == null || fotoSupir.value == null) {
      Get.snackbar(
        "Foto Belum Lengkap",
        "Harap ambil Foto Dispenser dan Foto Supir terlebih dahulu.",
        backgroundColor: AppColors.alertSoftRed,
        colorText: AppColors.white,
      );
      return;
    }

    if (aktualSolarC.text.isEmpty || double.tryParse(aktualSolarC.text.replaceAll(',', '.')) == 0) {
      Get.snackbar(
        "Data Belum Lengkap",
        "Harap isi Aktual Pengeluaran Solar.",
        backgroundColor: AppColors.alertSoftRed,
        colorText: AppColors.white,
      );
      return;
    }

    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieQuestion(),
        title: "Konfirmasi Submit",
        message: "Pastikan data solar dan foto sudah sesuai. Lanjutkan submit?",
        primaryColor: AppColors.primaryOrange,
        secondaryColor: AppColors.secondaryOrange,
        secondaryButtonText: "Cek Lagi",
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: "Ya, Submit",
        onPrimaryPressed: () {
          Get.back();
          submitTransaction();
        },
      ),
      barrierDismissible: false,
    );
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
      Get.snackbar("Error", "Gagal mengambil gambar: $e");
    } finally {
      isTakingPhoto.value = false;
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final lastIndex = file.path.lastIndexOf(RegExp(r'.jp'));
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

  Future<void> submitTransaction() async {
    if (!await ConnectivityHelper.validateNetwork()) return;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryOrange),
              const SizedBox(height: 24),
              Text("Mengirim Data...", style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.black), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final auth = _loginService.getCurrentAuth();
      if (auth == null) throw "Data user tidak valid.";

      String userLevel = auth.user.otorisasi.first;
      String kodeUnit = auth.currentKodeUnit ?? "";

      List<KonfigurasiApprovalModel> configList = await _apiService.getKonfigurasiApproval(
        transactionType: currentDocType,
        kodeUnit: kodeUnit,
        statusActive: true,
      );

      KonfigurasiApprovalModel myConfig = configList.firstWhere(
            (config) => config.levelApproval == userLevel,
        orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval untuk tipe $currentDocType.",
      );

      String finalNoDoc = noDoc.value;
      double estimasiSolar = double.tryParse(estimasiSolarC.text.replaceAll(',', '.')) ?? 0;
      double finalSolar = double.tryParse(aktualSolarC.text.replaceAll(',', '.')) ?? 0;
      double finalVarianLiter = double.tryParse(varianSolarC.text.replaceAll(',', '.')) ?? 0;
      double finalKm = double.tryParse(KmPengisian.value.replaceAll(',', '.')) ?? 0;

      await _apiService.createTransactionApproval(
          noDoc: finalNoDoc,
          kodeUnit: _currentUserUnitCode,
          transactionType: currentDocType // FOT or BPB
      );

      await Future.delayed(const Duration(milliseconds: 500));

      await _apiService.updateStatusTransactionApproval(
        noDoc: finalNoDoc,
        levelApproval: myConfig.levelApproval ?? "1",
        statusApprove: 'APPROVED',
        catatan: "Verifikasi Langsung Tanpa TTD ($currentDocType)",
        isSign: false,
        isPartnerSign: false,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      // 4. Upload Images
      await _apiService.uploadImagePengeluaran(
        noDoc: finalNoDoc,
        foto2: fotoDispenser.value!,  // foto dispenser/angka meter
        foto3: fotoSupir.value!,      // foto supir
      );

      // 5. Update Aktual Liter
      await _apiService.updateAktualLiterPengeluaran(
          noDoc: finalNoDoc,
          aktual: finalSolar,
          varianLiter: finalVarianLiter
      );

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

      await _updateLocalStatus(currentDocType, finalNoDoc, payload, fotoDispenser.value!.path, fotoSupir.value!.path);

      if (Get.isDialogOpen ?? false) Get.back();

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

    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("Error Submit: $e");
      Get.snackbar("Gagal", "Terjadi kesalahan: ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
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
    Get.offAllNamed(Routes.HOME);
  }
}