import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:signature/signature.dart';
import '../../../datas/models/pengeluaran/pengeluaran_daily_model.dart';
import '../controllers/pengeluaran_e_bpb_controller.dart';

class PengeluaranEBpbView extends GetView<PengeluaranEBpbController> {
  const PengeluaranEBpbView({super.key});

  Widget _buildStepIndicator() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Obx(() {
        final isStep2 = controller.currentStep.value == 1;
        return Row(
          children: [
            _buildStepPill(
              stepNumber: '1',
              label: 'Daftar Transaksi',
              isActive: !isStep2,
              isCompleted: isStep2,
            ),
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isStep2
                      ? AppColors.primaryOrange
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildStepPill(
              stepNumber: '2',
              label: 'Verifikasi & TTD',
              isActive: isStep2,
              isCompleted: false,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepPill({
    required String stepNumber,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final Color bgColor = isActive || isCompleted
        ? AppColors.primaryOrange
        : Colors.grey.shade200;
    final Color textColor = isActive || isCompleted
        ? AppColors.primaryOrange
        : AppColors.secondaryText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check_circle_outline_rounded,
                  size: 15, color: Colors.white)
              : Text(
                  stepNumber,
                  style: AppFonts.fUrbanistBold12.copyWith(
                    color: isActive ? Colors.white : AppColors.secondaryText,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppFonts.fUrbanistSemiBold12.copyWith(color: textColor),
        ),
      ],
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row Atas: Unit + Selector Tanggal Interaktif + Refresh
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.store_mall_directory_outlined,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Unit Operasional",
                              style: AppFonts.fUrbanistMedium10
                                  .copyWith(color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          controller.selectedUnitTitle.value,
                          style: AppFonts.fUrbanistBold14
                              .copyWith(color: AppColors.primaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => controller.pickDate(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryOrange.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: AppColors.primaryOrange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            controller.selectedDateDisplay.value,
                            style: AppFonts.fUrbanistBold12
                                .copyWith(color: AppColors.primaryOrange),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: controller.isLoading.value
                        ? null
                        : () => controller.fetchDailyTransactions(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 14),
              // Row Bawah: 2 KPI Stat Box
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      icon: Icons.local_gas_station_rounded,
                      label: "Total Aktual Liter",
                      value: "${controller.formattedTotalVolume} Ltr",
                      accentColor: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatBox(
                      icon: Icons.receipt_long_outlined,
                      label: "Total Transaksi",
                      value: "${controller.totalQty.value} Item",
                      accentColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.fUrbanistMedium10
                      .copyWith(color: AppColors.secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppFonts.fUrbanistBold14.copyWith(color: accentColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Obx(() {
      final hasQuery = controller.searchQuery.value.isNotEmpty;
      return TextField(
        controller: controller.searchTextC,
        onChanged: controller.searchBpb,
        style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: "Cari No. Doc, Nama Unit, No. IO, atau Supir...",
          hintStyle: AppFonts.fUrbanistRegular12
              .copyWith(color: AppColors.secondaryText),
          prefixIcon: const Icon(Icons.search,
              size: 18, color: AppColors.primaryOrange),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      size: 18, color: AppColors.secondaryText),
                  onPressed: controller.clearSearch,
                )
              : null,
          isDense: true,
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryOrange),
          ),
        ),
      );
    });
  }

  void _showCostCenterDialog(
      BuildContext context, PengeluaranDailyModel item) {
    String uniqueKey = item.id.toString();
    final editController = TextEditingController(
      text: controller.costCenterControllers[uniqueKey]?.text ??
          (item.costCenter ?? ""),
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Cost Center",
                    style: AppFonts.fUrbanistBold16
                        .copyWith(color: AppColors.primaryOrange),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close,
                        size: 20, color: AppColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "No. Doc: ${item.noDoc ?? '-'}",
                style: AppFonts.fUrbanistMedium12
                    .copyWith(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 16),
              Text(
                "Cost Center",
                style: AppFonts.fUrbanistSemiBold12
                    .copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: editController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  UpperCaseTextFormatter(),
                ],
                style:
                    AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
                decoration: InputDecoration(
                  hintText: "Masukkan Cost Center",
                  hintStyle: AppFonts.fUrbanistRegular12
                      .copyWith(color: AppColors.secondaryText),
                  filled: true,
                  fillColor: AppColors.fieldBackground.withOpacity(0.4),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: AppColors.secondaryText.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: AppColors.secondaryText.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.primaryOrange),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(
                            color: AppColors.secondaryText.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Batal",
                        style: AppFonts.fUrbanistBold14
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        String newText =
                            editController.text.trim().toUpperCase();
                        controller.updateCostCenter(uniqueKey, newText, item);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Simpan",
                        style:
                            AppFonts.fUrbanistBold14.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    int index,
    PengeluaranDailyModel item,
  ) {
    final String uniqueKey = item.id.toString();
    final String noIoVal = (item.noIo ?? '').trim();
    final bool needsCostCenter = noIoVal.isEmpty || noIoVal == '-';
    final String displayCc =
        (controller.costCenterControllers[uniqueKey]?.text ??
                item.costCenter ??
                '')
            .trim();
    final bool isCcMissing = displayCc.isEmpty || displayCc == '-';
    final String kategori = (item.kategoriKendaraan ?? '').toUpperCase();
    final bool isTamu = kategori == 'TMU' || kategori == 'TAMU';
    final String unitDisplay = isTamu
        ? (item.namaUnit != null && item.namaUnit!.trim().isNotEmpty
            ? '${item.namaUnit} ($kategori)'
            : kategori)
        : (item.namaUnit ?? '-');
    final bool isBackdate = item.hasBackdate ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (needsCostCenter && isCcMissing)
              ? AppColors.alertSoftRed.withOpacity(0.45)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card: Index + No. Doc + Badge Aktual Liter (Exact API value)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isBackdate
                  ? AppColors.primaryOrange.withOpacity(0.08)
                  : AppColors.fieldBackground.withOpacity(0.55),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${index + 1}",
                    style: AppFonts.fUrbanistBold12
                        .copyWith(color: AppColors.primaryOrange),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.noDoc ?? '-',
                        style: AppFonts.fUrbanistBold12.copyWith(
                          color: isBackdate
                              ? AppColors.primaryOrange
                              : AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isBackdate)
                        Text(
                          "Transaksi Backdate",
                          style: AppFonts.fUrbanistSemiBold10
                              .copyWith(color: AppColors.primaryOrange),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Aktual Liter persis dari data API tanpa pembulatan
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_gas_station_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${item.aktualLiterDisplay} Ltr",
                        style: AppFonts.fUrbanistBold12
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Card: Info Unit, IO / Cost Center, Supir, dan Input Keterangan
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(Icons.local_shipping_outlined,
                                size: 15, color: AppColors.secondaryText),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nama Unit",
                                  style: AppFonts.fUrbanistRegular10
                                      .copyWith(color: AppColors.secondaryText),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  unitDisplay,
                                  style: AppFonts.fUrbanistBold12
                                      .copyWith(color: AppColors.primaryText),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(Icons.confirmation_num_outlined,
                                size: 15, color: AppColors.secondaryText),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  needsCostCenter ? "Cost Center" : "No. IO",
                                  style: AppFonts.fUrbanistRegular10
                                      .copyWith(color: AppColors.secondaryText),
                                ),
                                const SizedBox(height: 2),
                                if (needsCostCenter)
                                  GestureDetector(
                                    onTap: () =>
                                        _showCostCenterDialog(context, item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCcMissing
                                            ? AppColors.alertSoftRed
                                                .withOpacity(0.1)
                                            : AppColors.primaryOrange
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isCcMissing
                                              ? AppColors.alertSoftRed
                                                  .withOpacity(0.5)
                                              : AppColors.primaryOrange
                                                  .withOpacity(0.5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              isCcMissing
                                                  ? "Isi CC"
                                                  : displayCc,
                                              style: AppFonts.fUrbanistBold10
                                                  .copyWith(
                                                color: isCcMissing
                                                    ? AppColors.alertSoftRed
                                                    : AppColors.primaryOrange,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.edit,
                                            size: 11,
                                            color: isCcMissing
                                                ? AppColors.alertSoftRed
                                                : AppColors.primaryOrange,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    noIoVal,
                                    style: AppFonts.fUrbanistSemiBold12
                                        .copyWith(color: AppColors.primaryText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.namaSupir != null &&
                    item.namaSupir!.trim().isNotEmpty &&
                    item.namaSupir!.trim() != '-') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: AppColors.secondaryText),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.namaSupir!.trim(),
                          style: AppFonts.fUrbanistMedium12
                              .copyWith(color: AppColors.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.getNoteController(uniqueKey),
                  style: AppFonts.fUrbanistRegular12
                      .copyWith(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    hintText: "Tambahkan keterangan (opsional)...",
                    hintStyle: AppFonts.fUrbanistLight12
                        .copyWith(color: AppColors.secondaryText),
                    prefixIcon: const Icon(Icons.edit_note_rounded,
                        size: 18, color: AppColors.secondaryText),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.backgroundGrey.withOpacity(0.45),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.primaryOrange),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListSection(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 64),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryOrange),
                SizedBox(height: 12),
                Text("Memuat transaksi harian..."),
              ],
            ),
          ),
        );
      }

      if (controller.dailyTransactionList.isEmpty) {
        final isFiltering = controller.searchQuery.value.trim().isNotEmpty;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFiltering
                      ? Icons.search_off_rounded
                      : Icons.folder_off_outlined,
                  size: 36,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isFiltering
                    ? "Transaksi tidak ditemukan"
                    : "Belum ada transaksi pengeluaran",
                textAlign: TextAlign.center,
                style: AppFonts.fUrbanistBold14
                    .copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 4),
              Text(
                isFiltering
                    ? "Coba kata kunci pencarian lain atau hapus filter."
                    : "Tidak ada transaksi pada tanggal ${controller.selectedDateDisplay.value}.",
                textAlign: TextAlign.center,
                style: AppFonts.fUrbanistRegular12
                    .copyWith(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: isFiltering
                    ? controller.clearSearch
                    : () => controller.fetchDailyTransactions(),
                icon: Icon(
                  isFiltering ? Icons.clear : Icons.refresh,
                  size: 16,
                  color: AppColors.primaryOrange,
                ),
                label: Text(
                  isFiltering ? "Hapus Pencarian" : "Muat Ulang",
                  style: AppFonts.fUrbanistBold12
                      .copyWith(color: AppColors.primaryOrange),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daftar Transaksi (${controller.dailyTransactionList.length})",
                  style: AppFonts.fUrbanistBold14
                      .copyWith(color: AppColors.primaryText),
                ),
                Text(
                  "Aktual Liter sesuai API",
                  style: AppFonts.fUrbanistMedium10
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.dailyTransactionList.length,
            itemBuilder: (ctx, index) => _buildTransactionCard(
              context,
              index,
              controller.dailyTransactionList[index],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange,
            AppColors.primaryOrange.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ringkasan E-BPB",
                    style:
                        AppFonts.fUrbanistBold14.copyWith(color: Colors.white),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          controller.selectedDateDisplay.value,
                          style: AppFonts.fUrbanistSemiBold10
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Transaksi",
                            style: AppFonts.fUrbanistRegular10
                                .copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${controller.totalQty.value} Item",
                            style: AppFonts.fUrbanistBold18
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Aktual Liter",
                            style: AppFonts.fUrbanistRegular10
                                .copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${controller.formattedTotalVolume} Ltr",
                            style: AppFonts.fUrbanistBold18
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
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
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow("Dibuat Oleh", controller.userName.value.toUpperCase(),
                  isBold: true),
              Divider(height: 18, color: Colors.grey.shade200),
              _buildInfoRow("Jabatan", controller.userJabatan.value),
              Divider(height: 18, color: Colors.grey.shade200),
              _buildInfoRow("Unit", controller.selectedUnitTitle.value),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.draw_rounded,
                          size: 18, color: AppColors.primaryOrange),
                      const SizedBox(width: 8),
                      Text(
                        "Tanda Tangan Asst. Traksi",
                        style: AppFonts.fUrbanistBold14
                            .copyWith(color: AppColors.primaryText),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => controller.clearSignature(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.alertSoftRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Hapus",
                        style: AppFonts.fUrbanistBold10
                            .copyWith(color: AppColors.alertSoftRed),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Silakan bubuhkan tanda tangan pada kotak di bawah ini sebelum submit.",
                style: AppFonts.fUrbanistRegular10
                    .copyWith(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 12),
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryOrange.withOpacity(0.35),
                    width: 1.2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Signature(
                    controller: controller.signatureController,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.fUrbanistRegular12
              .copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: (isBold ? AppFonts.fUrbanistBold12 : AppFonts.fUrbanistSemiBold12)
                .copyWith(color: AppColors.darkText),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Data(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryOrange,
            onRefresh: controller.fetchDailyTransactions,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    if (controller.hasOutstandingPreviousDate.value) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.alertSoftRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.alertSoftRed.withOpacity(0.45)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.alertSoftRed),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.outstandingPreviousMessage.value,
                                style: AppFonts.fUrbanistMedium12
                                    .copyWith(color: AppColors.alertSoftRed),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  _buildCompactHeader(context),
                  const SizedBox(height: 14),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildTransactionListSection(context),
                ],
              ),
            ),
          ),
        ),
        // Sticky Bottom Button
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Proses Tanda Tangan",
                    style:
                        AppFonts.fUrbanistBold16.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Signature(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 18),
                Obx(() => _buildSignatureSection(context)),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: Obx(() => ElevatedButton(
                  onPressed:
                      controller.isSubmitting.value ? null : controller.submitBpb,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Submit E-BPB",
                    style:
                        AppFonts.fUrbanistBold16.copyWith(color: Colors.white),
                  ),
                )),
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
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        appBar: AppBar(
          title: Obx(() => Text(
                controller.currentStep.value == 0
                    ? 'Pembuatan E-BPB'
                    : 'Verifikasi E-BPB',
                style: AppFonts.fUrbanistBold18
                    .copyWith(color: AppColors.primaryOrange),
              )),
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
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            _buildStepIndicator(),
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Data(context),
                  _buildStep2Signature(context),
                ],
              ),
            ),
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
