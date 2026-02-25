import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/component/penerimaan_step_view.dart';
import '../controllers/pengeluaran_tracking_controller.dart';

class PengeluaranTrackingView extends GetView<PengeluaranTrackingController> {
  const PengeluaranTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.offAllNamed(Routes.HOME);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Obx(() => Text(
            controller.transaction.value?.noBast ?? "-",
            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryOrange),
          )),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.primaryOrange),
            onPressed: () => Get.offAllNamed(Routes.HOME),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
          }

          final trx = controller.transaction.value;
          final detail = trx?.dataPengeluaran;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CARD DATA UTAMA (SESUAI REQUEST) ---
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // 1. Hari, Tanggal
                              _buildInfoRow("Hari, Tanggal", controller.formattedDate.value),

                              // 2. No. Doc (BAST)
                              _buildInfoRow("No. Doc", trx?.noBast ?? "-"),

                              // 3. No. IO
                              _buildInfoRow("No. IO", detail?.noIo ?? "-"),

                              // 4. Unit IO
                              _buildInfoRow("Unit IO", detail?.unitIO ?? "-"),

                              // 5. Nama Supir
                              _buildInfoRow("Nama Supir", detail?.supirCheck ?? "-"),

                              // 6. No. Polisi
                              _buildInfoRow("No. Polisi", detail?.nopolCheck ?? "-", isLast: true),
                            ],
                          ),
                        ),

                        // --- PROGRESS STEP ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                          child: Text(
                            "Progress",
                            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryOrange),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                          child: PenerimaanStepView(
                            steps: controller.steps,
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomAction(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(Get.context!).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Obx(() {
          String label = "Kembali ke Beranda";
          VoidCallback onTap = controller.backToHome;
          Color btnColor = AppColors.secondaryText;

          // Logic Button Color & Text
          if (controller.isWaitingApproval) {
            label = "Selesai";
            btnColor = AppColors.primaryOrange;
          } else if (controller.isFinished) {
            label = "Lihat Dokumen";
            btnColor = AppColors.primaryOrange;
            // onTap = controller.viewPdf; // Jika ada
          }

          return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onTap,
              child: Text(
                label,
                style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white),
              )
          );
        }),
      ),
    );
  }
}