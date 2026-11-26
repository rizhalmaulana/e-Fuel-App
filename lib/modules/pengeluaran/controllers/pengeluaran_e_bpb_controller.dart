import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../../../configs/app_colors.dart';
import '../../../datas/models/bon_sementara/bon_sementara_model.dart';
import '../../../datas/models/pengeluaran/pengeluaran_daily_model.dart';
import '../../../datas/models/pengeluaran/pengeluaran_outstanding_model.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../helpers/network_error_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/component/custom_snackbar.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../../datas/dummy/master_unit_dummy.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/pengeluaran/services/pengeluaran_api_service.dart';
import '../services/bon_sementara_local_service.dart';

class PengeluaranEBpbController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final BonSementaraLocalService _localService = BonSementaraLocalService();
  final PengeluaranApiService _apiService = PengeluaranApiService();

  // --- Page Control ---
  final PageController pageController = PageController();
  var currentStep = 0.obs; // 0: Data Table, 1: Signature

  var bpbList = <BonSementaraModel>[].obs;
  var filteredBpbList = <BonSementaraModel>[].obs;
  var dailyTransactionList = <PengeluaranDailyModel>[].obs;
  final List<PengeluaranDailyModel> _allDailyTransactions = [];

  final Map<String, TextEditingController> costCenterControllers = {};
  final Map<String, TextEditingController> noteControllers = {};

  final searchTextC = TextEditingController();
  final searchQuery = ''.obs;

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var isLoadingOutstanding = false.obs;
  final outstandingList = <PengeluaranOutstandingModel>[].obs;
  final outstandingError = RxnString();
  var selectedUnitCode = 'E000'.obs;
  var selectedUnitTitle = 'Unknown'.obs;
  var selectedDate = "Pilih Tanggal".obs;
  var totalVolume = 0.0.obs;
  var totalQty = 0.obs;

  /// Format total volume tanpa pembulatan ke bilangan bulat,
  /// namun tetap bersih dari noise floating-point IEEE 754 (mis. 81.03999999999999 -> 81.04).
  String get formattedTotalVolume {
    final val = totalVolume.value;
    final clean = double.parse(val.toStringAsFixed(6));
    if (clean % 1 == 0) {
      return clean.toInt().toString();
    }
    return clean
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  var hasOutstandingPreviousDate = false.obs;
  var outstandingPreviousMessage = "".obs;

  var selectedDateDisplay = "".obs;
  var selectedDateApi = "".obs;

  late SignatureController signatureController;
  var userName = "-".obs;
  var userJabatan = "-".obs;
  var userLevelApproval = "-".obs;

  TextEditingController getCostCenterController(String id, {String? initialValue}) {
    return costCenterControllers.putIfAbsent(id, () => TextEditingController(text: initialValue ?? ""));
  }

  void updateCostCenter(String id, String newCostCenter, PengeluaranDailyModel item) {
    if (costCenterControllers.containsKey(id)) {
      costCenterControllers[id]!.text = newCostCenter;
    } else {
      costCenterControllers[id] = TextEditingController(text: newCostCenter);
    }
    item.costCenter = newCostCenter;
    dailyTransactionList.refresh();
  }

  TextEditingController getNoteController(String id) {
    return noteControllers.putIfAbsent(id, () => TextEditingController());
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();

    signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    DateTime now = DateTime.now();
    selectedDateDisplay.value = DateFormat('dd/MM/yyyy').format(now);
    selectedDateApi.value = DateFormat('yyyy-MM-dd').format(now);

    fetchDailyTransactions();
  }

  @override
  void onClose() {
    signatureController.dispose();
    pageController.dispose();
    searchTextC.dispose();
    for (final ctrl in costCenterControllers.values) {
      ctrl.dispose();
    }
    for (final ctrl in noteControllers.values) {
      ctrl.dispose();
    }
    costCenterControllers.clear();
    noteControllers.clear();
    super.onClose();
  }

  void _loadUserInfo() {
    final authData = _loginService.getCurrentAuth();
    if (authData != null) {
      String unitCode = authData.currentKodeUnit ?? 'Unknown';
      selectedUnitCode.value = unitCode;

      final matched = mappingMasterUnit.firstWhere(
        (unit) => unit['kode_unit'] == unitCode,
        orElse: () => {},
      );
      if (matched.isNotEmpty && matched['title_unit'] != null) {
        String namaUnit = matched['nama_unit'] ?? '';
        selectedUnitTitle.value = namaUnit.isNotEmpty 
            ? namaUnit
            : "${matched['title_unit']}";
      } else {
        selectedUnitTitle.value = unitCode;
      }

      userName.value = "${authData.user.firstName} ${authData.user.lastName}";
      userJabatan.value = authData.user.jabatan?.namaJabatan ?? "Asst. Traksi";
      userLevelApproval.value = authData.user.otorisasi.isNotEmpty
          ? authData.user.otorisasi.first
          : "fuel_level_1";
    }
  }

  void clearSignature() {
    signatureController.clear();
  }

  void nextStep() {
    if (hasOutstandingPreviousDate.value) {
      Get.snackbar(
          "Tidak Bisa Lanjut", outstandingPreviousMessage.value,
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    if (_allDailyTransactions.isEmpty) {
      Get.snackbar("Data Kosong", "Tidak ada transaksi untuk diproses.",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    bool isValid = true;
    for (var item in _allDailyTransactions) {
      String key = item.id.toString();
      final kategori = (item.kategoriKendaraan ?? "").toUpperCase();
      final isTamuItem = kategori == "TAMU" || kategori == "TMU";
      if (isTamuItem) {
        String costCenter = costCenterControllers[key]?.text ?? item.costCenter ?? "";
        if (costCenter.trim().isEmpty || costCenter.trim() == "-") {
          isValid = false;
          break;
        }
      }
    }

    if (!isValid) {
      Get.snackbar(
          "Data Belum Lengkap", "Cost Center wajib diisi untuk kategori TAMU.",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    currentStep.value = 1;
    pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void prevStep() {
    currentStep.value = 0;
    pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  /// Memuat daftar tanggal transaksi belum selesai (outstanding) dengan batas timeout
  /// agar tidak pernah menggantung di dialog loading.
  Future<void> loadOutstandingDates() async {
    if (isLoadingOutstanding.value) return;

    isLoadingOutstanding.value = true;
    outstandingError.value = null;

    try {
      final result = await _apiService
          .getOutstandingTransactions()
          .timeout(const Duration(seconds: 12));
      outstandingList.assignAll(result);
    } catch (e) {
      outstandingError.value = NetworkErrorHelper.getFriendlyErrorMessage(e);
    } finally {
      isLoadingOutstanding.value = false;
    }
  }

  /// Format tampilan tanggal dari string API (yyyy-MM-dd -> dd/MM/yyyy).
  String formatOutstandingDate(String rawDate) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  /// Dipanggil setelah user memilih tanggal dari BottomSheet.
  void selectTransactionDate(PengeluaranOutstandingModel item) {
    final rawDate = item.tanggalTransaksi ?? '';
    if (rawDate.isEmpty) return;

    selectedDateDisplay.value = formatOutstandingDate(rawDate);
    selectedDateApi.value = rawDate;
    clearSearch();
    fetchDailyTransactions();
  }

  Future<void> fetchDailyTransactions() async {
    isLoading.value = true;
    try {
      var data = await _apiService
          .getDailyTransactions(
              dateInbound: selectedDateApi.value,
              kodeUnit: selectedUnitCode.value)
          .timeout(const Duration(seconds: 12));
      _allDailyTransactions
        ..clear()
        ..addAll(data);
      _applySearchFilter();
      _calculateTotals();
    } catch (e) {
      _allDailyTransactions.clear();
      dailyTransactionList.clear();
      _calculateTotals();
      Get.snackbar(
        "Gagal Memuat Data",
        NetworkErrorHelper.getFriendlyErrorMessage(e),
        backgroundColor: AppColors.alertSoftRed,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBpbData() async {
    isLoading.value = true;
    try {
      var localData = await _localService.getMasterList();

      bpbList.value = localData.where((item) => (item.liter ?? 0) > 0).toList();
      filteredBpbList.assignAll(bpbList);
      _calculateTotals();
    } finally {
      isLoading.value = false;
    }
  }

  void searchBpb(String query) {
    searchQuery.value = query;
    _applySearchFilter();
  }

  void clearSearch() {
    searchTextC.clear();
    searchQuery.value = '';
    _applySearchFilter();
  }

  void _applySearchFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      dailyTransactionList.assignAll(_allDailyTransactions);
    } else {
      final filtered = _allDailyTransactions.where((item) {
        return (item.namaUnit ?? "").toLowerCase().contains(q) ||
            (item.noIo ?? "").toLowerCase().contains(q) ||
            (item.noDoc ?? "").toLowerCase().contains(q) ||
            (item.namaSupir ?? "").toLowerCase().contains(q) ||
            (item.costCenter ?? "").toLowerCase().contains(q);
      }).toList();
      dailyTransactionList.assignAll(filtered);
    }
  }

  void _calculateTotals() {
    totalQty.value = _allDailyTransactions.length;
    totalVolume.value = _allDailyTransactions.fold(
        0.0, (sum, item) => sum + (item.aktualLiter ?? 0.0));
  }

  Future<void> submitBpb() async {
    if (isSubmitting.value) return;
    if (signatureController.isEmpty) {
      DialogFlexible.showInfo(
        title: "Tanda Tangan Kosong",
        message: "Tanda tangan wajib diisi sebelum submit.",
        color: AppColors.primaryOrange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    // Prepare Payload dari seluruh transaksi pada tanggal terpilih (tidak terpotong filter search)
    List<Map<String, dynamic>> fotPayload = [];
    for (var item in _allDailyTransactions) {
      String key = item.id.toString();
      bool isCc = (item.noIo?.trim().isEmpty ?? true) || item.noIo == "-";
      fotPayload.add({
        "no_doc": item.noDoc ?? "-",
        "cost_center": isCc ? (costCenterControllers[key]?.text ?? item.costCenter ?? "") : "",
        "keterangan": noteControllers[key]?.text ?? ""
      });
    }

    isSubmitting.value = true;
    try {
      final result = await DialogFlexible.confirmAndRun<String>(
        logo: LottiesHelper().getLottieQuestion(),
        title: "Konfirmasi E-BPB",
        message:
            "Buat E-BPB untuk ${_allDailyTransactions.length} transaksi ($formattedTotalVolume Ltr)?",
        primaryColor: AppColors.primaryOrange,
        cancelText: "Batal",
        confirmText: "Ya, Submit",
        loadingTitle: "Membuat E-BPB...",
        loadingSubtitle: "Mohon tunggu sebentar",
        errorTitle: "Gagal Submit",
        onConfirm: () => _executeSubmitBpbApi(fotPayload),
      );

      if (result.succeeded) {
        final noDoc = result.data ?? '';
        Get.offAllNamed(Routes.HOME);
        CustomSnackbar.showSuccess(
          title: "E-BPB Berhasil Dibuat",
          message: "Dokumen E-BPB ($noDoc) berhasil dibuat dan diajukan.",
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<File?> _getSignatureFile() async {
    if (signatureController.isEmpty) return null;

    final Uint8List? data = await signatureController.toPngBytes();
    if (data == null) return null;

    final tempDir = await getTemporaryDirectory();
    final file = await File(
            '${tempDir.path}/signature_ebpb_${DateTime.now().millisecondsSinceEpoch}.png')
        .create();

    file.writeAsBytesSync(data);
    return file;
  }

  Future<String> _executeSubmitBpbApi(
      List<Map<String, dynamic>> fotPayload) async {
    Map<String, dynamic> payload = {
      "kode_unit": selectedUnitCode.value,
      "tanggal_transaksi": selectedDateApi.value,
      "fot": fotPayload
    };

    var responseBpb =
        await _apiService.createTransactionEBPB(payload: payload);

    String noDoc = responseBpb['no_doc']?.toString() ?? "";
    if (noDoc.isEmpty) {
      throw "Gagal memproses dokumen E-BPB. Silakan coba lagi.";
    }

    if (userLevelApproval.value == "fuel_level_1") {
      await _apiService.createTransactionEBPBApproval(
          noDoc: noDoc, kodeUnit: selectedUnitCode.value);

      File? signatureFile = await _getSignatureFile();
      if (signatureFile != null) {
        await _apiService.uploadSignatureEBPB(
          noDoc: noDoc,
          levelApproval: userLevelApproval.value,
          imageSign: signatureFile,
        );
      }

      await _apiService.updateStatusEBPB(
        noDoc: noDoc,
        statusApprove: "APPROVED",
        levelApproval: userLevelApproval.value,
        catatan: "",
        isSign: signatureFile != null,
      );
    }

    return noDoc;
  }
}
