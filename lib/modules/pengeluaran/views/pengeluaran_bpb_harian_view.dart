import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../controllers/pengeluaran_bpb_harian_controller.dart';

class PengeluaranBpbHarianView extends GetView<PengeluaranBpbHarianController> {
  const PengeluaranBpbHarianView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'BPB Harian',
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
      body: Column(
        children: [
          // Search Bar disamakan posisinya
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: controller.searchTextC,
              onChanged: (value) => controller.searchBpb(value),
              style: AppFonts.fUrbanistMedium14,
              decoration: InputDecoration(
                hintText: "Cari No. IO...",
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryOrange),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    controller.searchTextC.clear();
                    controller.searchBpb("");
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
          const SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildDataTable(context),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => controller.pickDate(Get.context!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tanggal Transaksi", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                    Row(
                      children: [
                        Text(controller.selectedDate.value, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryOrange)),
                        const Icon(Icons.calendar_month, size: 16, color: AppColors.primaryOrange),
                      ],
                    ),
                  ],
                ),
              ),
              _headerItem("Kode Unit", controller.selectedUnitCode.value, cross: CrossAxisAlignment.end),
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
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
            }

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
                            color: AppColors.backgroundField,
                            child: DataTable(
                              headingRowHeight: 45,
                              dataRowHeight: 0,
                              columnSpacing: 20,
                              horizontalMargin: 15,
                              columns: [
                                _column("Nama Unit", width: 80, isLeft: true),
                                _column("Jumlah (Ltr)", width: 90),
                                _column("Satuan", width: 80),
                                _column("No. IO", width: 100),
                                _column("Cost Center", width: 130), // Input
                                _column("Keterangan", width: 150),  // Input
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
                                  _column("Nama Unit", width: 80, isLeft: true),
                                  _column("Jumlah (Ltr)", width: 90),
                                  _column("Satuan", width: 80),
                                  _column("No. IO", width: 100),
                                  _column("Cost Center", width: 130),
                                  _column("Keterangan", width: 150),
                                ],
                                rows: controller.filteredBpbList.map((item) {
                                  return DataRow(
                                    cells: [
                                      _cellItem(item.namaUnit ?? "-", width: 80, isLeft: true),
                                      _cellItem(item.liter?.toStringAsFixed(0) ?? "0", width: 90),
                                      _cellItem(item.satuan ?? "LTR", width: 80),
                                      _cellItem(item.internalOrder ?? "-", width: 100),
                                      // Field Input Cost Center
                                      _cellInput(controller.getCostCenterController(item.internalOrder!), width: 130, hint: "Input CC"),
                                      // Field Input Keterangan
                                      _cellInput(controller.getNoteController(item.internalOrder!), width: 150, hint: "Input Ket"),
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

  DataCell _cellInput(TextEditingController textController, {double? width, String? hint}) => DataCell(
    SizedBox(
      width: width,
      child: TextField(
        controller: textController,
        style: AppFonts.fUrbanistMedium12,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          border: const UnderlineInputBorder(), // Memberikan garis bawah agar terlihat bisa diisi
        ),
      ),
    ),
  );

  DataCell _cellItem(String value, {double? width, bool isLeft = false}) => DataCell(
    SizedBox(
      width: width,
      child: Text(
        value,
        style: AppFonts.fUrbanistMedium12,
        textAlign: isLeft ? TextAlign.left : TextAlign.center,
      ),
    ),
  );

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          "Submit BPB",
          style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}