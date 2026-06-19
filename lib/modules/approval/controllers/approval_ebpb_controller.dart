import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../configs/app_colors.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/pengeluaran/services/pengeluaran_api_service.dart';
import '../services/approval_service.dart';
import '../../../routes/app_pages.dart';

class ApprovalEbpbController extends GetxController {
  final ApprovalService _approvalService = ApprovalService();
  final PengeluaranApiService _pengeluaranService = PengeluaranApiService();
  final LoginService _loginService = Get.find<LoginService>();

  // Data dari Arguments
  String noDoc = '';
  String transactionType = '';

  // Data Detail (Reactive)
  var isLoading = true.obs;
  var detailData = <String, dynamic>{}.obs;

  // UI State
  var pageController = PageController();
  var currentPage = 0.obs;

  // Form (Approval Action)
  final noteController = TextEditingController();
  late SignatureController signatureController;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null && args is Map) {
      noDoc = args['noDoc'] ?? args['noBast'] ?? '';
      transactionType = args['type'] ?? 'E-BPB';
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
    if (noDoc.isNotEmpty) {
      final data = await _approvalService.getEbpbDetail(noDoc);
      if (data != null) {
        detailData.assignAll(data);
      } else {
        Get.snackbar("Terjadi Kesalahan", "Gagal memuat detail data transaksi E-BPB");
      }
    }
    isLoading.value = false;
  }

  void nextPage() async {
    await Future.delayed(const Duration(milliseconds: 500));
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
      Get.snackbar("Informasi", "Tanda tangan wajib diisi untuk Approve",
          backgroundColor: AppColors.info, colorText: Colors.white);
      return;
    }

    if (status == 'REJECTED' && noteController.text.trim().isEmpty) {
      Get.snackbar("Informasi", "Mohon isi catatan alasan penolakan",
          backgroundColor: AppColors.info, colorText: Colors.white);
      return;
    }

    Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        barrierDismissible: false);

    try {
      File? signFile;
      if (status == 'APPROVED') {
        final Uint8List? data = await signatureController.toPngBytes();
        final tempDir = await getTemporaryDirectory();
        signFile = await File('${tempDir.path}/sign_ebpb_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await signFile.writeAsBytes(data!);
      }

      final auth = _loginService.getCurrentAuth();
      final userLevel = auth?.user.otorisasi.first ?? 'fuel_level_2';

      await _pengeluaranService.updateStatusEBPB(
        noDoc: noDoc,
        statusApprove: status,
        levelApproval: userLevel,
        catatan: noteController.text.trim(),
        isSign: signFile != null,
      );

      if (status == 'APPROVED' && signFile != null) {
        await _pengeluaranService.uploadSignatureEBPB(
          noDoc: noDoc,
          levelApproval: userLevel,
          imageSign: signFile,
        );
      }

      // Check for Full Approved
      bool isFullApproved = false;
      String? downloadedFilePath;

      if (status == 'APPROVED') {
        // Fetch updated details to verify all levels have approved
        final updatedDetail = await _approvalService.getEbpbDetail(noDoc);
        if (updatedDetail != null) {
          final approvalsList = updatedDetail['approvals'] as List?;
          isFullApproved = approvalsList != null &&
              approvalsList.isNotEmpty &&
              approvalsList.every((appv) => appv['status_approve']?.toUpperCase() == 'APPROVED');
        }

        if (isFullApproved) {
          downloadedFilePath = await _approvalService.downloadPdfDocument(noDoc);
        }
      }

      Get.back(); // Tutup loading progress dialog
      Get.offAllNamed(Routes.HOME);

      if (isFullApproved) {
        if (downloadedFilePath != null) {
          Get.snackbar(
            "Full Approved!",
            "Dokumen E-BPB berhasil diunduh.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // 🟢 Buka file PDF secara otomatis!
          await Future.delayed(const Duration(milliseconds: 500)); // Beri jeda sedikit agar transisi ke Home mulus
          await OpenFilex.open(downloadedFilePath);
        } else {
          // Jika gagal mendownload dari server
          Get.snackbar(
            "Full Approved!",
            "Transaksi selesai, namun gagal mengunduh PDF secara otomatis.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar("Sukses", "Dokumen E-BPB berhasil diproses ($status)",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
          
    } catch (e) {
      Get.back(); // Tutup loading progress dialog
      Get.snackbar("Gagal", "Terjadi kesalahan saat memproses data",
          backgroundColor: Colors.red, colorText: Colors.white);
      print("Error submit EBPB: $e");
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
