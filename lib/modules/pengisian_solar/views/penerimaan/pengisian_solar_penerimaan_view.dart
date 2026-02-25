import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/configs/app_lotties.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/widgets/dialog/dialog_flexible.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/penerimaan/pengisian_solar_penerimaan_controller.dart';

class PengisianSolarPenerimaanView extends GetView<PengisianSolarPenerimaanController> {
  const PengisianSolarPenerimaanView({super.key});

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
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
            onPressed: () => _showExitConfirmation(),
          ),
          centerTitle: true,
          title: Text(
            'Proses Pengisian',
            style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 3. MONITORING CARDS
                    _buildMonitoringSection(),
                    const SizedBox(height: 16),
                    // 2. INFO TRANSAKSI
                    _buildTransactionSummary(),
                    const SizedBox(height: 16),
                    // 1. STATUS & ANIMASI (COMPACT)
                    _buildCompactStatusCard(),
                  ],
                ),
              ),
            ),

            // 4. BUTTON ACTION
            _buildBottomAction(context),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  // 1. Kartu Ringkasan Transaksi
  Widget _buildTransactionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Info Pengiriman", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
                  Text("Tanggal: ${controller.tanggal.value}", style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCompactDetail("No. PO", controller.noPO.value),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                _buildCompactDetail("No. Dokumen", controller.noBast.value),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                _buildCompactDetail("Plat Nomor", controller.noPolisi.value, isRight: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCompactDetail(String label, String value, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium8.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 2),
        Text(value, style: AppFonts.fUrbanistBold8.copyWith(color: AppColors.darkText)),
      ],
    );
  }

  // 2. Status Card Compact (Horizontal Layout)
  Widget _buildCompactStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Animasi Kecil di Kiri
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Lottie.asset(
              AppLotties.loading,
              fit: BoxFit.contain,
              width: 40,
            ),
          ),
          const SizedBox(width: 16),

          // Teks Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lakukan Pengisian Stok...",
                  style: AppFonts.fUrbanistBold14.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "Pastikan selang terhubung dan aliran solar lancar.",
                  style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.white.withOpacity(0.9)),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Section Monitoring
  Widget _buildMonitoringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.darkText),
            const SizedBox(width: 8),
            Text("Monitoring Volume", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 1: Sounding Awal
            Expanded(
              child: _buildVolumeCard(
                title: "Sounding Awal",
                volume: controller.initialVolume.value,
                icon: Icons.history,
                color: AppColors.secondaryText,
                bgColor: Colors.white,
                borderColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(width: 12),

            // Card 2: Sensor Live
            Expanded(
              child: Obx(() => _buildVolumeCard(
                  title: "Volume Sensor",
                  volume: controller.currentVolume.value,
                  icon: Icons.sensors_rounded,
                  color: AppColors.primary, // Warna teks primary
                  bgColor: const Color(0xFFE3F2FD), // Background biru muda banget
                  borderColor: AppColors.primary.withOpacity(0.3),
                  isLive: true,
                  isLoading: controller.isRefreshingSensor.value,
                  onTap: controller.refreshSensorMonitoring,
                  lastUpdate: controller.lastUpdateSensor.value
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVolumeCard({
    required String title,
    required double volume,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    bool isLive = false,
    bool isLoading = false,
    VoidCallback? onTap,
    String? lastUpdate
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110, // Fixed height agar rapi
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(title, style: AppFonts.fUrbanistSemiBold10.copyWith(color: color)),
                  ],
                ),
                if (isLive)
                  isLoading
                      ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(color: color, strokeWidth: 2))
                      : Icon(Icons.refresh, size: 16, color: color)
              ],
            ),

            Text(
              "${TextConvertHelper().formatNumber(volume)} L",
              style: AppFonts.fUrbanistBold20.copyWith(color: isLive ? AppColors.darkText : color), // Angka lebih menonjol
            ),

            if (isLive && lastUpdate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4)
                ),
                child: Text(
                  "Update: $lastUpdate",
                  style: AppFonts.fUrbanistMedium10.copyWith(color: color, fontSize: 9),
                ),
              )
            else
              Text(
                "Data statis",
                style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey.shade400, fontSize: 9),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            offset: const Offset(0, -4),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _showConfirmationDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Selesai Pengisian',
                style: AppFonts.fUrbanistSemiBold14.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DIALOGS ---

  void _showExitConfirmation() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieQuestion(),
        title: 'Tunda Transaksi?',
        message: 'Anda akan keluar dari halaman pengisian. Transaksi akan disimpan sebagai draft.',
        secondaryButtonText: 'Batal',
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: 'Ya, Keluar',
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
        title: 'Konfirmasi Selesai',
        message: 'Pastikan proses pengisian solar dari mobil ke tangki sudah benar-benar selesai.',
        secondaryButtonText: 'Batal',
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: 'Selesai',
        onPrimaryPressed: () {
          Get.back();
          controller.finishTransaction();
        },
      ),
      barrierDismissible: false,
    );
  }
}