import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/configs/app_lotties.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/widgets/dialog/dialog_flexible.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/penerimaan/pengisian_solar_penerimaan_controller.dart';

class PengisianSolarPenerimaanView extends GetView<PengisianSolarPenerimaanController> {
  const PengisianSolarPenerimaanView({super.key});

  void _showExitConfirmation() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieQuestion(),
        title: 'Informasi',
        message: 'Apakah anda yakin akan meninggalkan transaksi ini?',

        secondaryButtonText: 'Tidak',
        onSecondaryPressed: () => Get.back(),

        primaryButtonText: 'Ya',
        onPrimaryPressed: () {
          Get.back();
          controller.saveAndExit();
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showConfirmationDialog() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieConfirmation(),
        title: 'Konfirmasi Penyelesaian',
        message: 'Apakah Anda yakin pengisian solar sudah selesai dilakukan?',
        secondaryButtonText: 'Cek Lagi',
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: 'Ya, Selesai',
        onPrimaryPressed: () {
          Get.back();
          controller.finishTransaction();
        },
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitConfirmation();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_left, color: AppColors.primary),
            onPressed: () => _showExitConfirmation(),
          ),
          centerTitle: true,
          title: Text(
            'Pengisian Solar',
            style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.fieldBackground),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              'Pengisian Solar Sedang Berlangsung',
                              style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.fieldBackground),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                'Ringkasan Pengisian',
                                style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildDetailRow(label: 'Tanggal', value: controller.tanggal.value),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDetailRow(label: 'No. PO', value: controller.noPO.value),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Obx(() => _buildDetailRow(label: 'No. BAST', value: controller.noBast.value)),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Obx(() => _buildDetailRow(label: 'No. Polisi', value: controller.noPolisi.value)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Lottie.asset(
                AppLotties.loading,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Lanjutkan',
                      style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}