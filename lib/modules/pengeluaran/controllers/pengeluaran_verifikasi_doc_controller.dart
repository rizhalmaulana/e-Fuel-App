import 'dart:io';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../configs/app_fonts.dart';
import '../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../datas/models/pengeluaran/pengeluaran_model.dart';
import '../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
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
  var isTakingPhoto = false.obs;

  // Photo State
  final RxList<CapturedImageDetail?> photoSlots =
      RxList<CapturedImageDetail?>([null, null, null]);
  final ImagePicker _picker = ImagePicker();

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
    if (auth != null) {
      userName.value = "${auth.user.firstName} ${auth.user.lastName}";
      userJabatan.value = auth.user.jabatan?.namaJabatan ?? "Staff Gudang";
      _currentUserUnitCode = auth.currentKodeUnit!;
    } else {
      _currentUserUnitCode = "E000";
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value == 0) {
      // Validasi foto di step 1
      if (photoSlots.any((element) => element == null)) {
        Get.snackbar("Foto Belum Lengkap",
            "Harap lengkapi 3 foto bukti (Bon, Depan, Samping)!",
            backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
        return;
      }

      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (currentPage.value == 1) {
      // Validasi tanda tangan gudang di step 2
      if (warehouseSignatureController.isEmpty) {
        Get.snackbar("Informasi", "Tanda tangan bagian gudang wajib diisi",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
// Step 3: Konfirmasi submit akhir
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

  // --- PHOTO FUNCTIONS ---
  Future<void> takeSpecificPhoto(int index) async {
    try {
      isTakingPhoto.value = true;
      double currentLat = 0;
      double currentLong = 0;

      final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1080.0,
        maxHeight: 1920.0,
        imageQuality: 80,
      );

      if (imageFile == null) return;

      File originalFile = File(imageFile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile == null) return;

      final String tempPath = compressedFile.path;
      final String tempFileName = p.basename(tempPath);

      photoSlots[index] = CapturedImageDetail(
        tempPath: tempPath,
        latitude: currentLat,
        longitude: currentLong,
        fileName: tempFileName,
      );
    } catch (e) {
      if (kDebugMode) print('Error saat takePhoto: $e');
      Get.snackbar("Gagal", "Terjadi error: $e");
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

  void removeImage(int index) {
    if (index >= 0 && index < photoSlots.length && photoSlots[index] != null) {
      try {
        File(photoSlots[index]!.tempPath).deleteSync();
      } catch (e) {}
      photoSlots[index] = null;
    }
  }

  // --- SUBMIT FUNCTIONS ---
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
          message:
              "Pastikan semua tanda tangan dan foto sudah sesuai. Lanjutkan proses?",
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
        barrierDismissible: false);
  }

  Future<void> submitVerification() async {
    if (driverSignatureController.isEmpty) {
      Get.snackbar("Peringatan", "Tanda tangan supir wajib diisi",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

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
              Text(
                "Memproses Verifikasi...",
                style:
                    AppFonts.fUrbanistBold16.copyWith(color: AppColors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Mengunggah tanda tangan & foto bukti",
                style: AppFonts.fUrbanistRegular12
                    .copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      List<File?> photos =
      photoSlots.map((e) => e != null ? File(e.tempPath) : null).toList();

      final File? whSignFile = await _exportSignatureToFile(
          warehouseSignatureController, "sign_gudang");
      final File? driverSignFile =
      await _exportSignatureToFile(driverSignatureController, "sign_supir");

      if (whSignFile == null || driverSignFile == null) {
        throw Exception("Gagal memproses gambar tanda tangan.");
      }

      final auth = _loginService.getCurrentAuth();
      if (auth == null) throw "Data user atau transaksi tidak valid.";

      String userLevel = auth.user.otorisasi.first;
      String kodeUnit = auth.currentKodeUnit ?? "";

      List<KonfigurasiApprovalModel> configList =
      await _apiService.getKonfigurasiApproval(
        transactionType: 'FOT',
        kodeUnit: kodeUnit,
        statusActive: true,
      );

      KonfigurasiApprovalModel myConfig = configList.firstWhere(
            (config) => config.levelApproval == userLevel,
        orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval.",
      );

      String finalNoDoc = noDoc.value;

      if (finalNoDoc == '-' || finalNoDoc.isEmpty) {
        throw "Nomor Dokumen tidak valid / hilang.";
      }

      Map<String, dynamic> payload = {
        "no_io": noIO.value,
        "unit_io": unitIO.value,
        "nopol_check": noPolisi.value,
        "status_supir": "Internal",
        "supir_check": namaSupir.value,
        "km_pengisian":
        double.tryParse(kmPengisian.value.replaceAll(',', '')) ?? 0,
        "jumlah_pengisian_solar":
        double.tryParse(jumlahSolar.value.replaceAll(',', '')) ?? 0,
      };

      await _apiService.createTransactionApproval(
          noDoc: finalNoDoc,
          kodeUnit: _currentUserUnitCode,
          transactionType: 'FOT');

      print("⏳ Menunggu server commit data...");
      await Future.delayed(const Duration(seconds: 2));

      await _apiService.updateStatusTransactionApproval(
        noDoc: finalNoDoc,
        levelApproval: myConfig.levelApproval ?? "1",
        statusApprove: 'APPROVED',
        catatan: warehouseNoteController.text.isEmpty
            ? "Verifikasi Dokumen Selesai"
            : warehouseNoteController.text,
        isSign: true,
        isPartnerSign: true,
      );

      await _apiService.uploadSignatureTransactionApproval(
        noDoc: finalNoDoc,
        levelApproval: myConfig.levelApproval ?? "1",
        imageSign1: whSignFile,
        imageSign2: driverSignFile,
      );

      print("⏳ Menunggu upload tanda tangan...");
      await Future.delayed(const Duration(seconds: 2));

      if (photos[0] != null && photos[1] != null && photos[2] != null) {
        await _apiService.uploadImagePengeluaran(
          noDoc: finalNoDoc,
          foto1: photos[0]!,
          foto2: photos[1]!,
          foto3: photos[2]!,
        );
      } else {
        throw "File foto tidak lengkap ketika di Upload.";
      }

      await _updateLocalStatus(finalNoDoc, payload);

      if (Get.isDialogOpen ?? false) Get.back();

      Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieSuccess(),
          title: "Verifikasi Berhasil",
          message: "Dokumen berhasil disetujui oleh Kerani.",
          primaryColor: AppColors.primaryOrange,
          secondaryColor: AppColors.secondaryOrange,
          primaryButtonText: "Lihat Status",
          onPrimaryPressed: () {
            Get.back();
            Get.offAllNamed(Routes.PENGELUARAN_TRACKING,
                arguments: {'noBast': finalNoDoc});
          },
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // Close Loading

      print("Error Submit Verification: $e");
      Get.snackbar("Gagal Verifikasi", "Terjadi kesalahan: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4));
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

  Future<void> _updateLocalStatus(String noDoc, Map<String, dynamic> payload) async {
    final auth = _loginService.getCurrentAuth();

    if (auth != null) {
      final outstandingService = OutstandingService(auth.user.username);

      // Create pengeluaran model
      final pengeluaranDetail = PengeluaranModel(
        noDoc: noDoc,
        noIo: payload['no_io'],
        nopolCheck: payload['nopol_check'],
        statusSupir: payload['status_supir'],
        supirCheck: payload['supir_check'],
        kmPengisian: payload['km_pengisian'],
        jumlahPengisianSolar: payload['jumlah_pengisian_solar'],
        unitIO: payload['unit_io'],
        userName: auth.user.username,
        dateOutbound: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        pathFoto1: photoSlots[0]?.tempPath,
        pathFoto2: photoSlots[1]?.tempPath,
        pathFoto3: photoSlots[2]?.tempPath,
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
}
