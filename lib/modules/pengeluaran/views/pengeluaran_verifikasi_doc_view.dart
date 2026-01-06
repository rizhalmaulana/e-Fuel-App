import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
import '../controllers/pengeluaran_verifikasi_doc_controller.dart';

class PengeluaranVerifikasiDocView extends GetView<PengeluaranVerifikasiDocController> {
  const PengeluaranVerifikasiDocView({super.key});

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

  String _getRoleName() {
    String tipe = controller.tipeUnit.value.toUpperCase();
    if (tipe == 'AB') return "Operator";
    if (tipe == 'GS') return "Pengambil Solar";
    return "Supir";
  }

  String _getLabelKmPengisian() {
    String tipe = controller.tipeUnit.value.toUpperCase();
    if (tipe == 'AB') return "Hm Pengisian";
    if (tipe == 'GS') return "Tanggal Pengisian";
    return "Km Pengisian";
  }

  String _getValueKmPengisian() {
    String tipe = controller.tipeUnit.value.toUpperCase();
    if (tipe == 'GS') {
      return controller.tanggal.value; // Jika GS, tampilkan Tanggal Transaksi
    }
    return controller.kmPengisian.value; // Jika KD/AB, tampilkan Angka KM/HM
  }

  Widget _buildDashedDivider() {
    return Row(children: List.generate(150 ~/ 5, (index) => Expanded(child: Container(color: index % 2 == 0 ? Colors.transparent : AppColors.secondaryText.withOpacity(0.3), height: 1))));
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: isBold ? AppFonts.fUrbanistBold12.copyWith(color: AppColors.darkText) : AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText))),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoCard({required List<Widget> children}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))], border: Border.all(color: AppColors.fieldBackground)), child: Column(children: children));
  }

  Widget _buildDispenserPhotoBox() {
    return Obx(() {
      final CapturedImageDetail? imageDetail = controller.photoDispenser.value;
      final bool hasImage = imageDetail != null;

      return GestureDetector(
        onTap: controller.isTakingPhoto.value ? null : () {
          if (!hasImage) controller.takeDispenserPhoto();
        },
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: hasImage ? AppColors.white : AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hasImage ? AppColors.primaryOrange : AppColors.secondaryText.withOpacity(0.3)),
          ),
          child: hasImage
              ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.file(File(imageDetail.tempPath), fit: BoxFit.cover)),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: controller.removeDispenserImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.alertSoftRed, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: AppColors.white),
                  ),
                ),
              ),
              Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11))), child: Text("Foto Dispenser Pom", textAlign: TextAlign.center, style: AppFonts.fUrbanistSemiBold12.copyWith(color: Colors.white))))
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]), child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryOrange, size: 32)),
              const SizedBox(height: 12),
              Text("Ambil Foto Dispenser", style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primaryOrange)),
              Text("Pastikan angka liter terlihat jelas", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
            ],
          ),
        ),
      );
    });
  }

  // --- WIDGET STEP 1: FOTO & SUMMARY ---
  Widget _buildStep1SummaryAndPhoto() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Summary Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Doc. ${controller.noDoc.value}", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.black)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(controller.tanggal.value, style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryOrange))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDashedDivider(),
                const SizedBox(height: 16),
                _buildInfoRow("No. IO", controller.noIO.value),
                _buildInfoRow("Nama Unit", controller.unitIO.value),

                Obx(() => _buildInfoRow(_getLabelNoPolisi(), controller.noPolisi.value)),
                Obx(() => _buildInfoRow(_getLabelNamaSupir(), controller.namaSupir.value)),
                Obx(() => _buildInfoRow(_getLabelKmPengisian(), _getValueKmPengisian())),

                const SizedBox(height: 12),

                // [INPUT FIELD] Aktual Pengeluaran Solar
                Text("Aktual Pengeluaran Solar (Ltr)", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryOrange)),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.aktualSolarC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText),
                  decoration: InputDecoration(
                    hintText: "0",
                    isDense: true,
                    suffixText: "Liter",
                    suffixStyle: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText),
                    filled: true,
                    fillColor: AppColors.fieldBackground,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryOrange)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Photo Section
          Text('Bukti Pengisian', style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText)),
          const SizedBox(height: 4),
          Text('Foto dispenser pom wajib diisi.', style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 12),
          _buildDispenserPhotoBox(),
        ],
      ),
    );
  }

  // --- WIDGET STEP 2 (Sama) ---
  Widget _buildStep2Warehouse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderInfoCard(children: [
            Text("Doc. ${controller.noDoc.value}", style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.black)),
            const SizedBox(height: 12), _buildDashedDivider(), const SizedBox(height: 12),
            _buildInfoRow("Nama Verifikator", controller.userName.value, isBold: true),
            _buildInfoRow("Jabatan", controller.userJabatan.value),
          ]),
          const SizedBox(height: 24),
          Text("Catatan Verifikasi", style: AppFonts.fUrbanistSemiBold14), const SizedBox(height: 8),
          TextField(controller: controller.warehouseNoteController, maxLines: 1, style: AppFonts.fUrbanistRegular12, decoration: InputDecoration(hintText: "Tambahkan catatan jika perlu...", filled: true, fillColor: AppColors.fieldBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Tanda Tangan Gudang", style: AppFonts.fUrbanistSemiBold14), GestureDetector(onTap: () => controller.clearSignature(controller.warehouseSignatureController), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.alertSoftRed.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text("Hapus", style: AppFonts.fUrbanistSemiBold10.copyWith(color: AppColors.alertSoftRed))))]),
          const SizedBox(height: 8),
          Container(height: 200, decoration: BoxDecoration(color: AppColors.fieldBackground.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.secondaryText.withOpacity(0.3), width: 1)), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Signature(controller: controller.warehouseSignatureController, backgroundColor: Colors.transparent))),
        ],
      ),
    );
  }

  // --- WIDGET STEP 3: FINAL SIGNATURE (Dynamic Label) ---
  Widget _buildStep3Driver() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderInfoCard(children: [
            Text("Doc. ${controller.noDoc.value}", style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.black)),
            const SizedBox(height: 12), _buildDashedDivider(), const SizedBox(height: 12),
            Obx(() => _buildInfoRow(_getLabelNamaSupir(), controller.namaSupir.value, isBold: true)),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Obx(() => Text("Tanda Tangan ${_getRoleName()}", style: AppFonts.fUrbanistSemiBold14)),
            GestureDetector(onTap: () => controller.clearSignature(controller.driverSignatureController), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.alertSoftRed.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text("Hapus", style: AppFonts.fUrbanistSemiBold10.copyWith(color: AppColors.alertSoftRed))))
          ]),
          const SizedBox(height: 12),
          Container(height: 200, decoration: BoxDecoration(color: AppColors.fieldBackground.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.secondaryText.withOpacity(0.3), width: 1)), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Signature(controller: controller.driverSignatureController, backgroundColor: Colors.transparent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTakingPhoto = controller.isTakingPhoto.value;
      return WillPopScope(
        onWillPop: isTakingPhoto ? () async => false : () async { if (controller.currentPage.value > 0) { controller.prevPage(); return false; } return true; },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.white,
              appBar: AppBar(
                title: Obx(() {
                  String title = "Verifikasi Dokumen";
                  if (controller.currentPage.value == 1) title = "Tanda Tangan Gudang";
                  if (controller.currentPage.value == 2) title = "Tanda Tangan ${_getRoleName()}";
                  return Text(title, style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange));
                }),
                centerTitle: true, backgroundColor: AppColors.white, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20), onPressed: controller.prevPage),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller.pageController, physics: const NeverScrollableScrollPhysics(), onPageChanged: controller.onPageChanged,
                      children: [
                        _buildStep1SummaryAndPhoto(),
                        _buildStep2Warehouse(),
                        _buildStep3Driver(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
                        onPressed: controller.nextPage,
                        child: Obx(() => Text(controller.currentPage.value == 2 ? "Submit Dokumen" : "Selanjutnya", style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white))),
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (isTakingPhoto) Positioned.fill(child: Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)))),
          ],
        ),
      );
    });
  }
}
