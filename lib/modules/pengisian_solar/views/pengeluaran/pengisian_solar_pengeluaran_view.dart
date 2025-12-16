import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/configs/app_lotties.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:e_fuel/modules/pengisian_solar/controllers/pengeluaran/pengisian_solar_pengeluaran_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/widgets/dialog/dialog_flexible.dart';
import 'package:lottie/lottie.dart';

class PengisianSolarPengeluaranView extends GetView<PengisianSolarPengeluaranController> {
  const PengisianSolarPengeluaranView({super.key});

  void _showPengisianDialog() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieConfirmation(),
        title: 'Informasi',
        message: 'Pengisian bahan bakar solar sudah dapat dilakukan sekarang!',
        primaryColor: AppColors.primaryOrange,

        primaryButtonText: 'Mengerti',
        onPrimaryPressed: () {
          Get.back();
        },
        secondaryButtonText: null,
        onSecondaryPressed: null,
      ),
      barrierDismissible: false,
    );
  }

  void _showExitConfirmation() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieQuestion(),
        title: 'Informasi',
        message: 'Apakah anda yakin akan meninggalkan transaksi ini?',
        primaryColor: AppColors.primaryOrange,

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
        primaryColor: AppColors.primaryOrange,
        secondaryColor: AppColors.secondaryOrange,

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == false || Get.isDialogOpen == null) {
        _showPengisianDialog();
      }
    });

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
            icon: const Icon(Icons.keyboard_arrow_left, color: AppColors.primaryOrange),
            onPressed: () => _showExitConfirmation(),
          ),
          centerTitle: true,
          title: Text(
            'Pengeluaran Solar',
            style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange),
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
                      const SizedBox(height: 5),

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
                                "Doc. ${controller.noDoc.value}",
                                style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryOrange),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildDetailRow(label: 'Unit. IO', value: controller.unitIO.value),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDetailRow(label: 'No. IO', value: controller.noIO.value),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildDetailRow(label: 'Tanggal', value: controller.tanggal.value),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Obx(() => _buildDetailRow(label: 'Jumlah Solar', value: "${controller.jumlahSolar.value} Ltr")),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Obx(() => _buildDetailRow(label: 'No. Polisi', value: controller.noPolisi.value)),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Obx(() => _buildDetailRow(label: 'Nama Supir', value: controller.namaSupir.value)),
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
                AppLotties.loadingPengeluaran,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),

              // Tombol Aksi
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Selanjutnya',
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