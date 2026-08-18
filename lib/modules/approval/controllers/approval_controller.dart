import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../configs/app_colors.dart';
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
        Get.snackbar("Terjadi Kesalahan", "Gagal memuat detail data transaksi");
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
      Get.snackbar("Informasi", "Tanda tangan wajib diisi untuk Approve", backgroundColor: AppColors.info, colorText: Colors.white);
      return;
    }

    if (status == 'REJECTED' && noteController.text.isEmpty) {
      Get.snackbar("Informasi", "Mohon isi catatan alasan penolakan", backgroundColor: AppColors.info, colorText: Colors.white);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator(color: AppColors.primary)), barrierDismissible: false);

    File? signFile;
    if (status == 'APPROVED') {
      final Uint8List? data = await signatureController.toPngBytes();
      final tempDir = await getTemporaryDirectory();
      signFile = await File('${tempDir.path}/sign_approval_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await signFile.writeAsBytes(data!);
    }

    final auth = _loginService.getCurrentAuth();
    final userLevel = auth?.user.otorisasi.first ?? 'fuel_level_2';
    final kodeUnit = auth?.currentKodeUnit ?? ''; // Ambil kode unit untuk parameter getApprovalList

    final success = await _approvalService.submitPenerimaanApprovalDecision(
      noDoc: noBast,
      levelApproval: userLevel,
      status: status,
      note: noteController.text,
      signature: signFile,
    );

    if (success) {
      // PENGECEKAN FULL APPROVED
      if (status == 'APPROVED') {
        final approvalList = await _approvalService.getApprovalList(
          kodeUnit: kodeUnit,
          noBast: noBast,
          transactionType: transactionType,
        );

        // Jika data ada, dan SEMUA status_approve-nya adalah 'APPROVED' (tidak ada yang PENDING/REJECTED)
        bool isFullApproved = approvalList.isNotEmpty &&
            approvalList.every((appv) => appv.statusApprove?.toUpperCase() == 'APPROVED');

        if (isFullApproved) {
          String? downloadedFilePath = await _approvalService.downloadPdfDocument(noBast);

          Get.back(); // Tutup loading progress dialog
          Get.offAllNamed(Routes.HOME); // Arahkan ke Home

          if (downloadedFilePath != null) {
            Get.snackbar(
              "Full Approved!",
              "Dokumen berhasil diunduh.",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            await Future.delayed(const Duration(milliseconds: 500));
            await OpenFilex.open(downloadedFilePath);

          } else {
            Get.snackbar(
              "Full Approved!",
              "Transaksi selesai, namun gagal mengunduh PDF secara otomatis.",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
          return;
        }
      }

      // (Belum Full Approved atau REJECTED)
      Get.back();
      Get.offAllNamed(Routes.HOME);
      Get.snackbar("Sukses", "Dokumen berhasil diproses ($status)", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.back();
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