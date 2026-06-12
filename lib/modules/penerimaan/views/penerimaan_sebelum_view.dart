import 'dart:io';

import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/configs/app_icons.dart';
import 'package:e_fuel/helpers/decimal_input_formatter.dart';
import 'package:e_fuel/helpers/separator_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../datas/models/widgets/capture_image_detail.dart';
import '../../../helpers/text_convert_helper.dart';
import '../controllers/penerimaan_sebelum_controller.dart';

class PenerimaanSebelumView extends GetView<PenerimaanSebelumController> {
  const PenerimaanSebelumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTakingPhoto = controller.isTakingPhoto.value;
      final int currentIndex = controller.currentPage.value;

      String titleText = 'Form Penerimaan Solar';
      if (currentIndex == 1) titleText = 'Foto Dokumen SPB';

      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (isTakingPhoto) return;

          if (controller.currentPage.value > 0) {
            controller.pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.white, // Pastikan background putih
              appBar: _buildAppBar(context, titleText, isTakingPhoto),
              body: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: controller.onPageChanged,
                      children: [
                        _buildScrollablePage(stepIndex: 0),
                        _buildScrollablePage(stepIndex: 1), // Halaman Foto
                        _buildScrollablePage(stepIndex: 2),
                      ],
                    ),
                  ),
                  _buildBottomButtonSection(context), // Tombol Fixed di Bawah
                ],
              ),
            ),
            if (isTakingPhoto) _buildLoadingOverlay(),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title, bool isTakingPhoto) {
    return AppBar(
      title: Text(
        title,
        style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary),
      ),
      centerTitle: true,
      backgroundColor: AppColors.white,
      // Background putih
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
        onPressed: () {
          if (isTakingPhoto) return;
          if (controller.currentPage.value > 0) {
            controller.pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.darkText.withAlpha(180),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollablePage({required int stepIndex}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stepIndex == 0) _buildStepOneForm(),
          if (stepIndex == 1) _buildStepTwoPhotos(),
          if (stepIndex == 2) _buildStepThreeForm(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomButtonSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        // Shadow untuk memisahkan area tombol dengan konten (juga dipertegas)
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            offset: const Offset(0, -4),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: _buildStepButton(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // Jarak antar card diperbesar sedikit
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        // UPDATE: Shading dipertegas agar kontras dengan background putih
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            // Opacity dinaikkan (lebih gelap)
            blurRadius: 15,
            // Blur lebih luas
            offset: const Offset(0, 6),
            // Offset lebih ke bawah
            spreadRadius: 1, // Sedikit menyebar
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppFonts.fUrbanistBold16.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(color: AppColors.secondaryText.withOpacity(0.15)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDecimalTextField(
      String label, TextEditingController controller, String hint) {
    return _buildTextField(
      label,
      controller: controller,
      hintText: hint,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        DecimalInputFormatter(),
      ],
    );
  }

  // --- STEP 1 FORM ---
  Widget _buildStepOneForm() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Data Dokumen',
          icon: Icons.description_outlined,
          children: [
            _buildTextField('Tanggal',
                readOnly: true, controller: controller.dateInputController),
            _buildTextField('Hari',
                readOnly: true, controller: controller.dayInputController),
            _buildTextField('No. PO',
                controller: controller.noPoController,
                keyboardType: TextInputType.number,
                hintText: 'No. Purchase Order',
                maxLength: 15,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ]
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Data Pengiriman (Doc. SPB)',
          icon: Icons.local_shipping_outlined,
          children: [
            _buildTextField(
              'No. DO',
              controller: controller.noDoController,
              keyboardType: TextInputType.number,
              hintText: 'No. Delivery Order',
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            _buildTextField(
              'Jumlah (Ltr)',
              controller: controller.jumlahLtrController,
              keyboardType: TextInputType.number,
              hintText: 'Jumlah Pengiriman dalam Liter',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                DecimalInputFormatter(),
                SeparatorInputFormatter(),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: _buildDecimalTextField('Density',
                        controller.densityObsController, 'Jml Density')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildDecimalTextField('Temp. Observasi',
                        controller.temperatureObsController, 'Jml Temp')),
              ],
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Unit Pengangkut',
          icon: Icons.directions_bus_outlined,
          children: [
            _buildTextField('No Polisi',
                controller: controller.noPolisiController,
                hintText: 'No. Kendaraan Pengangkut',
                keyboardType: TextInputType.text,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ]),
            _buildTextField('Nama Sopir',
                controller: controller.namaSopirController,
                hintText: 'Nama Supir Pengangkut',
                keyboardType: TextInputType.text,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ]),
            _buildTextField(
              'Kapasitas Tangki Angkut (Ltr)',
              controller: controller.kapasitasTangkiController,
              keyboardType: TextInputType.number,
              hintText: 'Jumlah Kapasitas Tangki',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                SeparatorInputFormatter(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- STEP 2 PHOTOS ---
  Widget _buildStepTwoPhotos() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Dokumentasi SPB',
          icon: Icons.camera_enhance,
          children: [
            _buildPhotoBox(
              index: 0,
              label: 'Dokumen SPB (Wajib Terbaca)',
              assetPath: AppIcons.icDokumenSPB,
              isFullWidth: true, // Diubah true agar lebih besar
            ),
            const SizedBox(height: 12),

            // Foto Mobil (Side by Side)
            Row(
              children: [
                Expanded(
                    child: _buildPhotoBox(
                        index: 1,
                        label: 'Tampak Depan',
                        assetPath: AppIcons.icFrontTruck)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildPhotoBox(
                        index: 2,
                        label: 'Tampak Samping',
                        assetPath: AppIcons.icSideTruck)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- STEP 3 FORM ---
  Widget _buildStepThreeForm() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Data Pengirim',
          icon: Icons.checklist_rtl_rounded,
          children: [
            _buildTextField('No Polisi',
                controller: controller.noPolisiController),
            _buildTextField('Nama Sopir',
                controller: controller.namaSopirController),
            _buildDecimalTextField('Kapasitas Tangki Angkut (Ltr)',
                controller.kapasitasTangkiController, 'Jumlah Kapasitas'),
            Row(
              children: [
                Expanded(
                    child: _buildDecimalTextField(
                        'Density', controller.densityObsController, '0.0')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildDecimalTextField('Tempr (Obs)',
                        controller.temperatureObsController, '0.0')),
              ],
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Pemeriksaan',
          icon: Icons.straighten,
          children: [
            _buildDecimalTextField('Tinggi Tera di SPB (mm)',
                controller.tinggiTeraSpbController, 'Masukkan tinggi (mm)'),
            _buildDecimalTextField(
                'Tinggi Sounding Mobil Solar (mm)',
                controller.tinggiTeraSoundingController,
                'Masukkan tinggi sounding (mm)'),
            _buildTextField('Selisih Tinggi Tera (mm)',
                controller: controller.selisihTinggiTeraController,
                readOnly: true,
                hintText: '0',
                keyboardType: TextInputType.number),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(
                  color: AppColors.secondaryText.withOpacity(0.15),
                  thickness: 1),
            ),
            _buildDecimalTextField(
                'Nilai Kepekaan Tangki (mm/Liter)',
                controller.nilaiKepekaanController,
                'Masukkan nilai kepekaan'),
            _buildTextField('Selisih Volume Tera (Liter)',
                controller: controller.selisihVolumeTeraController,
                readOnly: true,
                hintText: '0',
                keyboardType: TextInputType.number),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(
                color: AppColors.secondaryText.withOpacity(0.15),
                thickness: 1,
              ),
            ),
            _buildTextField(
              'Segel Tangki Atas',
              controller: controller.segelTangkiAtasController,
              hintText: 'Masukkan nomor segel atas',
            ),
            _buildTextField(
              'Segel Tangki Bawah',
              controller: controller.segelTangkiBawahController,
              hintText: 'Masukkan nomor segel bawah',
            ),
            Obx(() => _buildDropdownField(
                  label: 'Kondisi Segel',
                  items: const ['Baik', 'Rusak', 'Hilang'],
                  selectedValue: controller.kondisiSegelSelected.value,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      controller.kondisiSegelSelected.value = newValue;
                    }
                  },
                )),
          ],
        ),
      ],
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildPhotoBox({
    required int index,
    required String label,
    required String assetPath,
    bool isFullWidth = false,
  }) {
    return Obx(() {
      final CapturedImageDetail? imageDetail = controller.photoSlots[index];
      final bool hasImage = imageDetail != null;
      final double boxHeight = isFullWidth ? 150 : 135;

      return GestureDetector(
        onTap: controller.isTakingPhoto.value
            ? null
            : () {
                if (!hasImage) {
                  controller.setActivePhotoLabel(label);
                  controller.takeSpecificPhoto(index);
                }
              },
        child: Container(
          height: boxHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasImage
                  ? AppColors.primary
                  : AppColors.secondaryText.withAlpha(76),
              width: hasImage ? 1.5 : 1,
            ),
          ),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(File(imageDetail.tempPath),
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: AppColors.alertSoftRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(blurRadius: 4, color: Colors.black26)
                              ]),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.white),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(10))),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.fUrbanistSemiBold10
                                .copyWith(color: Colors.white),
                          ),
                        ))
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        assetPath,
                        width: 20,
                        height: 20,
                        color: AppColors.primary,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.fUrbanistMedium12.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "+ Ambil Foto",
                      textAlign: TextAlign.center,
                      style: AppFonts.fUrbanistBold12.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
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
          Text(
            label,
            style: AppFonts.fUrbanistSemiBold14.copyWith(
              color: AppColors.primaryText,
            ),
          ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: hintText,
              hintStyle: AppFonts.fUrbanistLight12.copyWith(
                color: AppColors.secondaryText,
              ),
              filled: true,
              fillColor: readOnly
                  ? AppColors.backgroundGrey
                  : AppColors.alertSoftPrimarySecond,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            style: AppFonts.fUrbanistRegular12.copyWith(
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.fUrbanistSemiBold14.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.fieldBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            icon:
                const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            items: items
                .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(
                        v,
                        style: AppFonts.fUrbanistRegular12.copyWith(
                          color: AppColors.darkText,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton() {
    return Obx(() {
      final bool isLastPage = controller.currentPage.value == 2;
      final String buttonText =
          isLastPage ? 'Lanjut Pengukuran' : 'Selanjutnya';

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.goToNextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            buttonText,
            style: AppFonts.fUrbanistSemiBold14.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      );
    });
  }
}
