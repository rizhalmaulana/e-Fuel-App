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

  Widget _buildPhotoBox({
    required int index,
    required String label,
    required IconData iconData, // Menggunakan IconData agar fleksibel
  }) {
    final CapturedImageDetail? imageDetail = controller.photoSlots[index];
    final bool hasImage = imageDetail != null;

    return Expanded(
      child: GestureDetector(
        onTap: controller.isTakingPhoto.value
            ? null
            : () {
          if (!hasImage) {
            controller.takeSpecificPhoto(index);
          } else {
            // Logic preview/hapus bisa ditambahkan, saat ini remove on tap close
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0), // Spacing antar kotak
          height: 100, // Tinggi fix sesuai referensi
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondaryText.withOpacity(0.3),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: hasImage
              ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11), // Radius inner dikurangi sedikit
                child: Image.file(
                  File(imageDetail.tempPath),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => controller.removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.alertSoftRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: AppColors.white),
                  ),
                ),
              )
            ],
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  iconData,
                  size: 28,
                  color: AppColors.secondaryText
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                // Menggunakan font size 10 sesuai referensi agar muat
                style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    controller.manualNamaC.clear();
    controller.manualNipC.clear();
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

  // --- STEP 1: FORM INPUT ---
  Widget _buildStepOneForm(BuildContext context) {
    return SingleChildScrollView(
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
          _buildTextField(
            controller: controller.ioController,
            readOnly: true,
            hint: "Otomatis terisi",
          ),

          _buildLabel("No. Plat Kendaraan"),
          Obx(() => _buildTextField(
            controller: controller.platController,
            readOnly: controller.isPlatReadOnly.value,
            hint: controller.isPlatReadOnly.value ? "Otomatis terisi" : "Masukkan No. Plat Manual",
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
        ],
      ),
    );
  }

  // --- STEP 2: FOTO ---
  Widget _buildStepTwoPhotos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foto Bukti Pengeluaran',
            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 4),
          Text(
            'Silahkan ambil foto sesuai instruksi.',
            style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 20),

          // Layout 3 Kotak Foto Berjajar (Sama seperti PenerimaanSebelumForm)
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPhotoBox(
                index: 0,
                label: 'Bon Solar',
                iconData: Icons.receipt_long_outlined, // Icon Bon
              ),
              _buildPhotoBox(
                index: 1,
                label: 'Tampak Depan',
                iconData: Icons.local_shipping_outlined, // Icon Truk Depan
              ),
              _buildPhotoBox(
                index: 2,
                label: 'Tampak Samping',
                iconData: Icons.local_shipping, // Icon Truk Samping
              ),
            ],
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTakingPhoto = controller.isTakingPhoto.value;

      // Handle back button hardware
      return WillPopScope(
        onWillPop: isTakingPhoto ? () async => false : () async {
          if (controller.currentPage.value > 0) {
            controller.previousStep();
            return false;
          }
          return true;
        },
        child: Stack(
          children: [
            Scaffold(
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
                  onPressed: () {
                    if (isTakingPhoto) return;
                    controller.previousStep();
                  },
                ),
              ),
              body: Column(
                children: [
                  // Content PageView
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(), // Disable swipe manual
                      onPageChanged: controller.onPageChanged,
                      children: [
                        _buildStepOneForm(context), // Halaman 1: Input Data
                        _buildStepTwoPhotos(),      // Halaman 2: Foto
                      ],
                    ),
                  ),

                  // Button Navigasi
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: Obx(() {
                        // Logic Label
                        String label = controller.currentPage.value == 0 ? "Selanjutnya" : "Submit Data";

                        return ElevatedButton(
                          onPressed: controller.nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            label,
                            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Loading overlay saat ambil foto
            if (isTakingPhoto)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryOrange),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}