import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../helpers/decimal_input_formatter.dart';
import '../controllers/penerimaan_verifikasi_bast_controller.dart';

class PenerimaanVerifikasiBastView extends GetView<PenerimaanVerifikasiBastController> {
  const PenerimaanVerifikasiBastView({super.key});

  // --- TOTAL VOLUME CARD ---
  Widget _buildTotalVolumeCardSection(BuildContext context) {
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
          // HEADER: Total Volume + Nama Storage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Volume",
                style: AppFonts.fUrbanistMedium12.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.fieldBackground),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 10, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      controller.selectedStorage.value.isNotEmpty ? controller.selectedStorage.value : "Storage",
                      style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.primaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Volume Saat Ini", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                      const SizedBox(height: 4),
                      Text(
                        "${TextConvertHelper().formatNumber(controller.totalVolumeDisplay.value)} L",
                        style: AppFonts.fUrbanistBold20.copyWith(color: AppColors.primary, height: 1.0),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.withOpacity(0.3))
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_upward_rounded, size: 10, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              "${TextConvertHelper().formatNumber(controller.totalVolumeReceived.value)} L",
                              style: AppFonts.fUrbanistBold10.copyWith(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ),
                Container(
                  width: 1,
                  color: AppColors.fieldBackground,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  flex: 5,
                  child: Obx(() {
                    final tanks = controller.tankListDisplay;
                    if (tanks.isEmpty) return const SizedBox.shrink();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: tanks.map((tank) {
                        return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: _buildMicroTankItem(tank),
                            )
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

  // Menampilkan List Tangki
  Widget _buildMicroTankItem(Map<String, String> tankData) {
    String displayVol = tankData['volume'] ?? '0 L';
    String code = tankData['code'] ?? '-';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(code, style: AppFonts.fUrbanistMedium10.copyWith(fontSize: 10, color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(displayVol, style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: SIGNATURE CARD ---
  Widget _buildSignatureCard({
    required String title,
    required String placeholder,
    required SignatureController signatureController,
    TextEditingController? noteController,
    String noteLabel = "Catatan",
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 15,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.draw_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(title, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
                ],
              ),
              InkWell(
                onTap: () => signatureController.clear(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.alertSoftRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, size: 14, color: AppColors.alertSoftRed),
                      const SizedBox(width: 4),
                      Text("Ulangi", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.alertSoftRed)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text("Area Tanda Tangan", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 8),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Colors.grey.shade300, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          placeholder,
                          style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                  Signature(
                    controller: signatureController,
                    backgroundColor: Colors.transparent,
                    width: double.infinity,
                    height: 220,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              "Pastikan tanda tangan sesuai dengan identitas.",
              style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          if (noteController != null) ...[
            Text(noteLabel, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextFormField(
              controller: noteController,
              maxLines: 2,
              style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.darkText),
              decoration: InputDecoration(
                hintText: "Tulis catatan disini...",
                hintStyle: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- STEP 1: PENGECEKAN DATA ---
  Widget _buildStep1Pengecekan(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOTAL VOLUME CARD
          _buildTotalVolumeCardSection(context),

          const SizedBox(height: 24),
          Text("Pemeriksaan dan Pengukuran di Tangki Kebun",
              style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
          const SizedBox(height: 16),

          // 2. HASIL PENGUKURAN TANGKI KEBUN (Dinamis List)
          Obx(() {
            return Column(
              children: controller.fillingDataList.map((tank) {
                String varianVol = TextConvertHelper().formatNumber(tank.volumeVariant); // Solar yang diterima tangki tsb

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pengukuran ${tank.tankCode.replaceAll('_', ' ')}", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDimensionValue("Tinggi (mm)", TextConvertHelper().formatNumber(tank.heightAfter)),
                        const SizedBox(width: 12),
                        _buildDimensionValue("Volume (Ltr)", TextConvertHelper().formatNumber(tank.volumeAfter)),
                        const SizedBox(width: 12),
                        _buildDimensionValue("Diterima (Ltr)", "+$varianVol", isHighlight: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 8),

          // 3. PERBANDINGAN VOLUME (VARIAN KESELURUHAN)
          Text("Volume Tangki Kendaraan vs Tangki Kebun",
              style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
          const SizedBox(height: 16),

          _buildTextField(
              "Volume Tangki Pengirim (Ltr)",
              controller.volumePengirimController,
              onChanged: (val) => controller.hitungVarian()
          ),

          _buildTextField(
              "Total Solar Diterima Tangki Kebun (Ltr)",
              controller.volumeKebunController,
              readOnly: true
          ),

          _buildTextField(
              "Varian / Sisa Solar Pengirim (Ltr)",
              controller.varianController,
              readOnly: true
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- STEP 2: PENGUKURAN ---
  Widget _buildStep2Pengukuran(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOTAL VOLUME CARD
          _buildTotalVolumeCardSection(context),

          const SizedBox(height: 24),

          // WRAPPER CONTAINER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE3E8F0), width: 1.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ]
            ),
            child: Obx(() {
              final trx = controller.currentTransaction.value;
              final data = trx?.dataSebelum;

              String valNum(double? v, [String suffix = ""]) => (v != null) ? "${v.toStringAsFixed(0)} $suffix" : "-";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  _buildSummaryRow("No. BAST", trx?.noBast ?? "-"),
                  _buildSummaryRow("Hari, Tanggal", data?.dateInbound ?? "-"),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E8F0)),
                  ),

                  // --- DATA PENGIRIMAN ---
                  _buildSectionTitle("Data Pengiriman"),
                  _buildSummaryRow("No. PO", data?.purchNo ?? "-"),
                  _buildSummaryRow("Jumlah", valNum(data?.volumeVendor, "Ltr")),
                  _buildSummaryRow("Density", valNum(data?.densityVendor)),
                  _buildSummaryRow("Tempr (Obs)", valNum(data?.tempVendor)),

                  const SizedBox(height: 12),

                  // --- UNIT PENGANGKUTAN ---
                  _buildSectionTitle("Unit Pengangkutan"),
                  _buildSummaryRow("No. Polisi", data?.nopolVendor ?? "-"),
                  _buildSummaryRow("Nama Sopir", data?.supirVendor ?? "-"),
                  _buildSummaryRow("Kap. Tangki Angkut (Ltr)", valNum(data?.kapasitasVendor)),

                  const SizedBox(height: 12),

                  // --- PEMERIKSAAN ---
                  _buildSectionTitle("Pemeriksaan"),
                  _buildSummaryRow("Tinggi Terra SPB (mm)", valNum(data?.terraVendor)),
                  _buildSummaryRow("Tinggi Terra Zounding (mm)", valNum(data?.terraCheck)),
                  _buildSummaryRow("Selisih Tinggi Terra (mm)", valNum(data?.terraVar)),
                  _buildSummaryRow("Nilai Kepekaan (mm/Ltr)", data?.tangkiPeka ?? "-"),
                  _buildSummaryRow("Selisih Volume Terra (Ltr)", valNum(data?.selisihVolumeTerra)),
                  _buildSummaryRow("Segel Tangki Atas", data?.segelTangkiAtas ?? "-"),
                  _buildSummaryRow("Segel Tangki Bawah", data?.segelTangkiBawah ?? "-"),
                  _buildSummaryRow("Kondisi Segel", data?.segelKondisi ?? "-"),

                  const SizedBox(height: 12),

                  // --- PERHITUNGAN FISIK / VOLUME SOLAR ---
                  _buildSectionTitle("Pemeriksaan Volume Solar"),

                  _buildSummaryRow("Vol. Tangki Pengirim", "${controller.volumePengirimController.text} Ltr"),
                  _buildSummaryRow("Total Solar Diterima Kebun", "${controller.volumeKebunController.text} Ltr"),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                    child: _buildSummaryRow("Varian (Sisa di Pengirim)", "${controller.varianController.text} Ltr"),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.previousPage(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F1FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Edit",
                      style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Lanjut",
                      style: AppFonts.fUrbanistSemiBold14.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- STEP 3: GUDANG ---
  Widget _buildStep3Gudang(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildSignatureCard(
              title: "Bagian Gudang",
              placeholder: "Tanda Tangan Penerima disini",
              signatureController: controller.signatureGudangController,
              noteController: controller.catatanGudangController,
              noteLabel: "Catatan Penerimaan"
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- STEP 4: SUPIR ---
  Widget _buildStep4Supir(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildSignatureCard(
            title: "Supir / Partner",
            placeholder: "Tanda Tangan Pengirim disini",
            signatureController: controller.signatureSupirController,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildDimensionValue(String label, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistSemiBold10.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              color: isHighlight ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF2F6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isHighlight ? AppColors.primary.withOpacity(0.3) : const Color(0xFFE3E8F0)),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppFonts.fUrbanistBold14.copyWith(color: isHighlight ? AppColors.primary : AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool readOnly = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            readOnly: readOnly,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: readOnly ? [] : [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              DecimalInputFormatter(), // Memisahkan ribuan otomatis saat mengetik
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? const Color(0xFFF2F6FF) : AppColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 8,
            child: Text(
              label,
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text('Verifikasi BAST', style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => controller.previousPage(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: controller.onPageChanged,
              children: [
                _buildStep1Pengecekan(context),
                _buildStep2Pengukuran(context),
                _buildStep3Gudang(context),
                _buildStep4Supir(context),
              ],
            ),
          ),

          Obx(() {
            if (controller.currentPage.value == 1) {
              return const SizedBox.shrink();
            }

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
                  onPressed: controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    controller.currentPage.value >= 3 ? 'Submit Verifikasi' : 'Selanjutnya',
                    style: AppFonts.fUrbanistSemiBold14.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}