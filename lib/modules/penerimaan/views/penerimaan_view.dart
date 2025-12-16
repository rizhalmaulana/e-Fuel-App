import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/modules/penerimaan/controllers/penerimaan_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/component/penerimaan_step_view.dart';

class PenerimaanView extends GetView<PenerimaanController> {
  const PenerimaanView({super.key});

  Widget _buildSwipeableHeader() {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView(
            onPageChanged: (index) => controller.headerPageIndex.value = index,
            children: [
              Obx(() => _buildInfoCard(
                title: "Data Sensor IoT (Live)",
                totalVolume: controller.totalVolumeIoT.value,
                tankList: controller.tankListIoT,
                badgeColor: const Color(0xFFE8F5E9),
                icon: Icons.wifi_tethering,
                isRefreshable: true,
                onRefresh: controller.refreshData,
                isLoading: controller.isRefreshing.value,
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required double totalVolume,
    required List<Map<String, dynamic>> tankList,
    required Color badgeColor,
    required IconData icon,
    bool isRefreshable = false,
    VoidCallback? onRefresh,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.fieldBackground),
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(title, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              if (isRefreshable)
                InkWell(
                  onTap: onRefresh,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: isLoading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.refresh, color: Colors.white, size: 16),
                  ),
                )
            ],
          ),
          const SizedBox(height: 10),

          // Total Volume
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_gas_station, color: AppColors.primary, size: 32),
              const SizedBox(width: 8),
              Text(
                  "${TextConvertHelper().formatNumber(totalVolume)} ",
                  style: AppFonts.fUrbanistBold24.copyWith(fontSize: 28, color: AppColors.darkText)
              ),
              Text("Liter", style: AppFonts.fUrbanistBold20.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),

          Divider(color: AppColors.secondaryText.withOpacity(0.2)),

          Expanded(
            child: tankList.isNotEmpty
                ? SingleChildScrollView(
              child: Column(
                children: tankList.map((tank) {
                  double vol = 0.0;
                  double height = 0.0;

                  if (tank['volume'] is num) {
                    vol = (tank['volume'] as num).toDouble();
                  }
                  if (tank['height'] is num) {
                    height = (tank['height'] as num).toDouble();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text("${tank['code']}", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)),
                        ),

                        // Volume & Tinggi
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("${TextConvertHelper().formatNumber(vol)} Ltr", style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primary)),
                              const SizedBox(width: 8),
                              Text("|", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
                              const SizedBox(width: 8),
                              Text("${TextConvertHelper().formatNumber(height)} mm", style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.darkText)),
                            ],
                          ),
                        )
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

  void _showProgressModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
          child: PenerimaanStepView(
            steps: controller.masterSteps,
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Progress", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showProgressModal(context),
          child: Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.backgroundGrey),
              color: AppColors.white,
            ),
            child: Row(
              children: [
                Icon(
                    controller.masterSteps.firstWhere((step) => step.isActive.value).isCompleted.value ? Icons.check_circle : Icons.radio_button_checked,
                    color: AppColors.primary, size: 24
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.progressTitle.value,
                    style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Obx(() => Text(
            controller.selectedStorage.value,
            style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.darkText),
            textAlign: TextAlign.center,
          )),
        ),
        const SizedBox(height: 20),

        Text("Pengukuran Sebelum Pengisian", style: AppFonts.fUrbanistBold16),
        Text("Input manual untuk Volume dan Tinggi solar", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 20),

        // Obx memantau perubahan data dari API (Snapshot)
        Obx(() {
          if (controller.tankListManualSnapshot.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.secondaryText),
                  const SizedBox(height: 8),
                  Text("Tidak ada tangki terdeteksi", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            );
          }

          return Column(
            children: controller.tankListManualSnapshot.map((tank) {
              final code = tank['code']!;

              // Pastikan controller map memiliki key ini
              if (!controller.manualInputControllers.containsKey(code)) {
                return const SizedBox.shrink(); // Skip jika controller belum siap
              }

              final ctrls = controller.manualInputControllers[code]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label Tangki
                    Row(
                      children: [
                        const Icon(Icons.propane_tank_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                            code, // Nama Tangki dari API
                            style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary)
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomTextField(
                              label: "Tinggi (mm)",
                              controller: ctrls['height']!,
                              hint: "0",
                              isReadOnly: false
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildCustomTextField(
                              label: "Volume (Ltr)",
                              controller: ctrls['volume']!,
                              hint: "Auto", // Hint berubah
                              isReadOnly: true
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),

        // 4. TOTAL VOLUME CARD
        const SizedBox(height: 8),
        Text("Total Volume Manual", style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text("Akumulasi input volume user", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 8),

        Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: const Color(0xFFF2F6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total:", style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.darkText)),
              Text(
                "${TextConvertHelper().formatNumber(controller.manualTotalVolume.value)} Ltr",
                style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isReadOnly
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primaryText)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          readOnly: isReadOnly,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsFormatter(),
          ],
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F6FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: controller.validateAndProceed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        'Submit',
        style: AppFonts.fUrbanistSemiBold16.copyWith(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sounding Stok Solar',
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () {
            if (Get.previousRoute.isEmpty || Get.previousRoute == '') {
              Get.offAllNamed(Routes.HOME);
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressHeader(context),
              const SizedBox(height: 20),
              _buildSwipeableHeader(),
              _buildManualInputSection(),
              const SizedBox(height: 25),
              _buildNextButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ThousandsFormatter extends TextInputFormatter {
  static const separator = '.';

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    int value = int.tryParse(newText) ?? 0;

    final formatter = NumberFormat('#,###', 'id_ID');
    String formatted = formatter.format(value);
    formatted = formatted.replaceAll(',', '.');

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}