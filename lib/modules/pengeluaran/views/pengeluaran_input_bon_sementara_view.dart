import 'package:e_fuel/datas/models/bon_sementara/bon_sementara_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/pengeluaran_input_bon_sementara_controller.dart';

class PengeluaranInputBonSementaraView
    extends GetView<PengeluaranInputBonSementaraController> {
  const PengeluaranInputBonSementaraView({super.key});

  Widget _buildCompactHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shadowColor: AppColors.secondaryText.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.secondaryText.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _headerItem("Hari, Tanggal", "Kamis, 19 Des 2025", cross: CrossAxisAlignment.start),
                  _headerItem("Kode Unit", controller.selectedUnitCode.value, cross: CrossAxisAlignment.end),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, thickness: 0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _headerItem("Total Liter", "${controller.totalVolume.value.toStringAsFixed(0)} Ltr", cross: CrossAxisAlignment.start),
                  _headerItem("Jumlah Unit", controller.totalQty.value.toString(), cross: CrossAxisAlignment.end),
                ],
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _headerItem(String label, String value, {required CrossAxisAlignment cross}) {
    return Column(
      crossAxisAlignment: cross,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 2),
        Text(value, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryOrange)),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondaryText.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Obx(() {
            // Loading State
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryOrange),
                    SizedBox(height: 16),
                    Text("Sinkronisasi data Real Time..."),
                  ],
                ),
              );
            }

            // Table Layout
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sticky Header
                          Container(
                            color: AppColors.fieldBackground,
                            child: DataTable(
                              headingRowHeight: 45,
                              dataRowHeight: 0,
                              columnSpacing: 20,
                              horizontalMargin: 15,
                              columns: [
                                _column("Aksi", width: 40),
                                _column("Nama Unit", width: 120, isLeft: true),
                                _column("Liter", width: 50),
                                _column("No Polisi", width: 80),
                                _column("Selisih HM/KM", width: 90),
                                _column("Selisih Tanggal", width: 92),
                                _column("Ratio", width: 60),
                                _column("Internal Order", width: 100),
                              ],
                              rows: const [],
                            ),
                          ),
                          // Scrollable Body
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowHeight: 0,
                                columnSpacing: 20,
                                horizontalMargin: 15,
                                showCheckboxColumn: false,
                                columns: [
                                  _column("Aksi", width: 40),
                                  _column("Nama Unit", width: 120, isLeft: true),
                                  _column("Liter", width: 50),
                                  _column("No Polisi", width: 80),
                                  _column("Selisih HM/KM", width: 90),
                                  _column("Selisih Tanggal", width: 92),
                                  _column("Ratio", width: 60),
                                  _column("Internal Order", width: 100),
                                ],
                                rows: controller.filteredMasterList.map((item) {
                                  return DataRow(
                                    onSelectChanged: (_) => _showInputDetailDialog(context, item),
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: 40,
                                          child: Icon(
                                            Icons.edit_note_rounded,
                                            color: AppColors.primaryOrange.withOpacity(0.8),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      _cellItem(item.namaUnit ?? "-", width: 120, isLeft: true),
                                      _cellItem(
                                          "${item.liter?.toStringAsFixed(0) ?? "0"} Ltr",
                                          width: 50,
                                          isBold: (item.liter ?? 0) > 0
                                      ),
                                      _cellItem(item.noPolisi?.isNotEmpty == true ? item.noPolisi! : "-", width: 80),
                                      _cellItem(item.hmKmDiff > 0 ? "+${item.hmKmDiff.toStringAsFixed(0)}" : "-", width: 90),
                                      _cellItem(item.dateDiff > 0 ? "${item.dateDiff} Hari" : "-", width: 92),
                                      _cellItem(item.ratio ?? "-", width: 60),
                                      _cellItem(item.internalOrder ?? "-", width: 100),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  DataColumn _column(String label, {double? width, bool isLeft = false}) => DataColumn(
    label: SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: isLeft ? TextAlign.left : TextAlign.center,
        style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryOrange),
      ),
    ),
  );

  DataCell _cellItem(String value, {double? width, bool isLeft = false, bool isBold = false}) => DataCell(
    SizedBox(
      width: width,
      child: Text(
        value,
        style: AppFonts.fUrbanistMedium12.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isBold ? AppColors.primaryOrange : AppColors.primaryText,
        ),
        textAlign: isLeft ? TextAlign.left : TextAlign.center,
      ),
    ),
  );

  void _showInputDetailDialog(BuildContext context, BonSementaraModel item) {
    final nameController = TextEditingController(text: item.namaUnit);
    final kmAwalController = TextEditingController(text: item.hmKmAwal.toString());
    final kmAkhirController = TextEditingController(text: item.hmKmAkhir?.toString() ?? "");

    final dateAwalController = TextEditingController(text: item.dateAwal ?? "");
    final dateAkhirController = TextEditingController(text: item.dateAkhir ?? "");

    final literController = TextEditingController(text: item.liter?.toString() ?? "");
    final operationHoliday = TextEditingController(text: item.opl ?? "");
    final varianController = TextEditingController();
    final ratioController = TextEditingController(text: item.ratio ?? "");

    // Logic penentuan label dinamis
    bool isTypeGS = item.tipe == 'GS';

    Future<void> _selectDate() async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2024),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        dateAkhirController.text = DateFormat('yyyy-MM-dd').format(picked);
      }
    }

    void calculateAutomatedFields() {
      if (!isTypeGS) {
        double kmAwal = double.tryParse(kmAwalController.text) ?? 0;
        double kmAkhir = double.tryParse(kmAkhirController.text) ?? 0;
        double diff = (kmAkhir - kmAwal) > 0 ? (kmAkhir - kmAwal) : 0;
        varianController.text = kmAkhirController.text.isNotEmpty ? diff.toStringAsFixed(0) : "0";

        String ratioStr = ratioController.text.replaceAll(',', '.');
        double ratioValue = double.tryParse(ratioStr) ?? 0;

        if (ratioValue > 0 && diff > 0) {
          double literResult = (item.tipe == 'KD') ? (diff / ratioValue) : (diff * ratioValue);
          literController.text = literResult.toStringAsFixed(0);
        }
      }
    }

    kmAkhirController.addListener(calculateAutomatedFields);
    calculateAutomatedFields();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Penyesuaian Bon", style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryOrange)),
                const SizedBox(height: 20),
                _inputField("Nama Unit IO", controller: nameController, readOnly: true),

                if (isTypeGS) ...[
                  Row(
                    children: [
                      Expanded(child: _inputField("Tanggal Awal", controller: dateAwalController, readOnly: true)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDate,
                          child: AbsorbPointer(
                            child: _inputField("Tanggal Akhir", controller: dateAkhirController),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(child: _inputField("HM/KM Awal", controller: kmAwalController, readOnly: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _inputField("HM/KM Akhir", controller: kmAkhirController, keyboardType: TextInputType.number)),
                    ],
                  ),
                ],

                _inputField("Operasi Libur", controller: operationHoliday, keyboardType: TextInputType.number),
                if (!isTypeGS) _inputField("Varian (Selisih)", controller: varianController, readOnly: true),

                Row(
                  children: [
                    Expanded(child: _inputField("Ratio", controller: ratioController)),
                    const SizedBox(width: 10),
                    Expanded(child: _inputField("Liter", controller: literController, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
                    onPressed: () {
                      // --- VALIDASI PERINGATAN KM AKHIR < KM AWAL ---
                      if (!isTypeGS) {
                        double awal = double.tryParse(kmAwalController.text) ?? 0;
                        double akhir = double.tryParse(kmAkhirController.text) ?? 0;

                        if (akhir < awal && akhir != 0) {
                          Get.snackbar(
                              "Peringatan Input",
                              "KM Akhir ($akhir) tidak boleh lebih kecil dari KM Awal ($awal)",
                              backgroundColor: AppColors.alertSoftRed,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP
                          );
                          return; // Berhenti, jangan simpan
                        }
                      }

                      controller.updateDataBon(
                        item.internalOrder!,
                        double.tryParse(kmAkhirController.text) ?? 0,
                        double.tryParse(literController.text) ?? 0,
                        ratioController.text,
                        dateAkhir: dateAkhirController.text,
                        operationHoliday: operationHoliday.text,
                      );
                      Get.back();
                    },
                    child: Text("Simpan Perubahan", style: AppFonts.fUrbanistSemiBold14.copyWith(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _inputField(String label, {TextEditingController? controller, bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryText)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: AppFonts.fUrbanistRegular12,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: readOnly ? Colors.grey[200] : AppColors.fieldBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.5))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryOrange)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Form Bon Sementara',
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: controller.searchTextC,
              onChanged: (value) => controller.searchBon(value),
              style: AppFonts.fUrbanistMedium14,
              decoration: InputDecoration(
                hintText: "Cari No. IO atau Unit...",
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryOrange),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    controller.searchTextC.clear();
                    controller.searchBon("");
                  },
                ),
                filled: true,
                fillColor: AppColors.fieldBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _buildCompactHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildDataTable(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}