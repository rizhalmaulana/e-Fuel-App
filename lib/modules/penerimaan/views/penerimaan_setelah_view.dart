import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:e_fuel/configs/app_lotties.dart';

import '../controllers/penerimaan_setelah_controller.dart';

class PenerimaanSetelahView extends StatefulWidget {
  const PenerimaanSetelahView({super.key});

  @override
  State<PenerimaanSetelahView> createState() => _PenerimaanSetelahViewState();
}

class _PenerimaanSetelahViewState extends State<PenerimaanSetelahView> {
  final controller = Get.find<PenerimaanSetelahController>();
  final PageController _headerPageController = PageController();

  @override
  void dispose() {
    _headerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Volume Solar', style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingData.value) {
          return Center(child: Lottie.asset(AppLotties.loading, width: 150));
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildProgressHeader(),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 260,
                  child: PageView(
                    controller: _headerPageController,
                    onPageChanged: (index) => controller.headerPageIndex.value = index,
                    children: [
                      // CARD 1: DATA MANUAL SEBELUM
                      _buildSummaryCard(
                        title: "Sebelum Pengisian (Manual)",
                        totalVolume: controller.totalManualBefore.value,
                        tankList: controller.manualBeforeList,
                        icon: Icons.edit_note,
                        badgeColor: const Color(0xFFE3F2FD),
                        iconColor: Colors.blueAccent,
                      ),

                      // CARD 2: DATA IOT SEBELUM
                      _buildSummaryCard(
                        title: "Sebelum Pengisian (IoT)",
                        totalVolume: controller.totalIotBefore.value,
                        tankList: controller.iotBeforeList,
                        icon: Icons.wifi_tethering,
                        badgeColor: const Color(0xFFE8F5E9),
                        iconColor: Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // DOT INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) => _buildDot(index)),
                ),

                const SizedBox(height: 24),

                // --- FORM INPUT SESUDAH ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          controller.currentTransaction?.dataSebelum?.storageCode ?? "Storage Location",
                          style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text("Pengukuran Setelah Pengisian", style: AppFonts.fUrbanistBold16),
                      Text("Input manual untuk Volume dan Tinggi solar", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
                      const SizedBox(height: 16),

                      // Generate Input Form berdasarkan Tangki yang aktif
                      ...controller.activeTankCodes.map((code) => _buildTankInputSection(code)).toList(),

                      const SizedBox(height: 16),
                      _buildTotalVolumeCard(),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.goToVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Lanjut', style: AppFonts.fUrbanistSemiBold16.copyWith(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- WIDGETS ---

  // Widget Wrapper untuk Card Summary agar rapi
  Widget _buildSummaryCard({
    required String title,
    required double totalVolume,
    required List<Map<String, dynamic>> tankList,
    required IconData icon,
    required Color badgeColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.backgroundGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            // Header Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: iconColor),
                      const SizedBox(width: 8),
                      Text(title, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Volume Besar
            Text(
              "${TextConvertHelper().formatNumber(totalVolume)} Ltr",
              style: AppFonts.fUrbanistBold24.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.backgroundGrey),
            const SizedBox(height: 8),

            Expanded(
              child: tankList.isEmpty
                  ? Center(child: Text("- Data Kosong -", style: AppFonts.fUrbanistRegular12))
                  : SingleChildScrollView(
                child: Column(
                  children: tankList.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['code'] ?? '-',
                          style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText),
                        ),
                        Row(
                          children: [
                            Text(
                                "${TextConvertHelper().formatNumber(item['volume'])} Ltr",
                                style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.primary)
                            ),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 12, color: AppColors.secondaryText),
                            const SizedBox(width: 8),
                            Text(
                                "${TextConvertHelper().formatNumber(item['height'])} cm",
                                style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText)
                            ),
                          ],
                        )
                      ],
                    ),
                  )).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Obx(() {
      bool isActive = controller.headerPageIndex.value == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 20 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    });
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundGrey),
        color: AppColors.white,
      ),
      child: Row(
        children: [
          const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text("Pengukuran solar setelah pengisian", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  Widget _buildTankInputSection(String tankCode) {
    final ctrls = controller.manualInputControllers[tankCode];
    if (ctrls == null) return const SizedBox.shrink();

    String displayCode = controller.iotSesudahMap[tankCode]?['display_code'] ?? tankCode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.fieldBackground),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.propane_tank, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(displayCode, style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                    child: _buildCustomTextField(
                      label: "Tinggi (mm)",
                      controller: ctrls['height']!,
                      hint: "0",
                      isReadOnly: false, // User bisa edit
                    )
                ),

                const SizedBox(width: 16),

                // INPUT VOLUME (AUTOFILL / READONLY)
                Expanded(
                    child: _buildCustomTextField(
                      label: "Volume (Ltr)",
                      controller: ctrls['volume']!,
                      hint: "Auto", // Hint Baru
                      isReadOnly: true, // Disable Input Manual
                    )
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: AppColors.backgroundGrey),
            const SizedBox(height: 8),

            // VARIAN SECTION (Live Calculation)
            Text("Selisih (Sebelum vs Sesudah)", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)),
            const SizedBox(height: 8),

            Obx(() {
              var _ = controller.refreshTrigger.value;

              double varianVol = controller.getVarianVolume(tankCode);
              double varianHeight = controller.getVarianHeight(tankCode);

              // Format +/- string
              String strVol = (varianVol > 0 ? "+" : "") + TextConvertHelper().formatNumber(varianVol);
              String strHeight = (varianHeight > 0 ? "+" : "") + TextConvertHelper().formatNumber(varianHeight);

              // Warna teks (Hijau jika positif, Merah jika negatif/0)
              Color volColor = varianVol > 0 ? Colors.green : (varianVol < 0 ? Colors.red : AppColors.secondaryText);

              return Row(
                children: [
                  Expanded(child: _buildReadOnlyField("Beda Tinggi", "$strHeight mm", textColor: AppColors.darkText)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildReadOnlyField("Beda Volume", "$strVol Ltr", textColor: volColor)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isReadOnly = false // Default false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          readOnly: isReadOnly,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isReadOnly ? const Color(0xFFF2F4F7) : Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.backgroundGrey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          style: AppFonts.fUrbanistBold14.copyWith(
              color: isReadOnly ? AppColors.secondaryText : AppColors.darkText // Text grey jika readonly
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: AppFonts.fUrbanistBold12.copyWith(color: textColor ?? AppColors.darkText),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalVolumeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Volume Masuk", style: AppFonts.fUrbanistMedium12.copyWith(color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 4),
              Obx(() => Text(
                "${TextConvertHelper().formatNumber(controller.totalVolumeManualSesudah.value)} Ltr",
                style: AppFonts.fUrbanistBold20.copyWith(color: Colors.white),
              )),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white),
          )
        ],
      ),
    );
  }
}