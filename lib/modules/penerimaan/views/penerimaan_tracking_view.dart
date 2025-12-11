import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../controllers/penerimaan_tracking_controller.dart';
import '../../../widgets/component/penerimaan_step_view.dart'; // Gunakan widget step view yg sudah ada

class PenerimaanTrackingView extends GetView<PenerimaanTrackingController> {
  const PenerimaanTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Status Transaksi', style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("No. Dokumen", style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(controller.noBast.value, style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText)),
                    const SizedBox(height: 12),
                    Text("Tanggal Inbound", style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(controller.formattedDate.value, style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText)),
                  ],
                ),
              ),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text("Riwayat Aktivitas", style: AppFonts.fUrbanistBold16),
                    ),
                    const SizedBox(height: 8),

                    // REUSE WIDGET PENERIMAAN STEP VIEW ANDA
                    // Pastikan PenerimaanStepView menerima List<PenerimaanStep>
                    PenerimaanStepView(
                        steps: controller.steps
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              _buildActionBtn(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionBtn() {
    if (controller.currentStepId.value < 5) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () {
                final activeStep = controller.steps.firstWhere((s) => s.isActive.value);
                Get.toNamed(activeStep.routeName, arguments: {'noBast': controller.noBast.value});
              },
              child: const Text("Lanjutkan Transaksi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}