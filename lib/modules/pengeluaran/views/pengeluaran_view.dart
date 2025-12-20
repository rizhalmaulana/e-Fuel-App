import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
import '../../../helpers/separator_input_formatter.dart';
import '../controllers/pengeluaran_controller.dart';

class PengeluaranView extends GetView<PengeluaranController> {
  const PengeluaranView({super.key});

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
      child: Text(
        text,
        style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primaryText),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    List<TextInputFormatter>? customFormatters,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primaryText),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: AppFonts.fUrbanistLight12.copyWith(color: AppColors.secondaryText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: AppColors.fieldBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.secondaryText)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.secondaryText)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryOrange)),
      ),
      inputFormatters: customFormatters,
    );
  }

  Widget _buildStandardDropdown({
    required List<String> items,
    required Function(String?) onChanged,
    String? value,
    String? hint,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryOrange),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: AppColors.fieldBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.secondaryText)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.secondaryText)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryOrange)),
      ),
      hint: Text(hint ?? '', style: AppFonts.fUrbanistLight12.copyWith(color: AppColors.secondaryText)),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primaryText)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSearchableDropdown({required String? value, required VoidCallback onTap, String? hint}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.secondaryText),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? hint ?? '',
              style: value != null
                  ? AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primaryText)
                  : AppFonts.fUrbanistLight12.copyWith(color: AppColors.secondaryText),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryOrange),
          ],
        ),
      ),
    );
  }

  void _showUnitSearchSheet(BuildContext context) {
    controller.searchUnit('');
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Cari Unit / No IO...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) => controller.searchUnit(val),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingUnit.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.filteredUnitList.isEmpty) {
                  return const Center(child: Text("Unit tidak ditemukan"));
                }
                return ListView.separated(
                  itemCount: controller.filteredUnitList.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    var unit = controller.filteredUnitList[index];
                    return ListTile(
                      title: Text(unit.namaUnit ?? '-', style: AppFonts.fUrbanistBold14),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(unit.description ?? '-', style: AppFonts.fUrbanistRegular12),
                          Text("${unit.noPolisi ?? '-'} • ${unit.internalOrder ?? '-'}", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
                        ],
                      ),
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
    );
  }

  void _showManualInternalInput(BuildContext context) {
    controller.manualNipC.clear();
    controller.manualNamaC.clear();
    controller.manualJabatanC.clear();
    controller.manualUnitC.clear();

    Get.dialog(
      AlertDialog(
        title: Text(
          "Input Supir Internal",
          style: AppFonts.fUrbanistBold16,
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller.manualNipC,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: "NIP Karyawan",
                  isDense: true,
                  counterText: "",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                ],
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: controller.manualUnitC,
                maxLength: 4,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: "Kode Unit (4 Karakter)",
                  isDense: true,
                  counterText: "",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: controller.manualNamaC,
                decoration: InputDecoration(
                  hintText: "Nama Lengkap",
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z .']")),
                ],
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: controller.manualJabatanC,
                decoration: InputDecoration(
                  hintText: "Jabatan (Opsional)",
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            onPressed: () => controller.setManualInternalDriver(),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
        actionsAlignment: MainAxisAlignment.end,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      barrierDismissible: false,
    );
  }

  void _showDriverSearchSheet(BuildContext context) {
    controller.driverList.clear();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Cari Nama Supir...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true, // Agar tidak terlalu tinggi
              ),
              onChanged: (val) => controller.onSearchDriverChanged(val),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                if (controller.isLoadingDriver.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.driverList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Supir tidak ditemukan?"),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showManualInternalInput(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Tambah Manual (Internal)"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryText,
                            foregroundColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.driverList.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    var employee = controller.driverList[index];
                    return ListTile(
                      dense: true, // Agar list lebih compact
                      contentPadding: EdgeInsets.zero,
                      title: Text(employee.nama ?? "Nama Kosong", style: AppFonts.fUrbanistBold14),
                      subtitle: Text("${employee.nip} - ${employee.jabatan} (${employee.unit})"), // Tampilkan unit juga di list
                      onTap: () {
                        controller.pickDriverFromApi(employee);
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Form Pengeluaran Solar',
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nama Unit"),
            Obx(() => _buildSearchableDropdown(
              hint: "Pilih Unit",
              value: controller.selectedUnit.value?.namaUnit,
              onTap: () => _showUnitSearchSheet(context),
            )),

            _buildLabel("No. IO"),
            _buildTextField(controller: controller.ioController, readOnly: true),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Satuan"),
                      _buildTextField(
                          controller: controller.satuanC,
                          readOnly: true,
                          hint: "-"
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tipe Unit"),
                      _buildTextField(
                          controller: controller.tipeUnitC,
                          readOnly: true,
                          hint: "-"
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // HM/KM Awal & Akhir
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("HM/KM Awal"),
                      _buildTextField(controller: controller.hmKmAwalC, readOnly: true, hint: "0"),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("HM/KM Akhir"),
                      _buildTextField(controller: controller.hmKmAkhirC, readOnly: true, hint: "0"),
                    ],
                  ),
                ),
              ],
            ),

            // Tanggal Awal & Akhir
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tanggal Awal"),
                      Obx(() => _buildTextField(initialValue: controller.dateAwal.value, readOnly: true, hint: "-")),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tanggal Akhir"),
                      Obx(() => _buildTextField(initialValue: controller.dateAkhir.value, readOnly: true, hint: "-")),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Varian"),
                      _buildTextField(controller: controller.varianC, readOnly: true, hint: "0"),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Ratio"),
                      _buildTextField(controller: controller.ratioC, readOnly: true, hint: "0"),
                    ],
                  ),
                ),
              ],
            ),

            _buildLabel("No. Plat Kendaraan"),
            Obx(() => _buildTextField(
              controller: controller.platController,
              readOnly: controller.isPlatReadOnly.value,
            )),

            _buildLabel("Status Supir"),
            Obx(() => _buildStandardDropdown(
              items: controller.statusSupirList,
              value: controller.selectedStatusSupir.value,
              onChanged: (val) => controller.onStatusSupirChanged(val),
              hint: "Pilih Status",
            )),

            _buildLabel("Nama Supir"),
            Obx(() {
              if (controller.selectedStatusSupir.value == 'Eksternal') {
                return _buildTextField(
                  controller: controller.driverNameManualController,
                  hint: "Input Nama Supir Manual",
                );
              } else {
                return _buildSearchableDropdown(
                  hint: "Pilih Supir",
                  value: controller.selectedDriver.value?.nama,
                  onTap: () {
                    if (controller.selectedStatusSupir.value == 'Internal') {
                      _showDriverSearchSheet(context);
                    } else {
                      Get.snackbar("Info", "Pilih Status Supir 'Internal' terlebih dahulu");
                    }
                  },
                );
              }
            }),

            _buildLabel("Km Pengisian"),
            _buildTextField(
              controller: controller.kmPengisianC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hint: "Input KM saat ini",
              customFormatters: [
                SeparatorInputFormatter(),
              ],
            ),

            _buildLabel("Pengisian Solar (Ltr)"),
            _buildTextField(
              controller: controller.pengisianSolarC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hint: "Jumlah liter",
              customFormatters: [
                SeparatorInputFormatter(),
              ],
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: controller.validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Selanjutnya",
                  style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}