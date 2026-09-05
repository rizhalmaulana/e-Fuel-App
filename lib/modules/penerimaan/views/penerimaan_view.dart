import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/modules/penerimaan/controllers/penerimaan_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../helpers/decimal_input_formatter.dart';
import '../../../helpers/separator_input_formatter.dart';
import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';

class PenerimaanView extends GetView<PenerimaanController> {
  const PenerimaanView({super.key});

  Widget _buildCustomTextField(
      {required String label,
      required TextEditingController controller,
      required String hint,
      required bool isReadOnly,
      Color? activeFillColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppFonts.fUrbanistMedium12
                .copyWith(color: AppColors.primaryText)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          readOnly: isReadOnly,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            DecimalInputFormatter(),
            SeparatorInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: !isReadOnly
                ? (activeFillColor ?? const Color(0xFFF2F6FF))
                : const Color(0xFFF2F6FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
        ),
      ],
    );
  }

  Widget _buildTotalVolumeCardSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Volume",
                style: AppFonts.fUrbanistMedium12
                    .copyWith(color: AppColors.secondaryText),
              ),
              Obx(() => InkWell(
                    onTap: controller.refreshData,
                    child: controller.isRefreshing.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh,
                            color: AppColors.primary, size: 18),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() {
            double totalVol = controller.manualTotalVolume.value;
            return Text(
              "${TextConvertHelper().formatNumber(totalVol)} L",
              style:
                  AppFonts.fUrbanistBold24.copyWith(color: AppColors.primary),
            );
          }),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.fieldBackground),
          const SizedBox(height: 12),
          Obx(() {
            final List<Map<String, dynamic>> tanks =
                controller.tankListManualSnapshot.map((tank) {
              final String code = tank['code'] ?? '';
              final String volStr =
                  controller.manualInputControllers[code]?['volume']?.text ??
                      '0';
              // Bersihkan format ribuan agar bisa di-parse
              final double vol = double.tryParse(
                      volStr.replaceAll('.', '').replaceAll(',', '.')) ??
                  0;
              return {'code': code, 'volume': vol};
            }).toList();

            return Row(
              children: tanks.map((tank) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildMicroTankItem(tank),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMicroTankItem(Map<String, dynamic> tankData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBackground),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(tankData['code'] ?? '-',
                style: AppFonts.fUrbanistMedium10
                    .copyWith(color: AppColors.secondaryText),
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            "${TextConvertHelper().formatNumber((tankData['volume'] as num).toDouble())} L",
            style:
                AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Judul berubah sesuai mode
        Text(
          "Data Tangki Stok Solar",
          style: AppFonts.fUrbanistBold16.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Silahkan sesuaikan input untuk setiap tangki.",
          style: AppFonts.fUrbanistRegular12
              .copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 16),

        Obx(() {
          // Tampilkan semua tangki yang ada di tankListManualSnapshot
          final List<Map<String, dynamic>> displayTanks =
              controller.tankListManualSnapshot.toList();

          if (displayTanks.isEmpty) {
            return const Center(child: Text("Tidak ada tangki terdeteksi"));
          }

          return Column(
            children: displayTanks.map((tank) {
              final String code = tank['code']!;
              final controllers = controller.manualInputControllers[code];

              if (controllers == null) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.fieldBackground, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.propane_tank_outlined,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(code,
                                  style: AppFonts.fUrbanistSemiBold14
                                      .copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: _buildCustomTextField(
                            label: "Tinggi (mm)",
                            controller: controllers['height']!,
                            hint: "0",
                            isReadOnly: false,
                            activeFillColor: AppColors.alertSoftPrimarySecond,
                          )),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCustomTextField(
                              label: "Volume (Ltr)",
                              controller: controllers['volume']!,
                              hint: "Auto",
                              isReadOnly:
                                  true, // Volume selalu readonly di Sounding
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildBottomButtonSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            offset: const Offset(0, -4),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.validateAndProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Submit',
            style: AppFonts.fUrbanistSemiBold14.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
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
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.primary, size: 20),
          onPressed: () {
            if (Get.previousRoute.isEmpty || Get.previousRoute == '') {
              Get.offAllNamed(Routes.HOME);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Obx(() => Text(
                          controller.selectedStorage.value,
                          style: AppFonts.fUrbanistBold16
                              .copyWith(color: AppColors.darkText),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  const SizedBox(height: 16),
                  _buildTotalVolumeCardSection(),
                  const SizedBox(height: 24),
                  _buildManualInputSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomButtonSection(context),
        ],
      ),
    );
  }
}
