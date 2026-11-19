import 'dart:io';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

import '../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../datas/models/pengeluaran/pengeluaran_model.dart';
import '../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/component/custom_camera_view.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../helpers/network_error_helper.dart';
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

  var photoDispenser = Rxn<CapturedImageDetail>();
  File? hiddenPhotoSupir;
  File? hiddenPhotoTruk;

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
  final tipeUnit = '-'.obs;
  final satuan = '-'.obs;
  final hmKmAwal = '-'.obs;
  final hmKmAkhir = '-'.obs;
  final varian = '-'.obs;
  final ratio = '-'.obs;
  final keterangan = '-'.obs;
  final docType = '-'.obs;
  final jenisPengeluaran = 'Bon Sementara'.obs;
  final aktualSolarC = TextEditingController();
  final statusSupir = 'Internal'.obs;

  // User Info (Internal)
  final userName = '-'.obs;
  final userJabatan = '-'.obs;
  late String _currentUserUnitCode;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _loadUserInfo();

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
    aktualSolarC.dispose();
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

    tipeUnit.value = (args['tipe_unit'] ?? '-').toString();
    satuan.value = args['satuan'] ?? '-';
    hmKmAwal.value = (args['hm_km_awal'] ?? '-').toString();
    hmKmAkhir.value = (args['hm_km_akhir'] ?? '-').toString();
    varian.value = (args['varian'] ?? '-').toString();
    ratio.value = (args['ratio'] ?? '-').toString();
    keterangan.value = args['keterangan'] ?? '-';
    docType.value = args['doc_type'] ?? 'FOT';
    String initialJenis = args['jenis_pengeluaran'] ?? (args['payload'] != null ? args['payload']['jenis_pengeluaran'] : null) ?? (docType.value == 'BPB' ? 'BPB' : 'Bon Sementara');
    jenisPengeluaran.value = (initialJenis == 'BPB') ? 'BPB' : 'Bon Sementara';

    statusSupir.value = args['status_supir'] ?? 'Internal';
    aktualSolarC.text = jumlahSolar.value;

    if (args['foto_supir'] != null) {
      File f = File(args['foto_supir']);
      if (f.existsSync()) hiddenPhotoSupir = f;
    }
    if (args['foto_truk'] != null) {
      File f = File(args['foto_truk']);
      if (f.existsSync()) hiddenPhotoTruk = f;
    }
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
      if (photoDispenser.value == null) {
        DialogFlexible.showInfo(
          title: "Foto Belum Lengkap",
          message: "Foto Dispenser Pom wajib dilampirkan.",
          color: AppColors.primaryOrange,
          icon: Icons.warning_amber_rounded,
        );
        return;
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

      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (currentPage.value == 1) {
      if (warehouseSignatureController.isEmpty) {
        DialogFlexible.showInfo(
          title: "Tanda Tangan Kosong",
          message: "Tanda tangan bagian gudang wajib diisi.",
          color: AppColors.primaryOrange,
          icon: Icons.warning_amber_rounded,
        );
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

  Future<void> takeDispenserPhoto() async {
    try {
      isTakingPhoto.value = true;

      // Navigasi ke Custom Camera
      final String? resultPath = await Get.to(() => const CustomCameraView(
        label: "Foto Dispenser (Jumlah Liter)",
      ));

      // Jika user menekan back
      if (resultPath == null) {
        isTakingPhoto.value = false;
        return;
      }

      File originalFile = File(resultPath);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile == null) return;

      final String tempPath = compressedFile.path;
      final String tempFileName = p.basename(tempPath);

      photoDispenser.value = CapturedImageDetail(
        tempPath: tempPath,
        latitude: 0,
        longitude: 0,
        fileName: tempFileName,
      );
    } catch (e) {
      if (kDebugMode) print('Error saat takePhoto: $e');
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

  void removeDispenserImage() {
    if (photoDispenser.value != null) {
      try {
        File(photoDispenser.value!.tempPath).deleteSync();
      } catch (e) {}
      photoDispenser.value = null;
    }
  }

  // --- SUBMIT FUNCTIONS ---
  void _confirmAndSubmit() {
    if (driverSignatureController.isEmpty) {
      DialogFlexible.showInfo(
        title: "Tanda Tangan Kosong",
        message: "Tanda tangan supir wajib diisi.",
        color: AppColors.primaryOrange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

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
    final closeLoading = DialogFlexible.showLoading(
      title: "Memproses Verifikasi...",
      subtitle: "Mohon tunggu sebentar",
      color: AppColors.primaryOrange,
    );

    try {
      File? f1 = photoDispenser.value != null ? File(photoDispenser.value!.tempPath) : null;
      File? f2 = hiddenPhotoTruk;
      File? f3 = hiddenPhotoSupir;

      if (f1 == null || f2 == null || f3 == null) {
        throw "Data foto tidak lengkap. Harap lengkapi foto terlebih dahulu.";
      }

      final File? whSignFile = await _exportSignatureToFile(warehouseSignatureController, "sign_gudang");
      final File? driverSignFile = await _exportSignatureToFile(driverSignatureController, "sign_supir");

      if (whSignFile == null || driverSignFile == null) {
        throw "Gagal memproses gambar tanda tangan.";
      }

      final auth = _loginService.getCurrentAuth();
      if (auth == null) throw "Data user tidak valid.";

      String userLevel = auth.user.otorisasi.first;

      List<KonfigurasiApprovalModel> configList = await _apiService.getKonfigurasiApproval(
        transactionType: 'FOT',
        kodeUnit: auth.currentKodeUnit ?? "",
        statusActive: true,
      );

      KonfigurasiApprovalModel myConfig = configList.firstWhere(
            (config) => config.levelApproval == userLevel,
        orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval.",
      );

      String finalNoDoc = noDoc.value;
      double finalSolar = double.tryParse(aktualSolarC.text.replaceAll(',', '.')) ?? 0;

      Map<String, dynamic> payload = {
        "no_io": noIO.value,
        "unit_io": unitIO.value,
        "nopol_check": noPolisi.value,
        "status_supir": statusSupir.value,
        "supir_check": namaSupir.value,
        "km_pengisian": double.tryParse(kmPengisian.value.replaceAll(',', '')) ?? 0,
        "jumlah_pengisian_solar": finalSolar,
      };

      await _apiService.createTransactionApproval(
          noDoc: finalNoDoc,
          kodeUnit: _currentUserUnitCode,
          transactionType: docType.value
      );

      await Future.delayed(const Duration(seconds: 1));

      if (jenisPengeluaran.value == 'BPB') {
        await _apiService.updateStatusTransactionApprovalBpb(
          noDoc: finalNoDoc,
          levelApproval: myConfig.levelApproval ?? "1",
          statusApprove: 'APPROVED',
          catatan: warehouseNoteController.text.isEmpty
              ? "Verifikasi Dokumen Selesai"
              : warehouseNoteController.text,
          isSign: true,
          isPartnerSign: true,
        );
      } else {
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
      }

      await _apiService.uploadSignatureTransactionApproval(
        noDoc: finalNoDoc,
        levelApproval: myConfig.levelApproval ?? "1",
        imageSign1: whSignFile,
        imageSign2: driverSignFile,
      );

      await Future.delayed(const Duration(seconds: 1));

      await _apiService.uploadImagePengeluaran(
        noDoc: finalNoDoc,
        foto1: f1,
        foto2: f2,
        foto3: f3,
      );

      await _updateLocalStatus(finalNoDoc, payload, f1.path, f2.path, f3.path);

      // Tutup loading dialog
      closeLoading();

      Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieSuccess(),
          title: "Verifikasi Berhasil",
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
      closeLoading();
      print("Error: $e");
      DialogFlexible.showInfo(
        title: "Gagal Verifikasi",
        message: NetworkErrorHelper.getFriendlyErrorMessage(e),
        color: AppColors.alertSoftRed,
        icon: Icons.error_outline_rounded,
      );
    } finally {
      closeLoading();
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
      return null;
    }
  }

  Future<void> _updateLocalStatus(String noDoc, Map<String, dynamic> payload, String p1, String p2, String p3) async {
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      final outstandingService = OutstandingService(auth.user.username);
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
        pathFoto1: p1,
        pathFoto2: p2,
        pathFoto3: p3,
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