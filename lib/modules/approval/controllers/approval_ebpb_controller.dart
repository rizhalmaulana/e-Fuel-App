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
import '../../../helpers/network_error_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/component/custom_snackbar.dart';
import '../../../widgets/dialog/dialog_flexible.dart';

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

  bool _isSubmitting = false;

  void fetchDetailData() async {
    isLoading.value = true;
    try {
      if (noDoc.isNotEmpty) {
        final data = await _approvalService.getEbpbDetail(noDoc);
        if (data != null) {
          if (data['approvals'] != null && data['approvals'] is List) {
            final approvals = data['approvals'] as List;

            approvals.forEach((app) {
              String title = (app['title']?.toString() ?? '').toUpperCase();
              if (title.contains('KERANI') || title.contains('KEPALA GUDANG')) {
                app['title'] = 'Asst. Traksi';
              }
            });

            final order = ['ASST. TRAKSI', 'KASIE', 'MANAGER'];

            approvals.sort((a, b) {
              String titleA = (a['title']?.toString() ?? '').toUpperCase();
              String titleB = (b['title']?.toString() ?? '').toUpperCase();

              int indexA = order.indexWhere((t) => titleA.contains(t));
              int indexB = order.indexWhere((t) => titleB.contains(t));

              if (indexA == -1) indexA = 99;
              if (indexB == -1) indexB = 99;

              if (indexA != indexB) {
                return indexA.compareTo(indexB);
              }

              int levelA = int.tryParse(a['level_approve']?.toString() ?? '99') ?? 99;
              int levelB = int.tryParse(b['level_approve']?.toString() ?? '99') ?? 99;
              return levelA.compareTo(levelB);
            });
            data['approvals'] = approvals;
          }
          detailData.assignAll(data);
        } else {
          Get.snackbar("Terjadi Kesalahan", "Gagal memuat detail data transaksi E-BPB");
        }
      }
    } catch (e) {
      NetworkErrorHelper.showErrorSnackbar(
        title: "Gagal Memuat E-BPB",
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() async {
    await Future.delayed(const Duration(milliseconds: 500));
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

    if (status == 'REJECTED' && noteController.text.trim().isEmpty) {
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
        loadingTitle: 'Memproses E-BPB...',
        loadingSubtitle: 'Mohon tunggu sebentar',
        errorTitle: 'Gagal Proses E-BPB',
        task: () async {
          File? signFile;
          if (status == 'APPROVED') {
            final Uint8List? data = await signatureController.toPngBytes();
            if (data == null || data.isEmpty) {
              throw "Gagal memproses gambar tanda tangan. Silakan tanda tangan ulang.";
            }
            final tempDir = await getTemporaryDirectory();
            signFile = await File(
                    '${tempDir.path}/sign_ebpb_${DateTime.now().millisecondsSinceEpoch}.png')
                .create();
            await signFile.writeAsBytes(data);
          }

          final auth = _loginService.getCurrentAuth();
          final otorisasi = auth?.user.otorisasi ?? [];
          final userLevel =
              otorisasi.isNotEmpty ? otorisasi.first : 'fuel_level_2';

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

          bool isFullApproved = false;
          String? downloadedFilePath;

          if (status == 'APPROVED') {
            final updatedDetail = await _approvalService.getEbpbDetail(noDoc);
            if (updatedDetail != null) {
              final approvalsList = updatedDetail['approvals'] as List?;
              isFullApproved = approvalsList != null &&
                  approvalsList.isNotEmpty &&
                  approvalsList.every((appv) =>
                      appv['status_approve']?.toUpperCase() == 'APPROVED');
            }

            if (isFullApproved) {
              downloadedFilePath = await _approvalService
                  .downloadPdfDocument(noDoc, isEbpb: true);
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
              message: "Dokumen E-BPB berhasil diunduh.",
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
            message: "Dokumen E-BPB berhasil diproses ($status).",
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
