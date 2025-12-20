import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
import '../controllers/pengeluaran_verifikasi_doc_controller.dart';

class PengeluaranVerifikasiDocView
    extends GetView<PengeluaranVerifikasiDocController> {
  const PengeluaranVerifikasiDocView({super.key});

  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
          150 ~/ 5,
          (index) => Expanded(
                child: Container(
                  color: index % 2 == 0
                      ? Colors.transparent
                      : AppColors.secondaryText.withOpacity(0.3),
                  height: 1,
                ),
              )),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.fUrbanistRegular12
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: isBold
                  ? AppFonts.fUrbanistBold12.copyWith(color: AppColors.darkText)
                  : AppFonts.fUrbanistSemiBold12
                      .copyWith(color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.fUrbanistRegular12
                .copyWith(color: AppColors.primaryOrange),
          ),
          Text(
            value,
            style: isBold
                ? AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)
                : AppFonts.fUrbanistSemiBold12
                    .copyWith(color: AppColors.darkText),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: AppColors.fieldBackground),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildPhotoBox({
    required int index,
    required String label,
    required IconData iconData,
  }) {
    final CapturedImageDetail? imageDetail = controller.photoSlots[index];
    final bool hasImage = imageDetail != null;

    return Expanded(
      child: GestureDetector(
        onTap: controller.isTakingPhoto.value
            ? null
            : () {
                if (!hasImage) {
                  controller.takeSpecificPhoto(index);
                }
              },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondaryText.withOpacity(0.3),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        File(imageDetail.tempPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.alertSoftRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.white),
                        ),
                      ),
                    )
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconData, size: 28, color: AppColors.secondaryText),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppFonts.fUrbanistRegular10
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

