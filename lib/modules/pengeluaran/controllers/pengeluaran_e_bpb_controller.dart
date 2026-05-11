import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../../../configs/app_colors.dart';
import '../../../datas/models/bon_sementara/bon_sementara_model.dart';
import '../../../datas/models/pengeluaran/pengeluaran_daily_model.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
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

  final Map<String, TextEditingController> costCenterControllers = {};
  final Map<String, TextEditingController> noteControllers = {};

  final searchTextC = TextEditingController();

  var isLoading = false.obs;
  var selectedUnitCode = 'E000'.obs;
  var selectedDate = "Pilih Tanggal".obs;
  var totalVolume = 0.0.obs;
  var totalQty = 0.obs;

  var selectedDateDisplay = "".obs;
  var selectedDateApi = "".obs;

  late SignatureController signatureController;
  var userName = "-".obs;
  var userJabatan = "-".obs;
  var userLevelApproval = "-".obs;

  TextEditingController getCostCenterController(String id) {
    return costCenterControllers.putIfAbsent(id, () => TextEditingController());
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
    super.onClose();
  }

  void _loadUserInfo() {
    final authData = _loginService.getCurrentAuth();
    if (authData != null) {
      selectedUnitCode.value = authData.currentKodeUnit ?? 'Unknown';
      userName.value = "${authData.user.firstName} ${authData.user.lastName}";
      userJabatan.value = authData.user.jabatan?.namaJabatan ?? "Asst. Traksi";
      userLevelApproval.value = authData.user.otorisasi.first;
    }
  }

  void clearSignature() {
    signatureController.clear();
  }

  void nextStep() {
    if (dailyTransactionList.isEmpty) {
      Get.snackbar("Data Kosong", "Tidak ada transaksi untuk diproses.", backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    bool isValid = true;
    for (var item in dailyTransactionList) {
      String key = item.id.toString();
      String costCenter = costCenterControllers[key]?.text ?? "";
      if (costCenter.trim().isEmpty) {
        isValid = false;
        break;
      }
    }

    if (!isValid) {
      Get.snackbar("Data Belum Lengkap", "Cost Center wajib diisi pada semua item.", backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    currentStep.value = 1;
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void prevStep() {
    currentStep.value = 0;
    pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      if (selectedDateApi.value.isNotEmpty) initialDate = DateFormat('yyyy-MM-dd').parse(selectedDateApi.value);
    } catch (e) {}

    DateTime? picked = await showDatePicker(
      context: context, initialDate: initialDate, firstDate: DateTime(2024), lastDate: DateTime(2030),
    );

    if (picked != null) {
      selectedDateDisplay.value = DateFormat('dd/MM/yyyy').format(picked);
      selectedDateApi.value = DateFormat('yyyy-MM-dd').format(picked);
      fetchDailyTransactions();
    }
  }

  Future<void> fetchDailyTransactions() async {
    isLoading.value = true;
    try {
      var data = await _apiService.getDailyTransactions(dateInbound: selectedDateApi.value, kodeUnit: selectedUnitCode.value);
      dailyTransactionList.assignAll(data);
      _calculateTotals();
    } catch (e) {
      dailyTransactionList.clear();
      _calculateTotals();
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
    if (query.isEmpty) {
      fetchDailyTransactions();
    } else {
      var filtered = dailyTransactionList.where((item) {
        return (item.namaUnit ?? "").toLowerCase().contains(query.toLowerCase()) ||
            (item.noIo ?? "").toLowerCase().contains(query.toLowerCase());
      }).toList();
      dailyTransactionList.assignAll(filtered);
    }
  }

  void _calculateTotals() {
    totalQty.value = dailyTransactionList.length;
    totalVolume.value = dailyTransactionList.fold(0.0, (sum, item) => sum + (item.aktualLiter ?? 0.0));
  }

  Future<void> submitBpb() async {
    if (signatureController.isEmpty) {
      Get.snackbar("Tanda Tangan Kosong", "Harap tanda tangan terlebih dahulu sebelum submit.", backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    // Prepare Payload
    List<Map<String, dynamic>> fotPayload = [];
    for (var item in dailyTransactionList) {
      String key = item.id.toString();
      fotPayload.add({
        "no_doc": item.noDoc ?? "-",
        "cost_center": costCenterControllers[key]?.text ?? "",
        "keterangan": noteControllers[key]?.text ?? ""
      });
    }

    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieQuestion(),
        title: "Konfirmasi E-BPB",
        message: "Buat E-BPB untuk ${dailyTransactionList.length} item?",
        primaryColor: AppColors.primaryOrange,
        secondaryButtonText: "Batal",
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: "Ya, Submit",
        onPrimaryPressed: () {
          Get.back();
          _processSubmitApi(fotPayload);
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<File?> _getSignatureFile() async {
    if (signatureController.isEmpty) return null;

    final Uint8List? data = await signatureController.toPngBytes();
    if (data == null) return null;

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/signature_ebpb_${DateTime.now().millisecondsSinceEpoch}.png').create();

    file.writeAsBytesSync(data);
    return file;
  }

  void _processSubmitApi(List<Map<String, dynamic>> fotPayload) async {
    Get.dialog(const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)), barrierDismissible: false);

    try {
      Map<String, dynamic> payload = {
        "kode_unit": selectedUnitCode.value,
        "date_inbound": selectedDateApi.value,
        "fot": fotPayload
      };

      // HIT API CREATE TRANSACTION BPB
      var responseBpb = await _apiService.createTransactionEBPB(payload: payload);

      String noDoc = responseBpb['no_doc']?.toString() ?? "";
      if (noDoc.isEmpty) {
        throw Exception("Gagal mendapatkan Nomor Dokumen dari server.");
      }

      // Mulai Flow Approval untuk Fuel Level 1
      if (userLevelApproval.value == "fuel_level_1") {
        // HIT API CREATE APPROVAL EBPB
        await _apiService.createTransactionEBPBApproval(
            noDoc: noDoc,
            kodeUnit: selectedUnitCode.value
        );

        // HIT API UPLOAD SIGNATURE
        File? signatureFile = await _getSignatureFile();
        if (signatureFile != null) {
          await _apiService.uploadSignatureEBPB(
            noDoc: noDoc,
            levelApproval: userLevelApproval.value,
            imageSign: signatureFile,
          );
        }

        // HIT API UPDATE STATUS (APPROVED untuk level 1)
        await _apiService.updateStatusEBPB(
          noDoc: noDoc,
          statusApprove: "APPROVED",
          levelApproval: userLevelApproval.value,
          catatan: "",
          isSign: signatureFile != null,
        );
      }

      Get.back(); // Tutup loading dialog

      // Tampilkan Dialog Sukses
      Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieSuccess(),
          title: "Berhasil",
          message: "Dokumen E-BPB ($noDoc) berhasil dibuat dan diajukan.",
          primaryColor: AppColors.primaryOrange,
          primaryButtonText: "OK",
          onPrimaryPressed: () {
            Get.back();
            Get.back();
          },
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.back(); // Tutup loading dialog
      String errorMessage = "Terjadi kesalahan pada server";
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }
      Get.snackbar("Gagal", errorMessage, backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    }
  }
}