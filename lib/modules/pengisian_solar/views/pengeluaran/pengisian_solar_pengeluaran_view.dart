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

  void _showExitConfirmation() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieQuestion(),
        title: 'Konfirmasi Keluar',
        message: 'Data yang belum disubmit akan hilang. Yakin ingin keluar?',
        primaryColor: AppColors.primaryOrange,
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

  // --- WIDGETS ---
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
          // Header Card (Tetap Sama)
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
                      style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryOrange),
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

          // Info Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Grid Unit/Supir (Tetap Sama)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem("Nama Unit", controller.unitIO.value, Icons.local_shipping_outlined),
                          const SizedBox(height: 8),
                          Obx(() => _buildInfoItem(_getLabelNoPolisi(), controller.noPolisi.value, Icons.featured_play_list_outlined)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            if (controller.unitIO.value.isNotEmpty && controller.unitIO.value == "TAMU") return _buildInfoItem("Cost Center", controller.costCenter.value, Icons.confirmation_number_outlined);
                            return _buildInfoItem("No. IO", controller.noIO.value, Icons.confirmation_number_outlined);
                          }),
                          const SizedBox(height: 8),
                          Obx(() => _buildInfoItem(_getLabelNamaSupir(), controller.namaSupir.value, Icons.person_outline)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),

                Obx(() {
                  if (controller.isRefreshingSensor.value) return const SizedBox.shrink();
                  if (controller.isSensorApiActive.value) return const SizedBox.shrink();
                  if (controller.messageResponse.value.isEmpty) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.messageResponse.value,
                            style: AppFonts.fUrbanistMedium10.copyWith(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Aktual Pengeluaran Solar (Liter)", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.aktualSolarC,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      readOnly: false,
                      decoration: InputDecoration(
                        hintText: "0",
                        filled: true,
                        fillColor: AppColors.alertSoftOrangeSecond,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE3E8F0))),
                        suffixIcon: Obx(() => controller.isManualInput.value 
                            ? const SizedBox.shrink() 
                            : IconButton(
                          icon: controller.isRefreshingSensor.value
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(Icons.sync, color: controller.isSensorApiActive.value ? Colors.green : AppColors.primary),
                          onPressed: controller.refreshSensorMonitoring,
                          tooltip: "Tarik Data Sensor",
                        )),
                      ),
                      style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.darkText),
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.tipeUnit.value.toUpperCase() == 'GS') {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // KIRI: ESTIMASI
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Estimasi (Liter)", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
                                const SizedBox(height: 8),
                                _buildReadOnlyField(controller.estimasiSolarC),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // KANAN: VARIAN
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Sisa Solar (Liter)", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
                                const SizedBox(height: 8),
                                _buildReadOnlyField(controller.varianSolarC),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk Field ReadOnly agar codingan lebih rapi
  Widget _buildReadOnlyField(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.secondaryText),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
    return Obx(() {
      if (controller.isManualInput.value) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Wajib Foto",
            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // FOTO DISPENSER
              _buildPhotoItem(
                label: "Angka Meter Dispenser",
                icon: Icons.gas_meter_sharp,
                imageFile: controller.fotoDispenser.value,
                onTap: () => controller.takePhoto(false), // False = Dispenser
                onRemove: () => controller.removePhoto(false),
              ),
              const SizedBox(width: 16),
              // FOTO SUPIR
              _buildPhotoItem(
                label: controller.namaSupir.value,
                icon: Icons.person_4_rounded,
                imageFile: controller.fotoSupir.value,
                onTap: () => controller.takePhoto(true), // True = Supir
                onRemove: () => controller.removePhoto(true),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildPhotoItem({
    required String label,
    required IconData icon,
    required File? imageFile,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    bool hasImage = imageFile != null;
    return Expanded(
      child: GestureDetector(
        onTap: controller.isTakingPhoto.value ? null : onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: hasImage ? AppColors.white : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImage ? AppColors.primaryOrange : AppColors.secondaryText.withOpacity(0.2),
              width: hasImage ? 1.5 : 1,
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
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                  ),
                  child: Text(
                    label,
                    style: AppFonts.fUrbanistSemiBold10.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
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
                child: Icon(icon, color: AppColors.primaryOrange, size: 28),
              ),
              const SizedBox(height: 10),
              Text("Ambil Foto", style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(label, textAlign: TextAlign.center, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryText)),
              ),
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
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(),
                          const SizedBox(height: 20),
                          _buildPhotoSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Footer Button
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.showSubmitConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Submit Data',
                          style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Loading Indicator Overlay when taking photo
              Obx(() => controller.isTakingPhoto.value
                  ? Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
                  ))
                  : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}