// --- WIDGET STEP 1: FOTO & SUMMARY ---
  Widget _buildStep1PhotoAndSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Section
          Text(
            'Foto Bukti Pengeluaran',
            style:
                AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 4),
          Text(
            'Silahkan ambil foto sesuai instruksi.',
            style: AppFonts.fUrbanistRegular12
                .copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 20),

          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPhotoBox(
                    index: 0,
                    label: 'Speedometer Pom',
                    iconData: Icons.receipt_long_outlined),
                _buildPhotoBox(
                    index: 1,
                    label: 'Tampak Depan',
                    iconData: Icons.local_shipping_outlined),
                _buildPhotoBox(
                    index: 2,
                    label: 'Tampak Samping',
                    iconData: Icons.local_shipping),
              ],
            );
          }),
          const SizedBox(height: 32),

          // Summary Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Doc. ${controller.noDoc.value}",
                  style:
                      AppFonts.fUrbanistBold16.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 16),
                _buildDashedDivider(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                          "Hari, Tanggal", controller.tanggal.value),
                      _buildSummaryRow("No. IO", controller.noIO.value),
                      _buildSummaryRow("Nama Unit", controller.unitIO.value),
                      _buildSummaryRow("No. Polisi", controller.noPolisi.value),
                      _buildSummaryRow(
                          "Nama Sopir", controller.namaSupir.value),
                      _buildSummaryRow(
                          "Km Pengisian", controller.kmPengisian.value),
                      _buildSummaryRow("Jumlah Pengisian (Ltr)",
                          controller.jumlahSolar.value,
                          isBold: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET STEP 2: GUDANG SIGNATURE ---
  Widget _buildStep2Warehouse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderInfoCard(
            children: [
              Text(
                "Doc. ${controller.noDoc.value}",
                style:
                    AppFonts.fUrbanistBold16.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 12),
              _buildDashedDivider(),
              const SizedBox(height: 12),
              _buildInfoRow("Nama Verifikator", controller.userName.value,
                  isBold: true),
              _buildInfoRow("Jabatan", controller.userJabatan.value),
            ],
          ),

          const SizedBox(height: 24),

          // Catatan Input
          Text("Catatan Verifikasi", style: AppFonts.fUrbanistSemiBold14),
          const SizedBox(height: 8),
          TextField(
            controller: controller.warehouseNoteController,
            maxLines: 1,
            style: AppFonts.fUrbanistRegular12,
            decoration: InputDecoration(
              hintText: "Tambahkan catatan jika perlu...",
              hintStyle: AppFonts.fUrbanistRegular12
                  .copyWith(color: AppColors.secondaryText),
              filled: true,
              fillColor: AppColors.fieldBackground,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primaryOrange, width: 1),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Signature Pad Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tanda Tangan Gudang", style: AppFonts.fUrbanistSemiBold14),
              GestureDetector(
                onTap: () => controller
                    .clearSignature(controller.warehouseSignatureController),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.alertSoftRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    "Hapus",
                    style: AppFonts.fUrbanistSemiBold10
                        .copyWith(color: AppColors.alertSoftRed),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),

          // Signature Pad Area
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.fieldBackground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.secondaryText.withOpacity(0.3), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Signature(
                controller: controller.warehouseSignatureController,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Area Tanda Tangan",
                style: AppFonts.fUrbanistRegular10
                    .copyWith(color: AppColors.secondaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET STEP 3: DRIVER SIGNATURE ---
  Widget _buildStep3Driver() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Info
          _buildHeaderInfoCard(
            children: [
              Text(
                "Doc. ${controller.noDoc.value}",
                style:
                    AppFonts.fUrbanistBold16.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 12),
              _buildDashedDivider(),
              const SizedBox(height: 12),
              _buildInfoRow("Nama Lengkap", controller.namaSupir.value,
                  isBold: true),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tanda Tangan Supir", style: AppFonts.fUrbanistSemiBold14),
              GestureDetector(
                onTap: () => controller
                    .clearSignature(controller.driverSignatureController),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.alertSoftRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    "Hapus",
                    style: AppFonts.fUrbanistSemiBold10
                        .copyWith(color: AppColors.alertSoftRed),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.fieldBackground.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.secondaryText.withOpacity(0.3), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Signature(
                    controller: controller.driverSignatureController,
                    backgroundColor: Colors.transparent,
                  ),
                  Center(
                    child: Text(
                      "Tanda Tangan Supir Disini",
                      style: AppFonts.fUrbanistRegular12.copyWith(
                          color: AppColors.secondaryText.withOpacity(0.3)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTakingPhoto = controller.isTakingPhoto.value;

      return WillPopScope(
        onWillPop: isTakingPhoto
            ? () async => false
            : () async {
                if (controller.currentPage.value > 0) {
                  controller.prevPage();
                  return false;
                }
                return true;
              },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.white,
              appBar: AppBar(
                title: Obx(() {
                  // Dynamic Title
                  String title = "Foto & Verifikasi";
                  if (controller.currentPage.value == 1) {
                    title = "Verifikasi Gudang";
                  }

                  if (controller.currentPage.value == 2) {
                    title = "Tanda Tangan Supir";
                  }

                  return Text(
                    title,
                    style: AppFonts.fUrbanistBold18
                        .copyWith(color: AppColors.primaryOrange),
                  );
                }),
                centerTitle: true,
                backgroundColor: AppColors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: AppColors.primaryOrange, size: 20),
                  onPressed: controller.prevPage,
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: controller.onPageChanged,
                      children: [
                        _buildStep1PhotoAndSummary(), // Step 1: Foto + Summary
                        _buildStep2Warehouse(), // Step 2: Gudang Signature
                        _buildStep3Driver(), // Step 3: Driver Signature
                      ],
                    ),
                  ),

                  // Bottom Buttons Area
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Obx(() {
                      if (controller.currentPage.value == 0) {
                        return Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.alertSoftRed,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    elevation: 0,
                                  ),
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    "Batal",
                                    style: AppFonts.fUrbanistBold16
                                        .copyWith(color: AppColors.white),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                onPressed: controller.nextPage,
                                child: Text(
                                  "Selanjutnya",
                                  style: AppFonts.fUrbanistBold16
                                      .copyWith(color: AppColors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        String label = controller.currentPage.value == 2
                            ? "Submit Dokumen"
                            : "Selanjutnya";

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: controller.nextPage,
                            child: Text(
                              label,
                              style: AppFonts.fUrbanistBold16
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                        );
                      }
                    }),
                  )
                ],
              ),
            ),

// Loading overlay saat ambil foto
            if (isTakingPhoto)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryOrange),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
