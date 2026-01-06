import 'dart:io';

import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:e_fuel/modules/pengisian_solar/controllers/pengeluaran/pengisian_solar_pengeluaran_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/widgets/dialog/dialog_flexible.dart';

class PengisianSolarPengeluaranView extends GetView<PengisianSolarPengeluaranController> {
  const PengisianSolarPengeluaranView({super.key});

  String _getLabelNoPolisi() {
    String tipe = controller.tipeUnit.value.toUpperCase();
    if (tipe == 'AB' || tipe == 'GS') return "No. Unit";
    return "No. Polisi";
  }

  String _getLabelNamaSupir() {
    String tipe = controller.tipeUnit.value.toUpperCase();
    if (tipe == 'AB') return "Nama Operator";
    if (tipe == 'GS') return "Pengambil Solar";
    return "Nama Supir";
  }

  String _getLabelFotoSupir() {
    String tipe = controller.tipeUnit.value.toUpperCase();
    if (tipe == 'AB') return "Foto Operator";
    if (tipe == 'GS') return "Foto Pengambil Solar";
    return "Foto Supir";
  }

  void _showExitConfirmation() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieQuestion(),
        title: 'Konfirmasi',
        message: 'Apakah anda yakin akan membatalkan transaksi ini? Data yang belum tersimpan akan hilang.',
        primaryColor: AppColors.primaryOrange,
        secondaryButtonText: 'Lanjut Transaksi',
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: 'Keluar',
        onPrimaryPressed: () {
          Get.back();
          controller.saveAndExit();
        },
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Header: Doc No & Tanggal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, size: 16, color: AppColors.primaryOrange),
                    const SizedBox(width: 6),
                    Text(
                      "Doc. ${controller.noDoc.value}",
                      style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryOrange),
                    ),
                  ],
                ),
                Text(
                  controller.tanggal.value,
                  style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Highlight: Jumlah Solar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.fieldBackground),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text("Estimasi Solar Dikeluarkan", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        "${controller.jumlahSolar.value} Liter",
                        style: AppFonts.fUrbanistBold20.copyWith(color: AppColors.primaryOrange),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Detail Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem("Kode Unit", controller.unitIO.value, Icons.local_shipping_outlined),
                          const SizedBox(height: 16),
                          Obx(() => _buildInfoItem(_getLabelNoPolisi(), controller.noPolisi.value, Icons.featured_play_list_outlined)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem("No. IO", controller.noIO.value, Icons.confirmation_number_outlined),
                          const SizedBox(height: 16),
                          Obx(() => _buildInfoItem(_getLabelNamaSupir(), controller.namaSupir.value, Icons.person_outline)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryText.withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText)),
              const SizedBox(height: 2),
              Text(value, style: AppFonts.fUrbanistSemiBold10.copyWith(color: AppColors.darkText)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bukti Foto (Wajib)",
          style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
          children: [
            _buildPhotoItem(
              label: _getLabelFotoSupir(),
              imageFile: controller.fotoSupir.value,
              onTap: () => controller.takePhoto(true),
              onRemove: () => controller.removePhoto(true),
            ),
            const SizedBox(width: 16),
            _buildPhotoItem(
              label: "Foto Unit/Truk",
              imageFile: controller.fotoTruk.value,
              onTap: () => controller.takePhoto(false),
              onRemove: () => controller.removePhoto(false),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildPhotoItem({
    required String label,
    required File? imageFile,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    bool hasImage = imageFile != null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120, // Sedikit lebih tinggi agar proporsional
          decoration: BoxDecoration(
            color: hasImage ? AppColors.white : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImage ? AppColors.primaryOrange : AppColors.secondaryText.withOpacity(0.2),
              width: hasImage ? 1.5 : 1,
              style: hasImage ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: hasImage
              ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
              // Gradient Overlay untuk teks label
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                  ),
                  child: Text(
                    label,
                    style: AppFonts.fUrbanistSemiBold10.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Delete Button
              Positioned(
                top: 6, right: 6,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.alertSoftRed,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              )
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryOrange, size: 24),
              ),
              const SizedBox(height: 10),
              Text("Ambil Foto", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
              Text(label, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryText)),
            ],
          ),
        ),
      ),
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
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20),
            onPressed: () => _showExitConfirmation(),
          ),
          centerTitle: true,
          title: Text(
            'Pengisian Solar',
            style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Summary Card
                      _buildSummaryCard(),

                      const SizedBox(height: 16),

                      // Section 2: Photo Upload
                      _buildPhotoSection(),

                      const SizedBox(height: 20), // Spacing bottom
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.finishTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Proses Verifikasi',
                      style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
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