import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/helpers/string_helper.dart';
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

                // --- HEADER CAROUSEL (SWIPEABLE CARD) ---
                SizedBox(
                  height: 240,
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
                      ),

                      // CARD 2: DATA IOT SEBELUM
                      _buildSummaryCard(
                        title: "Sebelum Pengisian (IoT)",
                        totalVolume: controller.totalIotBefore.value,
                        tankList: controller.iotBeforeList,
                        icon: Icons.wifi_tethering,
                        badgeColor: const Color(0xFFE8F5E9),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) => _buildDot(index)),
                ),

                const SizedBox(height: 24),

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

                      ...controller.activeTankCodes.map((code) => _buildTankInputSection(code)).toList(),
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
  Widget _buildSummaryCard({
    required String title,
    required double totalVolume,
    required List<Map<String, dynamic>> tankList,
    required IconData icon,
    required Color badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.fieldBackground),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(title, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Total Volume
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_gas_station, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              Text(
                  StringHelper().formatNumber(totalVolume),
                  style: AppFonts.fUrbanistBold24.copyWith(fontSize: 28, color: AppColors.darkText)
              ),
              Text(" Liter", style: AppFonts.fUrbanistBold20.copyWith(color: AppColors.primary)),
            ],
          ),

          const SizedBox(height: 12),

          // Divider tipis pemisah header dan list
          Divider(color: AppColors.backgroundGrey, thickness: 1),

          const SizedBox(height: 8),

          // FIX: Gunakan Expanded + SingleChildScrollView
          // Agar list bisa di-scroll di dalam card jika datanya banyak
          Expanded(
            child: tankList.isNotEmpty
                ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: tankList.map((tank) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        // Text Code dengan lebar fix agar rapi
                        SizedBox(
                          width: 70,
                          child: Text(tank['code'], style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
                        ),

                        const Spacer(),

                        Text("Vol ", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
                        Text("${StringHelper().formatNumber(tank['volume'])} Ltr ", style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.darkText)),

                        const SizedBox(width: 8),

                        Text("Tinggi ", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
                        Text("${StringHelper().formatNumber(tank['height'])} Cm", style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.darkText)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
                : Center(child: Text("- Data Kosong -", style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey))),
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JUDUL TANGKI
          Text(displayCode, style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),

          // INPUT ROW
          Row(
            children: [
              Expanded(child: _buildCustomTextField(label: "Volume (Ltr)", controller: ctrls['volume']!, hint: "0")),
              const SizedBox(width: 16),
              Expanded(child: _buildCustomTextField(label: "Tinggi (Cm)", controller: ctrls['height']!, hint: "0")),
            ],
          ),

          const SizedBox(height: 16),

          // VARIAN SECTION (Sesuai Gambar)
          Text("Varian $displayCode Sebelum vs Sesudah", style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),

          Obx(() {
            var _ = controller.refreshTrigger.value;

            double varianVol = controller.getVarianVolume(tankCode);
            double varianHeight = controller.getVarianHeight(tankCode);

            // Format +/- string
            String strVol = (varianVol > 0 ? "+" : "") + StringHelper().formatNumber(varianVol);
            String strHeight = (varianHeight > 0 ? "+" : "") + StringHelper().formatNumber(varianHeight);

            return Row(
              children: [
                Expanded(child: _buildReadOnlyField("Volume (Ltr)", strVol)),
                const SizedBox(width: 16),
                Expanded(child: _buildReadOnlyField("Tinggi (Cm)", strHeight)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({required String label, required TextEditingController controller, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F6FF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary.withOpacity(0.7))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6FF).withOpacity(0.5), // Sedikit transparan untuk membedakan readonly
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.primary.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalVolumeCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Total Volume", style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text("Volume Tangki (Ltr)", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary)),
        const SizedBox(height: 8),
        Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            StringHelper().formatNumber(controller.totalVolumeManualSesudah.value),
            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary.withOpacity(0.6)),
          ),
        )),
      ],
    );
  }
}