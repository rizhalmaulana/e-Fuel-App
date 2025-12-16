import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/datas/models/karyawan/karyawan_dbk/karyawan_dbk_list_dto.dart';
import 'package:e_fuel/datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../datas/models/master_io/master_io_model.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/pengeluaran/pengeluaran_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/outstanding_service.dart';
import '../../transactions/pengeluaran/services/pengeluaran_api_service.dart';
import '../services/draft_pengeluaran_service.dart';

class PengeluaranController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final PengeluaranApiService _apiService = PengeluaranApiService();
  late DraftPengeluaranService _draftService;

  // --- Page & UI State ---
  final PageController pageController = PageController();
  var currentPage = 0.obs;
  var isTakingPhoto = false.obs;

  // --- Form Controllers (Step 1) ---
  final kmPengisianC = TextEditingController();
  final pengisianSolarC = TextEditingController();
  final ioController = TextEditingController();
  final platController = TextEditingController();
  final driverNameManualController = TextEditingController();

  // --- Photo State (Step 2) ---
  final RxList<CapturedImageDetail?> photoSlots = RxList<CapturedImageDetail?>([null, null, null]);
  final ImagePicker _picker = ImagePicker();

  // --- Data Logic ---
  var isLoadingUnit = false.obs;
  var filteredUnitList = <MasterIoModel>[].obs;
  var isPlatReadOnly = true.obs;
  List<MasterIoModel> _allUnitList = [];

  var selectedUnit = Rxn<MasterIoModel>();

  // var selectedDriver = Rxn<String>();
  var selectedDriver = Rxn<KaryawanDbkListDto>();
  final manualNipC = TextEditingController();
  final manualNamaC = TextEditingController();
  final manualJabatanC = TextEditingController();
  final manualUnitC = TextEditingController();

  var selectedStatusSupir = Rxn<String>();

  final List<String> statusSupirList = ['Internal', 'Eksternal'];

  var driverList = <KaryawanDbkListDto>[].obs;
  var isLoadingDriver = false.obs;
  Timer? _debounce; // Timer untuk menunda request API
  late String _kodeUnit;

  @override
  void onInit() {
    super.onInit();

    // Init Draft Service
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _kodeUnit = auth.user.userKaryawan.unit.kodeUnit ?? "Null";
      _draftService = DraftPengeluaranService(auth.user.username);
      _checkAndRestoreDraft(); // Cek draft saat init
    }
    fetchUnitList();
  }

  @override
  void onClose() {
    kmPengisianC.dispose();
    pengisianSolarC.dispose();
    ioController.dispose();
    platController.dispose();
    driverNameManualController.dispose();

    manualNipC.dispose();
    manualNamaC.dispose();
    manualJabatanC.dispose();
    manualUnitC.dispose();

    pageController.dispose();
    super.onClose();
  }

  // --- FETCHING DATA UNIT DAN SUPIR ---
  void fetchUnitList() async {
    try {
      isLoadingUnit.value = true;
      var data = await _apiService.getMasterIoList();
      _allUnitList = data;
      filteredUnitList.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data unit: $e');
    } finally {
      isLoadingUnit.value = false;
    }
  }

  void searchUnit(String keyword) {
    if (keyword.isEmpty) {
      filteredUnitList.assignAll(_allUnitList);
    } else {
      var result = _allUnitList.where((unit) {
        var shortName = (unit.namaUnit ?? '').toLowerCase();
        var longName = (unit.description ?? '').toLowerCase();
        var io = (unit.internalOrder ?? '').toLowerCase();
        var plat = (unit.noPolisi ?? '').toLowerCase();
        var input = keyword.toLowerCase();
        return shortName.contains(input) ||
            longName.contains(input) ||
            io.contains(input) ||
            plat.contains(input);
      }).toList();
      filteredUnitList.assignAll(result);
    }
  }

  void onUnitSelected(MasterIoModel unit) {
    selectedUnit.value = unit;
    ioController.text = unit.internalOrder ?? '-';
    if (unit.noPolisi != null && unit.noPolisi!.isNotEmpty && unit.noPolisi != '-') {
      platController.text = unit.noPolisi!;
      isPlatReadOnly.value = true;
    } else {
      platController.text = '';
      isPlatReadOnly.value = false;
    }
    searchUnit('');
  }

  void onStatusSupirChanged(String? val) {
    selectedStatusSupir.value = val;
    if (val == 'Internal') {
      driverNameManualController.clear();
    } else {
      selectedDriver.value = null;
    }
  }

  void searchDriverApi(String keyword, String unit) async {
    try {
      isLoadingDriver.value = true;

      var response = await _apiService.getEmployees(
        page: 1,
        pageSize: 25,
        search: keyword,
        kodeUnit: _kodeUnit
      );

      if (response.data != null) {
        driverList.assignAll(response.data!);
      }

    } catch (e) {
      print("Error: $e");
    } finally {
      isLoadingDriver.value = false;
    }
  }

  void onSearchDriverChanged(String val) {
    if (val.isEmpty) {
      driverList.clear();
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchDriverApi(val, _kodeUnit);
    });
  }

  void pickDriverFromApi(KaryawanDbkListDto data) {
    selectedDriver.value = data;
    // Reset manual input controllers
    manualNipC.clear();
    manualNamaC.clear();
    manualJabatanC.clear();
  }

  void setManualInternalDriver() {
    String nip = manualNipC.text.trim();
    String nama = manualNamaC.text.trim();
    String unit = manualUnitC.text.trim();
    String jabatan = manualJabatanC.text.trim();

    if (nip.isEmpty || nama.isEmpty || unit.isEmpty) {
      Get.snackbar("Validasi Gagal", "NIP, Nama, dan Kode Unit wajib diisi",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    if (nip.length < 13 || nip.length > 14) {
      Get.snackbar("Validasi NIP", "NIP harus terdiri dari 13 - 14 digit",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    if (unit.length != 4) {
      Get.snackbar("Validasi Unit", "Kode Unit harus terdiri dari 4 karakter",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    if (RegExp(r'[0-9]').hasMatch(nama)) {
      Get.snackbar("Validasi Nama", "Nama tidak boleh mengandung angka",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    final manualData = KaryawanDbkListDto(
      nama: nama,
      nip: nip,
      jabatan: jabatan.isEmpty ? "Supir" : jabatan,
      unit: unit.toUpperCase(),
      status: "Aktif",
    );

    selectedDriver.value = manualData;
    Get.back(); // Tutup Dialog
    if (Get.isBottomSheetOpen ?? false) Get.back();
  }

  // --- RESTORE DATA ---
  Future<void> _checkAndRestoreDraft() async {
    var draft = await _draftService.getDraft();
    if (draft != null) {
      // Implementasi restore data ke form jika diperlukan
      // Contoh: ioController.text = draft['no_io'];
      // Plat, Supir, KM, dll...
    }
  }

  // --- NAVIGASI PAGE ---
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextStep() {
    if (currentPage.value == 0) {
      if (_validateStepOne()) {
        _saveDraft();
        pageController.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      }
    } else if (currentPage.value == 1) {
      // Step 2: Konfirmasi Submit
      confirmSubmit();
    }
  }

  void previousStep() {
    if (currentPage.value > 0) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      if (Get.context != null) {
        Navigator.pop(Get.context!);
      }
    }
  }

  // --- VALIDASI ---
  bool _validateStepOne() {
    bool isDriverValid = false;
    if (selectedStatusSupir.value == 'Internal') {
      isDriverValid = selectedDriver.value != null;
    } else if (selectedStatusSupir.value == 'Eksternal') {
      isDriverValid = driverNameManualController.text.isNotEmpty;
    }

    if (selectedUnit.value == null ||
        selectedStatusSupir.value == null ||
        !isDriverValid ||
        kmPengisianC.text.isEmpty ||
        pengisianSolarC.text.isEmpty ||
        platController.text.isEmpty) {
      Get.snackbar('Data Belum Lengkap', 'Harap lengkapi semua form inputan!',
          backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white);
      return false;
    }
    return true;
  }

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

  // --- SUBMIT DATA ---
  void _saveDraft() {
    Map<String, dynamic> data = {
      "no_io": ioController.text,
      "unit_io": selectedUnit.value?.namaUnit,
      "nopol": platController.text,
      "km": kmPengisianC.text,
      "solar": pengisianSolarC.text,
    };
    _draftService.saveDraft(data);
  }

  void confirmSubmit() {
    if (photoSlots.any((element) => element == null)) {
      Get.snackbar('Foto Belum Lengkap', 'Harap lengkapi 3 foto bukti (Bon, Depan, Samping)!',
          backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white);
      return;
    }

    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieConfirmation(),
        title: "Konfirmasi Submit",
        message: "Apakah data pengeluaran solar sudah sesuai? Data tidak dapat diubah setelah disubmit.",

        // Button Kiri
        secondaryButtonText: "Periksa Lagi",
        onSecondaryPressed: () => Get.back(),

        // Button Kanan
        primaryButtonText: "Submit",
        onPrimaryPressed: () {
          Get.back();
          _processSubmitToApi();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _processSubmitToApi() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
      barrierDismissible: false,
    );

    try {
      String cleanKm = TextConvertHelper().cleanNumber(kmPengisianC.text);
      String cleanSolar = TextConvertHelper().cleanNumber(pengisianSolarC.text);
      String namaSupirFinal = selectedStatusSupir.value == 'Internal'
          ? (selectedDriver.value?.nama ?? "")
          : driverNameManualController.text;

      Map<String, dynamic> payload = {
        "no_io": ioController.text,
        "unit_io": selectedUnit.value?.namaUnit ?? "-",
        "nopol_check": platController.text.toUpperCase(),
        "status_supir": selectedStatusSupir.value,
        "supir_check": namaSupirFinal.toUpperCase(),
        "km_pengisian": double.tryParse(cleanKm) ?? 0,
        "jumlah_pengisian_solar": double.tryParse(cleanSolar) ?? 0,
      };

      List<File?> photos = photoSlots.map((e) => e != null ? File(e.tempPath) : null).toList();

      final response = await _apiService.createInboundFot(
          payloadMap: payload,
          photos: photos
      );

      String noDoc = response['no_doc'] ?? "-";
      String message = response['message'] ?? "Berhasil disubmit";

      await _saveToOutstanding(noDoc, payload);
      await _draftService.deleteDraft();

      Get.back(); // Tutup Loading

      // 9. Dialog Sukses
      Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieSuccess(),
          title: "Berhasil",
          message: "$message\nNo Dokumen: $noDoc",
          primaryButtonText: "Lanjut Pengisian",
          onPrimaryPressed: () {
            Get.back();

            Get.offNamed(
                Routes.PENGISIAN_SOLAR_PENGELUARAN,
                arguments: {
                  'noDoc': noDoc,
                  'noIO': payload['no_io'],
                  'unitIO': selectedUnit.value?.namaUnit,
                  'noPolisi': payload['nopol_check'],
                  'tanggal': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  'jumlah_pengisian_solar':  double.tryParse(cleanSolar) ?? 0,
                  'status': 'pengisian_solar_pengeluaran',
                }
            );
          },
        ),
        barrierDismissible: false,
      );

    } on DioException catch (e) {
      Get.back();
      _handleApiError(e);
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Terjadi kesalahan aplikasi: $e",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    }
  }

  Future<void> _saveToOutstanding(String noDoc, Map<String, dynamic> payload) async {
    final auth = _loginService.getCurrentAuth();
    if (auth == null) return;

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
      pathFoto1: photoSlots[0]?.tempPath,
      pathFoto2: photoSlots[1]?.tempPath,
      pathFoto3: photoSlots[2]?.tempPath,
    );

    final trx = TransactionPengeluaranModel(
      noBast: noDoc,
      status: 'pengisian_solar_pengeluaran',
      dateCreated: DateTime.now().toIso8601String(),
      dataPengeluaran: pengeluaranDetail,
    );

    await outstandingService.saveTransactionPengeluaran(trx);
  }

  void _handleApiError(DioException e) {
    String title = "Gagal Submit";
    String message = "Terjadi kesalahan koneksi";

    if (e.response != null) {
      int statusCode = e.response!.statusCode ?? 500;
      var data = e.response!.data;

      String detailMsg = "";
      if (data is Map && data['detail'] != null) {
        detailMsg = data['detail'];
      }

      if (statusCode == 404) {
        message = detailMsg.isNotEmpty ? detailMsg : "Internal Order (IO) tidak ditemukan di SAP/Database.";
      } else if (statusCode == 400) {
        message = detailMsg.isNotEmpty ? detailMsg : "Data request tidak valid. Cek inputan Anda.";
      } else if (statusCode == 500) {
        message = "Terjadi kesalahan pada Server (Internal Server Error).";
      } else {
        message = detailMsg.isNotEmpty ? detailMsg : "Error Code: $statusCode";
      }
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.alertSoftRed,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}