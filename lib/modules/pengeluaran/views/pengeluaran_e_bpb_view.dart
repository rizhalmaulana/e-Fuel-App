import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:signature/signature.dart';
import '../controllers/pengeluaran_e_bpb_controller.dart';

class PengeluaranEBpbView extends GetView<PengeluaranEBpbController> {
  const PengeluaranEBpbView({super.key});

  Widget _buildCompactHeader(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.pickDate(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tanggal Transaksi",
                                style: AppFonts.fUrbanistMedium12
                                    .copyWith(color: AppColors.primaryOrange)),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                      controller.selectedDateDisplay.value,
                                      style: AppFonts.fUrbanistBold14.copyWith(
                                          color: AppColors.secondaryText),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.calendar_month,
                                    size: 16, color: AppColors.primaryOrange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Kode Unit",
                              style: AppFonts.fUrbanistMedium12
                                  .copyWith(color: AppColors.primaryOrange)),
                          Text(controller.selectedUnitCode.value,
                              style: AppFonts.fUrbanistBold14
                                  .copyWith(color: AppColors.secondaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Liter",
                              style: AppFonts.fUrbanistMedium12
                                  .copyWith(color: AppColors.primaryOrange)),
                          Text(
                              "${controller.totalVolume.value.toStringAsFixed(0)} Ltr",
                              style: AppFonts.fUrbanistBold14
                                  .copyWith(color: AppColors.secondaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Total Transaksi",
                              style: AppFonts.fUrbanistMedium12
                                  .copyWith(color: AppColors.primaryOrange)),
                          Text("${controller.totalQty.value} Unit",
                              style: AppFonts.fUrbanistBold14
                                  .copyWith(color: AppColors.secondaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  // 1. UPDATE: Tambahkan parameter isAlphaNumeric untuk mengaktifkan validasi Cost Center
  Widget _buildTableInputField(
      {required TextEditingController controller,
      required String hint,
      bool isAlphaNumeric = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        style:
            AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primaryText),
        // Force Uppercase untuk Cost Center
        textCapitalization: isAlphaNumeric
            ? TextCapitalization.characters
            : TextCapitalization.none,
        // Regex validasi hanya angka dan huruf (tanpa spasi dan karakter khusus)
        inputFormatters: isAlphaNumeric
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                UpperCaseTextFormatter(),
                // Menggunakan custom formatter agar saat diketik langsung jadi kapital
              ]
            : [],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppFonts.fUrbanistLight12
              .copyWith(color: AppColors.secondaryText),
          isDense: true,
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: AppColors.secondaryText.withOpacity(0.3))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: AppColors.secondaryText.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryOrange)),
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    // 3. UPDATE: Menggunakan rasio tinggi layar agar responsif di HP yang lebih kecil/besar
    final double tableHeight = MediaQuery.of(context).size.height * 0.5;

    return Container(
      height: tableHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryText.withOpacity(0.2)),
        color: Colors.grey.shade50,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryOrange));
          }
          if (controller.dailyTransactionList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_off_outlined,
                      size: 48, color: AppColors.secondaryText),
                  const SizedBox(height: 12),
                  Text("Belum ada transaksi pengeluaran\npada tanggal ini.",
                      textAlign: TextAlign.center,
                      style: AppFonts.fUrbanistMedium14
                          .copyWith(color: AppColors.secondaryText)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                      onPressed: () => controller.fetchDailyTransactions(),
                      icon: const Icon(Icons.refresh,
                          size: 16, color: AppColors.primaryOrange),
                      label: Text("Muat Ulang",
                          style: AppFonts.fUrbanistBold12
                              .copyWith(color: AppColors.primaryOrange)))
                ],
              ),
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor:
                    MaterialStateProperty.all(AppColors.fieldBackground),
                columnSpacing: 20,
                horizontalMargin: 15,
                dataRowHeight: 60,
                columns: [
                  DataColumn(
                      label: Text("Nama Unit",
                          style: AppFonts.fUrbanistBold12
                              .copyWith(color: AppColors.primaryOrange))),
                  DataColumn(
                      label: Text("Liter",
                          style: AppFonts.fUrbanistBold12
                              .copyWith(color: AppColors.primaryOrange))),
                  DataColumn(
                      label: Text("No. IO",
                          style: AppFonts.fUrbanistBold12
                              .copyWith(color: AppColors.primaryOrange))),
                  DataColumn(
                      label: Text("Cost Center",
                          style: AppFonts.fUrbanistBold12
                              .copyWith(color: AppColors.primaryOrange))),
                  DataColumn(
                      label: Text("Keterangan",
                          style: AppFonts.fUrbanistBold12
                              .copyWith(color: AppColors.primaryOrange))),
                ],
                rows: controller.dailyTransactionList.map((item) {
                  String uniqueKey = item.id.toString();
                  return DataRow(
                    cells: [
                      DataCell(
                        item.kategoriKendaraan == "TMU"
                            ? Center(
                                child: Text("${item.kategoriKendaraan}",
                                    style: AppFonts
                                        .fUrbanistMedium12),
                              )
                            : Center(
                                child: Text(item.namaUnit ?? "-",
                                    style: AppFonts.fUrbanistMedium12),
                              ),
                      ),
                      DataCell(Text("${item.aktualLiter?.toStringAsFixed(0)}",
                          style: AppFonts.fUrbanistMedium12)),
                      DataCell(Text(item.noIo ?? "-",
                          style: AppFonts.fUrbanistMedium12)),
                      DataCell(
                        item.kategoriKendaraan == "TMU"
                            ? Center(
                                child: Text(item.costCenter ?? "-",
                                    style: AppFonts.fUrbanistMedium12),
                              )
                            : Center(
                                child: Text("-",
                                    style: AppFonts.fUrbanistMedium12),
                              ),
                      ),
                      DataCell(
                        Container(
                          width: 160,
                          alignment: Alignment.center,
                          child: _buildTableInputField(
                              controller:
                                  controller.getNoteController(uniqueKey),
                              hint: "Keterangan"),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(children: [
              Text("Total Transaksi",
                  style: AppFonts.fUrbanistRegular12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Obx(() => Text("${controller.totalQty.value}",
                  style: AppFonts.fUrbanistBold18
                      .copyWith(color: AppColors.primaryOrange)))
            ]),
          ),
          Container(
              height: 30,
              width: 1,
              color: AppColors.secondaryText.withOpacity(0.3)),
          Expanded(
            child: Column(children: [
              Text("Total Volume",
                  style: AppFonts.fUrbanistRegular12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Obx(() => Text(
                  "${controller.totalVolume.value.toStringAsFixed(0)} Ltr",
                  style: AppFonts.fUrbanistBold18
                      .copyWith(color: AppColors.primaryOrange)))
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
              border: Border.all(color: AppColors.fieldBackground)),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Dibuat Oleh",
                          style: AppFonts.fUrbanistRegular12
                              .copyWith(color: AppColors.secondaryText)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Obx(() => Text(
                              controller.userName.value.toUpperCase(),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppFonts.fUrbanistBold12
                                  .copyWith(color: AppColors.darkText),
                            )),
                      )
                    ])),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Jabatan",
                          style: AppFonts.fUrbanistRegular12
                              .copyWith(color: AppColors.secondaryText)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Obx(() => Text(
                              controller.userJabatan.value,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppFonts.fUrbanistSemiBold12
                                  .copyWith(color: AppColors.darkText),
                            )),
                      )
                    ])),
          ]),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            child: Text("Tanda Tangan Asst. Traksi",
                style: AppFonts.fUrbanistSemiBold14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
              onTap: () => controller.clearSignature(),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.alertSoftRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text("Hapus",
                      style: AppFonts.fUrbanistSemiBold10
                          .copyWith(color: AppColors.alertSoftRed))))
        ]),
        const SizedBox(height: 10),

        // 2. UPDATE: Mengurangi tinggi (height) signature pad dari 200 ke 150 agar lebih *simple* dan pas di HP kecil.
        Container(
            height: 150,
            decoration: BoxDecoration(
                color: AppColors.fieldBackground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.secondaryText.withOpacity(0.3), width: 1)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Signature(
                    controller: controller.signatureController,
                    backgroundColor: Colors.transparent))),
      ],
    );
  }

  Widget _buildStep1Data(BuildContext context) {
    return Column(
      children: [
        // 1. Konten Scrollable (Header & Table)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildCompactHeader(context),
                const SizedBox(height: 16),
                _buildDataTable(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // 2. Tombol Sticky di Bawah
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text("Proses Tanda Tangan",
                  style:
                      AppFonts.fUrbanistBold16.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Signature(BuildContext context) {
    return Column(
      children: [
        // 1. Konten Scrollable (Summary & Signature)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildSignatureSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // 2. Tombol Sticky di Bawah
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.submitBpb,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text("Submit E-BPB",
                  style:
                      AppFonts.fUrbanistBold16.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (controller.currentStep.value == 1) {
          controller.prevStep();
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Obx(() => Text(
              controller.currentStep.value == 0
                  ? 'Pembuatan E-BPB'
                  : 'Verifikasi E-BPB',
              style: AppFonts.fUrbanistBold18
                  .copyWith(color: AppColors.primaryOrange))),
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.primaryOrange, size: 20),
            onPressed: () {
              if (controller.currentStep.value == 1) {
                controller.prevStep();
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe
          children: [
            _buildStep1Data(context),
            _buildStep2Signature(context),
          ],
        ),
      ),
    );
  }
}

// FORMATTER TAMBAHAN: Untuk mengubah text otomatis menjadi Uppercase secara real-time saat mengetik.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
