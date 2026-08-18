import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../controllers/pengembalian_proses_controller.dart';

class PengembalianProsesView extends GetView<PengembalianProsesController> {
  const PengembalianProsesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text('Proses Pengembalian',
            style: AppFonts.fUrbanistBold18
                .copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.primary, size: 20),
            onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardWrapper(
              title: 'Informasi Transaksi & Unit',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStaticField('Tanggal Transaksi', _formatDate(controller.data.createdAt))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStaticField('Nama Unit', controller.data.namaUnit)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStaticField('No. Transaksi', controller.data.noDoc)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStaticField('No. IO', controller.data.noIo)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStaticField('Tipe Unit', controller.data.tipeUnitIo),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _buildCardWrapper(
              title: 'Volume Solar (${controller.data.satuan})',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStaticField('Liter Pengambilan', controller.data.liter.toString())),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStaticField('Aktual Pengisian', controller.data.aktualLiter.toString())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStaticField('Sisa Liter (Tercatat)', controller.data.varianLiter.toString(), isHighlighted: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildCardWrapper(
              title: 'Input Pengembalian',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Varian Liter Dikembalikan', controller.varianLiterController, isNumber: true),
                  const SizedBox(height: 16),
                  _buildInputField('Keterangan', controller.keteranganController, isNumber: false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _buildCardWrapper(
              title: 'Lampiran Foto',
              child: _buildCameraBox(),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Text(
                  'Submit Pengembalian',
                  style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildCardWrapper({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStaticField(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFFF0F5FF) : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isHighlighted ? AppColors.primaryOrange.withOpacity(0.3) : Colors.transparent),
          ),
          child: Text(
            value,
            style: AppFonts.fUrbanistMedium14.copyWith(
              color: isHighlighted ? AppColors.primaryOrange : AppColors.primaryText,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController txtController, {required bool isNumber}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: txtController,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.primaryText),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: isNumber ? '0' : 'Masukkan $label',
              hintStyle: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraBox() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPhotoBox(1, controller.foto1Path, 'Foto Alat Berat / Unit')),
            const SizedBox(width: 12),
            Expanded(child: _buildPhotoBox(2, controller.foto2Path, 'Foto Tangki')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildPhotoBox(3, controller.foto3Path, 'Foto Bukti Pengembalian')),
            const SizedBox(width: 12),
            Expanded(child: const SizedBox()), // Empty slot for grid
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoBox(int index, RxnString pathObs, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Obx(() {
          final path = pathObs.value;
          if (path != null) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(path),
                    width: double.infinity,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => controller.removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            );
          }

          return GestureDetector(
            onTap: () => controller.pickImage(index, title),
            child: Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.primaryOrange, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text('Ambil Foto', style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
