import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../auth/services/login_service.dart';
import '../services/approval_service.dart';
import '../../../routes/app_pages.dart';

class ApprovalController extends GetxController {
  final ApprovalService _approvalService = ApprovalService();
  final LoginService _loginService = Get.find<LoginService>();

  // Data dari Arguments
  String noBast = '';
  String transactionType = '';

  // Data Detail (Reactive)
  var isLoading = true.obs;
  var detailData = <String, dynamic>{}.obs;

  // UI State
  var pageController = PageController();
  var currentPage = 0.obs;

  // Form Step 2 (Approval Action)
  final noteController = TextEditingController();
  late SignatureController signatureController;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null && args is Map) {
      noBast = args['noBast'] ?? '';
      transactionType = args['type'] ?? '';
    }

    signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    fetchDetailData();
  }

  void fetchDetailData() async {
    isLoading.value = true;
    if (noBast.isNotEmpty) {
      final data = await _approvalService.getInboundOpenDetail(noBast);
      if (data != null) {
        detailData.assignAll(data);
      } else {
        Get.snackbar("Error", "Gagal memuat detail data transaksi");
      }
    }
    isLoading.value = false;
  }

  void nextPage() async {
    await Future.delayed(const Duration(seconds: 1));

    pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    currentPage.value = 1;
  }

  void prevPage() {
    pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
    currentPage.value = 0;
  }

  Future<void> submitDecision(String status) async {
    if (status == 'APPROVED' && signatureController.isEmpty) {
      Get.snackbar("Error", "Tanda tangan wajib diisi untuk Approve");
      return;
    }

    if (status == 'REJECTED' && noteController.text.isEmpty) {
      Get.snackbar("Error", "Mohon isi catatan alasan penolakan");
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    File? signFile;
    if (status == 'APPROVED') {
      final Uint8List? data = await signatureController.toPngBytes();
      final tempDir = await getTemporaryDirectory();
      signFile = await File('${tempDir.path}/sign_approval_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await signFile.writeAsBytes(data!);
    }

    final auth = _loginService.getCurrentAuth();
    final userLevel = auth?.user.otorisasi.first ?? 'fuel_level_2';

    final success = await _approvalService.submitPenerimaanApprovalDecision(
      noDoc: noBast,
      levelApproval: userLevel,
      status: status,
      note: noteController.text,
      signature: signFile,
    );

    Get.back();

    if (success) {
      Get.offAllNamed(Routes.HOME);
      Get.snackbar("Sukses", "Dokumen berhasil diproses ($status)", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Gagal", "Terjadi kesalahan saat memproses data", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    signatureController.dispose();
    noteController.dispose();
    pageController.dispose();
    super.onClose();
  }
}