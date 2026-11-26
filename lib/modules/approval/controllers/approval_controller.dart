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
import '../../../helpers/network_error_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/component/custom_snackbar.dart';
import '../../../widgets/dialog/dialog_flexible.dart';

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

  bool _isSubmitting = false;

  void fetchDetailData() async {
    isLoading.value = true;
    try {
      if (noBast.isNotEmpty) {
        final data = await _approvalService.getInboundOpenDetail(noBast);
        if (data != null) {
          detailData.assignAll(data);
        } else {
          Get.snackbar("Terjadi Kesalahan", "Gagal memuat detail data transaksi");
        }
      }
    } catch (e) {
      NetworkErrorHelper.showErrorSnackbar(
        title: "Gagal Memuat Data",
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() async {
    await Future.delayed(const Duration(seconds: 1));
    if (isClosed || !pageController.hasClients) return;

    pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    currentPage.value = 1;
  }

  void prevPage() {
    if (!pageController.hasClients) return;
    pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
    currentPage.value = 0;
  }

  Future<void> submitDecision(String status) async {
    if (_isSubmitting) return;

    if (status == 'APPROVED' && signatureController.isEmpty) {
      CustomSnackbar.showWarning(
        title: "Informasi",
        message: "Tanda tangan wajib diisi untuk Approve.",
      );
      return;
    }

    if (status == 'REJECTED' && noteController.text.isEmpty) {
      CustomSnackbar.showWarning(
        title: "Informasi",
        message: "Mohon isi catatan alasan penolakan.",
      );
      return;
    }

    _isSubmitting = true;
    try {
      final result = await DialogFlexible.runWithLoading<Map<String, dynamic>>(
        primaryColor: AppColors.primary,
        loadingTitle: 'Memproses Approval...',
        loadingSubtitle: 'Mohon tunggu sebentar',
        errorTitle: 'Gagal Proses Dokumen',
        task: () async {
          File? signFile;
          if (status == 'APPROVED') {
            final Uint8List? data = await signatureController.toPngBytes();
            if (data == null || data.isEmpty) {
              throw "Gagal memproses gambar tanda tangan. Silakan tanda tangan ulang.";
            }
            final tempDir = await getTemporaryDirectory();
            signFile = await File(
                    '${tempDir.path}/sign_approval_${DateTime.now().millisecondsSinceEpoch}.png')
                .create();
            await signFile.writeAsBytes(data);
          }

          final auth = _loginService.getCurrentAuth();
          final otorisasi = auth?.user.otorisasi ?? [];
          final userLevel =
              otorisasi.isNotEmpty ? otorisasi.first : 'fuel_level_2';
          final kodeUnit = auth?.currentKodeUnit ?? '';

          final success =
              await _approvalService.submitPenerimaanApprovalDecision(
            noDoc: noBast,
            levelApproval: userLevel,
            status: status,
            note: noteController.text,
            signature: signFile,
          );

          if (!success) {
            throw "Terjadi kesalahan saat memproses keputusan approval. Silakan coba lagi.";
          }

          bool isFullApproved = false;
          String? downloadedFilePath;

          if (status == 'APPROVED') {
            final approvalList = await _approvalService.getApprovalList(
              kodeUnit: kodeUnit,
              noBast: noBast,
              transactionType: transactionType,
            );

            isFullApproved = approvalList.isNotEmpty &&
                approvalList.every(
                    (appv) => appv.statusApprove?.toUpperCase() == 'APPROVED');

            if (isFullApproved) {
              downloadedFilePath =
                  await _approvalService.downloadPdfDocument(noBast);
            }
          }

          return {
            'isFullApproved': isFullApproved,
            'downloadedFilePath': downloadedFilePath,
          };
        },
      );

      if (result.succeeded && result.data != null) {
        final isFullApproved = result.data!['isFullApproved'] == true;
        final downloadedFilePath =
            result.data!['downloadedFilePath'] as String?;

        Get.offAllNamed(Routes.HOME);

        if (isFullApproved) {
          if (downloadedFilePath != null) {
            CustomSnackbar.showSuccess(
              title: "Full Approved!",
              message: "Dokumen berhasil diunduh.",
            );
            await Future.delayed(const Duration(milliseconds: 500));
            await OpenFilex.open(downloadedFilePath);
          } else {
            CustomSnackbar.showWarning(
              title: "Full Approved!",
              message:
                  "Transaksi selesai, namun gagal mengunduh PDF secara otomatis.",
            );
          }
        } else {
          CustomSnackbar.showSuccess(
            title: "Sukses",
            message: "Dokumen berhasil diproses ($status).",
          );
        }
      }
    } finally {
      _isSubmitting = false;
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