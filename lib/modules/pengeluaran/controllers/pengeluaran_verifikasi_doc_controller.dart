import 'dart:io';
import 'dart:typed_data';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';

import '../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../../helpers/lotties_helper.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/outstanding_service.dart';
import '../../transactions/pengeluaran/services/pengeluaran_api_service.dart';

class PengeluaranVerifikasiDocController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final PengeluaranApiService _apiService = PengeluaranApiService();

  // Page Controller
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  // Signature Controllers
  late SignatureController warehouseSignatureController;
  late SignatureController driverSignatureController;
  final warehouseNoteController = TextEditingController();

  // Data from Arguments
  final noDoc = '-'.obs;
  final noIO = '-'.obs;
  final unitIO = '-'.obs;
  final noPolisi = '-'.obs;
  final namaSupir = '-'.obs;
  final kmPengisian = '-'.obs;
  final jumlahSolar = '-'.obs;
  final tanggal = '-'.obs;

  // User Info (Internal)
  final userName = '-'.obs;
  final userJabatan = '-'.obs;
  late String _currentUserUnitCode;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _loadUserInfo();

    // Init Signature
    warehouseSignatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    driverSignatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void onClose() {
    warehouseSignatureController.dispose();
    driverSignatureController.dispose();
    warehouseNoteController.dispose();
    pageController.dispose();
    super.onClose();
  }

  void _loadArguments() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    noDoc.value = args['noDoc'] ?? '-';
    noIO.value = args['noIO'] ?? '-';
    unitIO.value = args['unitIO'] ?? '-';
    noPolisi.value = args['noPolisi'] ?? '-';
    namaSupir.value = args['nama_supir'] ?? '-';
    kmPengisian.value = (args['km_pengisian'] ?? '-').toString();
    jumlahSolar.value = (args['jumlah_pengisian_solar'] ?? '-').toString();
    tanggal.value = args['tanggal'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  void _loadUserInfo() {
    final auth = _loginService.getCurrentAuth();
    if(auth != null) {
      userName.value = "${auth.user.firstName} ${auth.user.lastName}";
      userJabatan.value = auth.user.userKaryawan.jabatan.namaJabatan ?? "Staff Gudang";
      _currentUserUnitCode = auth.user.userKaryawan.unit.kodeUnit;
    } else {
      _currentUserUnitCode = "E000";
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      if (currentPage.value == 1 && warehouseSignatureController.isEmpty) {
        Get.snackbar("Informasi", "Tanda tangan bagian gudang wajib diisi",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _confirmAndSubmit();
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  void clearSignature(SignatureController controller) {
    controller.clear();
  }

  void _confirmAndSubmit() {
    if (driverSignatureController.isEmpty) {
      Get.snackbar("Peringatan", "Tanda tangan supir wajib diisi",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieQuestion(),
          title: "Konfirmasi Submit",
          message: "Pastikan semua tanda tangan dan data sudah sesuai. Lanjutkan proses?",

          primaryColor: AppColors.primaryOrange,
          secondaryColor: AppColors.secondaryOrange,

          secondaryButtonText: "Cek Lagi",
          onSecondaryPressed: () => Get.back(),
          primaryButtonText: "Ya, Submit",
          onPrimaryPressed: () {
            Get.back();
            submitVerification();
          },
        ),
        barrierDismissible: false
    );
  }

  Future<void> submitVerification() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final File? whSignFile = await _exportSignatureToFile(warehouseSignatureController, "sign_gudang");
      final File? driverSignFile = await _exportSignatureToFile(driverSignatureController, "sign_supir");

      if (whSignFile == null || driverSignFile == null) {
        throw Exception("Gagal memproses gambar tanda tangan.");
      }

      final auth = _loginService.getCurrentAuth();
      if (auth == null) throw "Data user atau transaksi tidak valid.";

      String userLevel = auth.user.otorisasi.first;
      String kodeUnit = auth.user.userKaryawan.unit.kodeUnit ?? "";

      /// =======================================================================
      // STEP 1: HIT API - CEK KONFIGURASI APPROVAL
      // =======================================================================
      List<KonfigurasiApprovalModel> configList = await _apiService.getKonfigurasiApproval(
        transactionType: 'FOT', kodeUnit: kodeUnit, statusActive: true,
      );

      KonfigurasiApprovalModel myConfig = configList.firstWhere(
            (config) => config.levelApproval == userLevel,
        orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval.",
      );

      print("✅ Step 1: Validasi Approval Berhasil (ID: ${myConfig.id})");
      print("✅ Step 1: Validasi Approval Berhasil: Step ${myConfig.stepApproval}");

      // 3. STEP 1: Create Transaction Approval
      // Transaction Type = FOT (Fuel Outbound Transaction)
      await _apiService.createTransactionApproval(
          noDoc: noDoc.value,
          kodeUnit: _currentUserUnitCode, // Menggunakan Unit Code User Login (Misal: E021)
          transactionType: 'FOT'
      );

      print("⏳ Menunggu server commit data...");
      await Future.delayed(const Duration(seconds: 2));

      // 4. STEP 2: Update Status Transaction Approval (Approve Gudang)
      await _apiService.updateStatusTransactionApproval(
        noDoc: noDoc.value,
        levelApproval: myConfig.levelApproval ?? "1",
        statusApprove: 'APPROVED',
        catatan: warehouseNoteController.text.isEmpty
            ? "Verifikasi Dokumen Selesai"
            : warehouseNoteController.text,
        isSign: true,
        isPartnerSign: true,
      );

      // 5. STEP 3: Upload Signature Images
      await _apiService.uploadSignatureTransactionApproval(
        noDoc: noDoc.value,
        levelApproval: myConfig.levelApproval ?? "1",
        imageSign1: whSignFile,
        imageSign2: driverSignFile,
      );

      // 6. Update Status Lokal Hive (OutstandingService)
      await _updateLocalStatus();

      // Tutup Loading
      if(Get.isDialogOpen ?? false) Get.back();

      // 7. Dialog Sukses & Redirect
      Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieSuccess(),
          title: "Verifikasi Berhasil",
          message: "Dokumen berhasil disetujui dan diteruskan ke Kasie untuk approval selanjutnya.",

          primaryColor: AppColors.primaryOrange,
          secondaryColor: AppColors.secondaryOrange,
          
          primaryButtonText: "Selesai",
          onPrimaryPressed: () {
            Get.back(); // Close Dialog
            Get.offAllNamed(Routes.HOME);
          },
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      if(Get.isDialogOpen ?? false) Get.back(); // Close Loading

      print("Error Submit Verification: $e");
      Get.snackbar(
          "Gagal Verifikasi",
          "Terjadi kesalahan: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4)
      );
    }
  }

  Future<File?> _exportSignatureToFile(SignatureController controller, String fileName) async {
    try {
      if (controller.isEmpty) return null;
      final Uint8List? data = await controller.toPngBytes();

      if (data == null) return null;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName.png');
      await file.writeAsBytes(data);

      return file;
    } catch (e) {
      print("Error converting signature: $e");
      return null;
    }
  }

  Future<void> _updateLocalStatus() async {
    final auth = _loginService.getCurrentAuth();
    if(auth != null) {
      final outstandingService = OutstandingService(auth.user.username);

      // Update status menjadi 'approval_kasie'
      await outstandingService.updateStatusPengeluaran(
          noDoc.value,
          'approval_kasie'
      );
    }
  }
}