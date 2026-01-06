import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../helpers/separator_input_formatter.dart';
import '../controllers/pengeluaran_controller.dart';

class PengeluaranView extends GetView<PengeluaranController> {
  const PengeluaranView({super.key});

  static const Color _colorEditable = AppColors.alertSoftOrange;
  static const Color _colorReadOnly = AppColors.backgroundGrey;

  // --- HELPER: SECTION CARD ---
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 10),
              Text(title, style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText)),
            ],
          ),
          const SizedBox(height: 12),
          // Isi Form
          ...children,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: Colors.grey.shade200, thickness: 1.5, height: 1),
    );
  }

  // --- WIDGETS INPUT ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
      child: Text(text,
          style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryText)),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    bool readOnly = false,
    bool forceEditableColor = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    List<TextInputFormatter>? customFormatters,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    final Color backgroundColor = (readOnly && !forceEditableColor) ? _colorReadOnly : _colorEditable;
    List<TextInputFormatter> formatters = [UpperCaseTextFormatter(), ...?customFormatters];

    return TextFormField(
      controller: controller,
      onTap: onTap,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.characters,
      style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primaryText),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: AppFonts.fUrbanistLight12.copyWith(color: AppColors.secondaryText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryOrange)),
      ),
      inputFormatters: formatters,
    );
  }

  Widget _buildStandardDropdown({
    required List<String> items,
    required Function(String?) onChanged,
    String? value,
    String? hint,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryOrange),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: _colorEditable,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryOrange)),
      ),
      hint: Text(hint ?? '', style: AppFonts.fUrbanistLight12.copyWith(color: AppColors.secondaryText)),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toUpperCase(), style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primaryText), overflow: TextOverflow.ellipsis, maxLines: 1),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSearchableDropdown({required String? value, required VoidCallback onTap, String? hint}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _colorEditable,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value?.toUpperCase() ?? hint ?? '',
                style: value != null
                    ? AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primaryText)
                    : AppFonts.fUrbanistLight12.copyWith(color: AppColors.secondaryText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryOrange, size: 20),
          ],
        ),
      ),
    );
  }

  void _showUnitSearchSheet(BuildContext context) {
    if (controller.isTamu) return;
    controller.searchUnit('');
    Get.bottomSheet(
      Container(
        height: Get.height * 0.65,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: "Cari Unit / No IO...",
                hintStyle: AppFonts.fUrbanistLight12,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => controller.searchUnit(val),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingUnit.value) return const Center(child: CircularProgressIndicator());
                if (controller.filteredUnitList.isEmpty) return const Center(child: Text("Unit tidak ditemukan"));
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: controller.filteredUnitList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    var unit = controller.filteredUnitList[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                      title: Text(unit.namaUnit?.toUpperCase() ?? '-', style: AppFonts.fUrbanistBold14),
                      subtitle: Text("${unit.noPolisi ?? '-'} • ${unit.internalOrder ?? '-'}", style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey)),
                      onTap: () {
                        controller.onUnitSelected(unit);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text('Form Pengeluaran Solar', style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundGrey,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20), onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================================================
            // CARD 1: INFORMASI UNIT & TRANSAKSI (GABUNGAN)
            // =========================================================
            _buildSectionCard(
              title: "Jenis Transaksi & Unit",
              icon: Icons.directions_car_filled_rounded,
              children: [
                // Baris 1: Jenis & Kategori
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildLabel("Jenis Pengeluaran"),
                      Obx(() => _buildStandardDropdown(
                        items: controller.jenisBonList,
                        value: controller.selectedJenisBon.value,
                        onChanged: (val) => controller.switchJenisBon(val),
                        hint: "Pilih Jenis",
                      )),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildLabel("Kategori"),
                      Obx(() => _buildStandardDropdown(
                        items: controller.jenisKategoriList,
                        value: controller.selectedKategoriKendaraan.value,
                        onChanged: (val) => controller.switchKategoriKendaraan(val),
                        hint: "Pilih Kategori",
                      )),
                    ])),
                  ],
                ),

                _buildDivider(), // Garis pemisah

                // Baris 2: Nama Unit & Plat No
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildLabel("Nama Unit"),
                      Obx(() => _buildSearchableDropdown(
                        hint: "Pilih Unit",
                        value: controller.selectedUnit.value?.namaUnit,
                        onTap: () => _showUnitSearchSheet(context),
                      )),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Obx(() {
                        String tipe = controller.tipeUnit.value?.toUpperCase() ?? "";
                        String label = "No. Kendaraan";
                        if (tipe == "AB" || tipe == "GS") label = "No. Unit";
                        return _buildLabel(label);
                      }),
                      Obx(() => _buildTextField(
                        controller: controller.platController,
                        readOnly: controller.isPlatReadOnly.value,
                        hint: "No. Plat/Unit",
                      )),
                    ])),
                  ],
                ),
              ],
            ),

            // =========================================================
            // CARD 2: DATA OPERASIONAL (CONDITIONAL: HIDDEN IF TAMU)
            // =========================================================
            Obx(() {
              if (controller.isTamu) return const SizedBox.shrink();

              return _buildSectionCard(
                title: "Data Operasional",
                icon: Icons.speed_rounded,
                children: [
                  // Logic HM/KM & Date
                  Obx(() {
                    if (controller.tipeUnit.value == null) return const SizedBox.shrink();
                    String tipe = controller.tipeUnit.value?.toUpperCase() ?? "";
                    String labelPrefix = (tipe == "AB") ? "HM" : "KM";

                    if (controller.isTipeKendaraan) {
                      return Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildLabel("$labelPrefix Awal"),
                          _buildTextField(controller: controller.hmKmAwalC, readOnly: controller.isHmKmAwalReadOnly.value, hint: "0", keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildLabel("$labelPrefix Akhir"),
                          _buildTextField(controller: controller.hmKmAkhirC, readOnly: controller.isHmKmAkhirReadOnly.value, hint: "0", keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                        ])),
                      ]);
                    } else {
                      return Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildLabel("Tanggal Awal"),
                          _buildTextField(controller: controller.dateAwalC, readOnly: true, forceEditableColor: true, hint: "dd/MM/yyyy", onTap: () => controller.pickDate(context, true)),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildLabel("Tanggal Akhir"),
                          _buildTextField(controller: controller.dateAkhirC, readOnly: true, forceEditableColor: true, hint: "dd/MM/yyyy", onTap: () => controller.pickDate(context, false)),
                        ])),
                      ]);
                    }
                  }),

                  const SizedBox(height: 12),

                  // Logic Selisih & Rasio
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildLabel("Selisih"),
                        _buildTextField(
                            controller: controller.varianC,
                            readOnly: controller.isVarianReadOnly.value,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            hint: "0"),
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildLabel("Rasio"),
                        _buildTextField(
                          controller: controller.ratioC,
                          readOnly: controller.isRatioReadOnly.value,
                          hint: "0",
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ])),
                    ],
                  ),
                ],
              );
            }),

            // =========================================================
            // CARD 3: DETAIL PENGISIAN & VERIFIKASI (GABUNGAN)
            // =========================================================
            _buildSectionCard(
              title: "Estimasi Liter & Supir",
              icon: Icons.local_gas_station_rounded,
              children: [
                // Baris 1: Liter & IO/CostCenter
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildLabel("Estimasi Liter"),
                      Obx(() => _buildTextField(
                        controller: controller.pengisianSolarC,
                        readOnly: controller.isLiterReadOnly.value,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        hint: "Input Liter",
                        customFormatters: [SeparatorInputFormatter()],
                      )),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Obx(() => _buildLabel(controller.isTamu ? "Cost Center" : "No. IO")),
                      Obx(() => _buildTextField(
                          controller: controller.ioController,
                          readOnly: controller.isIoReadOnly.value,
                          hint: controller.isTamu ? "Input Cost Center" : "-")),
                    ])),
                  ],
                ),

                _buildDivider(), // Garis pemisah

                // Baris 2: Nama Supir
                Obx(() {
                  String tipe = controller.tipeUnit.value?.toUpperCase() ?? "";
                  String label = "Nama Supir";
                  if (tipe == "AB") label = "Nama Operator";
                  if (tipe == "GS") label = "Pengambil Solar";
                  return _buildLabel(label);
                }),
                _buildTextField(controller: controller.driverNameC, hint: "Input Nama Lengkap"),

                // Baris 3: Keterangan
                const SizedBox(height: 12),
                _buildLabel("Keterangan"),
                _buildTextField(controller: controller.keteranganC, hint: "Tambahkan Catatan (Opsional)...", maxLines: 1),
              ],
            ),

            const SizedBox(height: 20),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.validateAndProceed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text("Proses Pengisian", style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}