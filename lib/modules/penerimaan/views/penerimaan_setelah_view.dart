import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:e_fuel/configs/app_lotties.dart';

import '../../../helpers/decimal_input_formatter.dart';
import '../controllers/penerimaan_setelah_controller.dart';

class PenerimaanSetelahView extends GetView<PenerimaanSetelahController> {
  const PenerimaanSetelahView({super.key});

  // --- WIDGETS ---
  Widget _buildTotalVolumeCardSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Text(
                "Perbandingan Volume Total",
                style: AppFonts.fUrbanistMedium12.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              Obx(() => InkWell(
                onTap: controller.refreshSensorData,
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

          const SizedBox(height: 16),

          // ISI (Sebelum vs Sesudah)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // KIRI: SEBELUM PENGISIAN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sebelum Pengisian", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                      const SizedBox(height: 4),
                      Text(
                        "${TextConvertHelper().formatNumber(controller.totalManualBefore.value)} L",
                        style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  color: AppColors.fieldBackground,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),

                // KANAN: SESUDAH PENGISIAN
                Expanded(
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Sesudah Pengisian", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.primary)),
                          const SizedBox(width: 4),
                          Icon(controller.isSensorApiActive.value ? Icons.wifi_tethering : Icons.edit_note, size: 12, color: AppColors.primary)
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${TextConvertHelper().formatNumber(controller.totalVolumeManualSesudah.value)} L",
                        style: AppFonts.fUrbanistBold20.copyWith(color: AppColors.primary),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: AppColors.fieldBackground, height: 1),
          const SizedBox(height: 8),

          // SELISIH TOTAL (VARIAN)
          Obx(() {
            double variantTotal = controller.totalVolumeManualSesudah.value - controller.totalManualBefore.value;
            String symbol = variantTotal >= 0 ? "+" : "";
            Color variantColor = variantTotal > 0 ? Colors.blue : (variantTotal < 0 ? Colors.red : AppColors.secondaryText);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Penerimaan:", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)),
                Text(
                    "$symbol${TextConvertHelper().formatNumber(variantTotal)} Ltr",
                    style: AppFonts.fUrbanistBold14.copyWith(color: variantColor)
                ),
              ],
            );
          })
        ],
      ),
    );
  }

  // --- TANK INPUT SECTION ---
  Widget _buildTankInputSection(String tankCode) {
    return Obx(() {
      final ctrls = controller.manualInputControllers[tankCode];
      if (ctrls == null) return const SizedBox.shrink();

      String displayCode = controller.iotSesudahMap[tankCode]?['display_code'] ?? tankCode;
      bool isApiActive = controller.isSensorApiActive.value;

      double volSebelum = controller.getVolumeManualSebelum(tankCode);
      double heightSebelum = controller.getHeightManualSebelum(tankCode);

      var _ = controller.refreshTrigger.value;

      double varianVol = controller.getVarianVolume(tankCode);
      double varianHeight = controller.getVarianHeight(tankCode);

      String strVolSebelum = TextConvertHelper().formatNumber(volSebelum);
      String strHeightSebelum = TextConvertHelper().formatNumber(heightSebelum);

      String strVarianVol = (varianVol > 0 ? "+" : "") + TextConvertHelper().formatNumber(varianVol);
      String strVarianHeight = (varianHeight > 0 ? "+" : "") + TextConvertHelper().formatNumber(varianHeight);

      Color volColor = varianVol > 0 ? Colors.blue : (varianVol < 0 ? Colors.red : AppColors.secondaryText);
      Color heightColor = varianHeight > 0 ? Colors.blue : (varianHeight < 0 ? Colors.red : AppColors.secondaryText);

      return Container(
        margin: const EdgeInsets.only(bottom: 24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.fieldBackground, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER TANGKI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.propane_tank, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(displayCode, style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  if (isApiActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text("Sensor Aktif", style: AppFonts.fUrbanistBold10.copyWith(color: Colors.green)),
                    )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // BLOK SEBELUM PENGISIAN (Read Only - Grey Background)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.fieldBackground)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Data Sebelum Pengisian", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildInfoItem("Tinggi (mm)", strHeightSebelum)),
                            Container(width: 1, height: 30, color: AppColors.fieldBackground),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: _buildInfoItem("Volume (Ltr)", strVolSebelum),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BLOK SESUDAH PENGISIAN (Input Fields)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Input Sesudah Pengisian ", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)),
                          Text("(Wajib diisi)", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.alertSoftRed)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: isApiActive ? [
                          // JIKA SENSOR AKTIF: VOLUME DI KIRI (BISA DIEDIT), TINGGI DI KANAN (AUTO)
                          Expanded(
                              child: _buildCustomTextField(
                                label: "Volume (Ltr)",
                                controller: ctrls['volume']!,
                                hint: "0",
                                isReadOnly: false,
                                activeFillColor: AppColors.alertSoftPrimarySecond,
                              )
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildCustomTextField(
                                label: "Tinggi (mm)",
                                controller: ctrls['height']!,
                                hint: "Auto",
                                isReadOnly: true,
                              )
                          ),
                        ] : [
                          // JIKA SENSOR MATI: TINGGI DI KIRI (BISA DIEDIT), VOLUME DI KANAN (AUTO)
                          Expanded(
                              child: _buildCustomTextField(
                                label: "Tinggi (mm)",
                                controller: ctrls['height']!,
                                hint: "0",
                                isReadOnly: false,
                                activeFillColor: AppColors.alertSoftPrimarySecond,
                              )
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildCustomTextField(
                                label: "Volume (Ltr)",
                                controller: ctrls['volume']!,
                                hint: "Auto",
                                isReadOnly: true,
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // BLOK VARIAN (Hitungan Live)
                  Row(
                    children: isApiActive ? [
                      Expanded(child: _buildVarianItem("Varian Volume", "$strVarianVol Ltr", volColor)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildVarianItem("Varian Tinggi", "$strVarianHeight mm", heightColor)),
                    ] : [
                      Expanded(child: _buildVarianItem("Varian Tinggi", "$strVarianHeight mm", heightColor)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildVarianItem("Varian Volume", "$strVarianVol Ltr", volColor)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isReadOnly = false,
    Color? activeFillColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          readOnly: isReadOnly,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            DecimalInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            // Jika read-only, pakai warna abu-abu. Jika tidak, pakai warna activeFillColor atau putih.
            fillColor: isReadOnly ? const Color(0xFFF2F4F7) : (activeFillColor ?? Colors.white),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.backgroundGrey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          style: AppFonts.fUrbanistBold14.copyWith(
              color: isReadOnly ? AppColors.secondaryText : AppColors.darkText
          ),
        ),
      ],
    );
  }

  // Helper UI untuk menampilkan Info Sebelum
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 2),
        Text(value, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
      ],
    );
  }

  Widget _buildVarianItem(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: valueColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: valueColor.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 4),
          Text(value, style: AppFonts.fUrbanistBold14.copyWith(color: valueColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Konfirmasi Solar', style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoadingData.value) {
          return Center(child: Lottie.asset(AppLotties.loading, width: 150));
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          controller.currentTransaction?.dataSebelum?.storageCode ?? "Storage Location",
                          style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- TOTAL VOLUME CARD SEBELUM & SESUDAH ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildTotalVolumeCardSection(),
                      ),

                      const SizedBox(height: 16),

                      // --- FORM INPUT SESUDAH ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Pengukuran Setelah Pengisian", style: AppFonts.fUrbanistBold16),
                            Text("Perbandingan detail tinggi dan volume per tangki", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
                            const SizedBox(height: 16),

                            // Generate Input Form berdasarkan Tangki yang aktif
                            ...controller.activeTankCodes.map((code) => _buildTankInputSection(code)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- BUTTON STICKY DI BAWAH ---
              Container(
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
                    onPressed: controller.goToVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Lanjut Verifikasi',
                      style: AppFonts.fUrbanistSemiBold14.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}