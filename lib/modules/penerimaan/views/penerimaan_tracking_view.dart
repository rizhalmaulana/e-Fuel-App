import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../../../routes/app_pages.dart';
import '../controllers/penerimaan_tracking_controller.dart';
import '../../../widgets/component/penerimaan_step_view.dart';

class PenerimaanTrackingView extends GetView<PenerimaanTrackingController> {
  const PenerimaanTrackingView({super.key});

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
            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primary),
          )),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.primary),
            onPressed: () => Get.offAllNamed(Routes.HOME),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

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
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow("Hari, Tanggal", controller.formattedDate.value),
                              _buildInfoRow("No. PO", controller.transaction.value?.dataSebelum?.purchNo ?? "-"),
                              _buildInfoRow("Jumlah", "${controller.transaction.value?.dataSebelum?.volumeVendor?.toStringAsFixed(0) ?? 0} Ltr"),
                              _buildInfoRow("No. Polisi", controller.transaction.value?.dataSebelum?.nopolVendor ?? "-"),
                              _buildInfoRow("Nama Sopir", controller.transaction.value?.dataSebelum?.supirVendor ?? "-", isLast: true),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                          child: Text(
                            "Progress",
                            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                          child: PenerimaanStepView(steps: controller.steps),
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
        children: [
          Text(
            label,
            style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
          ),
          Text(
            value,
            style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(12),
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

          if (controller.isWaitingApproval) {
            label = "Selesai";
            btnColor = AppColors.primary;
          } else if (controller.isFinished) {
            label = "Lihat BAST";
            onTap = controller.viewBastPdf;
            btnColor = AppColors.primary;
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