import 'dart:io';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/configs/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../datas/models/widgets/capture_image_detail.dart';
import '../../../helpers/separator_input_formatter.dart';
import '../controllers/penerimaan_sebelum_controller.dart';

class PenerimaanSebelumForm extends GetView<PenerimaanSebelumController> {
  const PenerimaanSebelumForm({super.key});

  // --- WIDGET HELPER: CARD WRAPPER ---
  // Digunakan untuk membungkus field agar terlihat dalam kotak rapi
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16), // Rounded halus
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(color: AppColors.secondaryText.withOpacity(0.2)),
          const SizedBox(height: 16),

          // Isi Form
          ...children,
        ],
      ),
    );
  }

  // --- BUILDER HALAMAN SCROLL ---
  Widget _buildScrollablePage(PenerimaanSebelumController ctrl, {required int stepIndex}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => _buildProgressIndicator(ctrl.currentPage.value)),
            const SizedBox(height: 20),

            if (stepIndex == 0) _buildStepOneForm(ctrl),
            if (stepIndex == 1) _buildStepTwoPhotos(ctrl),
            if (stepIndex == 2) _buildStepThreeForm(ctrl),

            const SizedBox(height: 10),
            _buildStepButton(ctrl),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int stepIndex) {
    String stepText = '';
    if (stepIndex == 0) stepText = 'Pengecekan dokumen';
    else if (stepIndex == 1) stepText = 'Foto Pengiriman';
    else stepText = 'Pemeriksaan Fisik';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            stepText,
            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // --- STEP 1: DATA PENGIRIMAN (FULL FIELD) ---
  Widget _buildStepOneForm(PenerimaanSebelumController ctrl) {
    return Column(
      children: [
        // CARD 1: Info Dasar
        _buildSectionCard(
          title: 'Data Dokumen',
          icon: Icons.description_outlined,
          children: [
            _buildTextField('Tanggal', readOnly: true, controller: ctrl.dateInputController),
            _buildTextField('Hari', readOnly: true, controller: ctrl.dayInputController),
            _buildTextField('No PO', controller: ctrl.noPoController, keyboardType: TextInputType.text, hintText: 'No. Purchase Order'),
          ],
        ),

        // CARD 2: Detail SPB
        _buildSectionCard(
          title: 'Data Pengiriman (Doc. SPB)',
          icon: Icons.local_shipping_outlined,
          children: [
            _buildTextField(
              'No. DO',
              controller: ctrl.noDoController,
              keyboardType: TextInputType.number,
              hintText: 'No. Delivery Order',
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            ),
            _buildTextField(
              'Jumlah (Ltr)',
              controller: ctrl.jumlahLtrController,
              keyboardType: TextInputType.number,
              hintText: 'Jumlah Pengiriman dalam Liter',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, SeparatorInputFormatter()],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField('Density', controller: ctrl.densityObsController, keyboardType: TextInputType.number, hintText: 'Jml Density')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Temp. Observasi', controller: ctrl.temperatureObsController, keyboardType: TextInputType.number, hintText: 'Jml Temp')),
              ],
            ),
          ],
        ),

        // CARD 3: Unit Pengangkut
        _buildSectionCard(
          title: 'Unit Pengangkut',
          icon: Icons.directions_bus_outlined,
          children: [
            _buildTextField('No Polisi', controller: ctrl.noPolisiController, keyboardType: TextInputType.text, hintText: 'No. Kendaraan Pengangkut'),
            _buildTextField('Nama Sopir', controller: ctrl.namaSopirController, keyboardType: TextInputType.text, hintText: 'Nama Supir Pengangkut'),
            _buildTextField(
              'Kapasitas Tangki Angkut (Ltr)',
              controller: ctrl.kapasitasTangkiController,
              keyboardType: TextInputType.number,
              hintText: 'Jumlah Kapasitas Tangki',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, SeparatorInputFormatter()],
            ),
          ],
        ),
      ],
    );
  }

  // --- STEP 2: FOTO PENGIRIMAN ---
  Widget _buildStepTwoPhotos(PenerimaanSebelumController ctrl) {
    return _buildSectionCard(
      title: 'Foto Pengiriman Solar',
      icon: Icons.camera_alt_outlined,
      children: [
        Text(
          'Silahkan ambil foto sesuai instruksi.',
          style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 20),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPhotoBox(ctrl: ctrl, index: 0, label: 'Dokumen SPB', assetPath: AppIcons.icPenerimaan2),
            _buildPhotoBox(ctrl: ctrl, index: 1, label: 'Tampak Depan', assetPath: AppIcons.icFrontTruck),
            _buildPhotoBox(ctrl: ctrl, index: 2, label: 'Tampak Samping', assetPath: AppIcons.icSideTruck),
          ],
        )),
      ],
    );
  }

  // --- STEP 3: PEMERIKSAAN (FULL FIELD) ---
  Widget _buildStepThreeForm(PenerimaanSebelumController ctrl) {
    return Column(
      children: [
        // CARD 1: Review Data Unit & Kualitas
        _buildSectionCard(
          title: 'Review Fisik',
          icon: Icons.checklist_rtl_rounded,
          children: [
            _buildTextField('No Polisi', controller: ctrl.noPolisiController),
            _buildTextField('Nama Sopir', controller: ctrl.namaSopirController),
            _buildTextField('Kapasitas Tangki Angkut (Ltr)', keyboardType: TextInputType.number, controller: ctrl.kapasitasTangkiController),
            Row(
              children: [
                Expanded(child: _buildTextField('Density', keyboardType: TextInputType.number, controller: ctrl.densityObsController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Tempr (Obs)', keyboardType: TextInputType.number, controller: ctrl.temperatureObsController)),
              ],
            ),
          ],
        ),

        // CARD 2: Pengukuran Tera (PENTING UNTUK KALKULASI)
        _buildSectionCard(
          title: 'Pengukuran Tera',
          icon: Icons.straighten,
          children: [
            _buildTextField(
              'Tinggi Tera SPB (mm)',
              controller: ctrl.tinggiTeraSpbController,
              keyboardType: TextInputType.number,
              hintText: 'Masukkan tinggi (mm)',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, SeparatorInputFormatter()],
            ),
            _buildTextField(
                'Tinggi Sounding Mobil (mm)',
                controller: ctrl.tinggiTeraSoundingController,
                keyboardType: TextInputType.number,
                hintText: 'Masukkan tinggi sounding (mm)',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, SeparatorInputFormatter()]
            ),
            // Field ini biasanya otomatis terisi oleh Controller listener
            _buildTextField(
                'Selisih Tinggi Tera (mm)',
                controller: ctrl.selisihTinggiTeraController,
                keyboardType: TextInputType.number,
                hintText: 'Hitung selisih (mm)',
                readOnly: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, SeparatorInputFormatter()]
            ),
          ],
        ),

        // CARD 3: Segel & Keamanan
        _buildSectionCard(
          title: 'Segel & Keamanan',
          icon: Icons.lock_outline,
          children: [
            _buildTextField('Nilai Kepekaan Tangki', controller: ctrl.nilaiKepekaanController, hintText: 'Masukkan nilai kepekaan'),
            _buildTextField('Segel Tangki Atas', controller: ctrl.segelTangkiAtasController, hintText: 'Masukkan nomor segel atas'),
            _buildTextField('Segel Tangki Bawah', controller: ctrl.segelTangkiBawahController, hintText: 'Masukkan nomor segel bawah'),

            Obx(() => _buildDropdownField(
              label: 'Kondisi Segel',
              items: const ['Baik', 'Rusak', 'Hilang'],
              selectedValue: ctrl.kondisiSegelSelected.value,
              onChanged: (newValue) {
                if (newValue != null) ctrl.kondisiSegelSelected.value = newValue;
              },
            )),
          ],
        ),
      ],
    );
  }

  // --- WIDGET PENDUKUNG (FOTO, TEXTFIELD, DROPDOWN, BUTTON) ---

  Widget _buildPhotoBox({
    required PenerimaanSebelumController ctrl,
    required int index,
    required String label,
    required String assetPath,
  }) {
    final CapturedImageDetail? imageDetail = ctrl.photoSlots[index];
    final bool hasImage = imageDetail != null;

    return Expanded(
      child: GestureDetector(
        onTap: ctrl.isTakingPhoto.value
            ? null
            : () {
          if (!hasImage) {
            ctrl.takeSpecificPhoto(index);
          } else {
            // Logic preview/delete jika ada
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
            ),
          ),
          child: hasImage
              ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(imageDetail.tempPath), fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => ctrl.removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.alertSoftRed, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 12, color: AppColors.white),
                  ),
                ),
              )
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, width: 24, height: 24, color: AppColors.secondaryText, fit: BoxFit.contain),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, {
        TextInputType keyboardType = TextInputType.text,
        bool readOnly = false,
        String? initialValue,
        TextEditingController? controller,
        String? hintText,
        List<TextInputFormatter>? inputFormatters,
        int? maxLength,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primaryText)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            keyboardType: keyboardType,
            readOnly: readOnly,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            decoration: InputDecoration(
              isDense: true,
              counterText: "",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: hintText,
              hintStyle: AppFonts.fUrbanistLight12.copyWith(color: AppColors.secondaryText),
              filled: true,
              // Jika ReadOnly warnanya beda dikit biar user tau
              fillColor: readOnly ? AppColors.backgroundGrey : AppColors.fieldBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
            ),
            style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items, required String selectedValue, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primaryText)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.fieldBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            items: items.map((v) => DropdownMenuItem(value: v, child: Text(v, style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.darkText)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton(PenerimaanSebelumController ctrl) {
    return Obx(() {
      bool isLastPage = ctrl.currentPage.value == 2;
      String buttonText = isLastPage ? 'Lanjut Pengukuran' : 'Selanjutnya';

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: ctrl.goToNextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(buttonText, style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.white)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTakingPhoto = controller.isTakingPhoto.value;
      final int currentIndex = controller.currentPage.value;

      String titleText = 'Form Penerimaan Solar';
      if (currentIndex == 1) titleText = 'Foto Dokumen SPB';

      return WillPopScope(
        onWillPop: isTakingPhoto ? () async => false : () async {
          if (controller.currentPage.value > 0) {
            controller.pageController.previousPage(duration: const Duration(milliseconds: 800), curve: Curves.easeOut);
            return false;
          }
          return true;
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.backgroundGrey, // Background Abu agar Card menonjol
              appBar: AppBar(
                title: Text(titleText, style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary)),
                centerTitle: true,
                backgroundColor: AppColors.backgroundGrey,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                  onPressed: () {
                    if (isTakingPhoto) return;
                    if (controller.currentPage.value > 0) {
                      controller.pageController.previousPage(duration: const Duration(milliseconds: 800), curve: Curves.easeOut);
                    } else {
                      Get.back();
                    }
                  },
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: controller.onPageChanged,
                      children: [
                        _buildScrollablePage(controller, stepIndex: 0),
                        _buildScrollablePage(controller, stepIndex: 1),
                        _buildScrollablePage(controller, stepIndex: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isTakingPhoto)
              Positioned.fill(
                child: Container(
                  color: AppColors.darkText.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text('Membuka Kamera...', style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.white)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}