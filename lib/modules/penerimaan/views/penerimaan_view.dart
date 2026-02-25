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
                      style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText),
                      textAlign: TextAlign.center,
                    )),
                  ),

                  const SizedBox(height: 16),

                  _buildTotalVolumeCardSection(),

                  const SizedBox(height: 16),

                  // FLOW CONTROL
                  Obx(() => !controller.isSensorApiActive.value
                      ? _buildManualInputSection()
                      : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(child: Text("Data volume diambil otomatis dari sensor IoT.", style: AppFonts.fUrbanistMedium12.copyWith(color: Colors.green[800])))
                      ],
                    ),
                  )
                  ),

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
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            DecimalInputFormatter(),
            SeparatorInputFormatter(),
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

  Widget _buildTotalVolumeCardSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                controller.isSensorApiActive.value ? "Total Volume (IoT)" : "Total Volume (Manual)",
                style: AppFonts.fUrbanistMedium12.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold
                ),
              )),

              Obx(() => InkWell(
                onTap: controller.refreshData,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.fieldBackground)
                  ),
                  child: controller.isRefreshing.value
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, color: AppColors.primary, size: 14),
                ),
              )),
            ],
          ),

          const SizedBox(height: 12),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Obx(() {
                    double totalVol = controller.isSensorApiActive.value
                        ? controller.totalVolumeIoT.value
                        : controller.manualTotalVolume.value;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${TextConvertHelper().formatNumber(totalVol)} L",
                          style: AppFonts.fUrbanistBold20.copyWith(
                            color: AppColors.primary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.isSensorApiActive.value ? "Live Data" : "User Input",
                          style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText, fontSize: 9),
                        )
                      ],
                    );
                  }),
                ),

                Container(
                  width: 1,
                  color: AppColors.fieldBackground,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),

                Expanded(
                  flex: 5,
                  child: Obx(() {
                    List<Map<String, dynamic>> tankList = [];

                    if (controller.isSensorApiActive.value) {
                      tankList = controller.tankListIoT;
                    } else {
                      tankList = controller.tankListManualSnapshot.map((tank) {
                        String code = tank['code'];
                        String volStr = controller.manualInputControllers[code]?['volume']?.text ?? '0';
                        double vol = double.tryParse(volStr.replaceAll('.', '')) ?? 0;
                        return { 'code': code, 'volume': vol };
                      }).toList();
                    }

                    if (tankList.isEmpty) {
                      return Center(child: Text("- No Data -", style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey, fontSize: 10)));
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: tankList.take(3).map((tank) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: _buildMicroTankItem(tank),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroTankItem(Map<String, dynamic> tankData) {
    String displayVol = TextConvertHelper().formatNumber((tankData['volume'] as num).toDouble());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            tankData['code'] ?? '-',
            style: AppFonts.fUrbanistMedium10.copyWith(fontSize: 10, color: AppColors.secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          "$displayVol L",
          style: AppFonts.fUrbanistBold12.copyWith(fontSize: 11, color: AppColors.primaryText),
        ),
      ],
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Input Manual Tangki", style: AppFonts.fUrbanistBold16),
        Text("Masukkan tinggi hasil sounding", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 10),

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

              if (!controller.manualInputControllers.containsKey(code)) {
                return const SizedBox.shrink();
              }

              final ctrls = controller.manualInputControllers[code]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.propane_tank_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                            code,
                            style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary)
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
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
                              hint: "Auto",
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
}