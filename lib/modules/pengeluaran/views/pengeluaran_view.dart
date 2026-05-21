import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../datas/models/master_io/master_io_model.dart';
import '../../../helpers/decimal_input_formatter.dart';
import '../../../widgets/component/auto_scroll_text.dart';
import '../controllers/pengeluaran_controller.dart';

class PengeluaranView extends GetView<PengeluaranController> {
  const PengeluaranView({super.key});

  static const Color _colorEditable = AppColors.alertSoftOrangeSecond;
  static const Color _colorReadOnly = AppColors.backgroundGrey;

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
              Text(title,
                  style: AppFonts.fUrbanistBold16
                      .copyWith(color: AppColors.primaryText)),
            ],
          ),
          const SizedBox(height: 12),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
      child: Text(text,
          style: AppFonts.fUrbanistSemiBold12
              .copyWith(color: AppColors.primaryText)),
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
    final Color backgroundColor =
        (readOnly && !forceEditableColor) ? _colorReadOnly : _colorEditable;
    List<TextInputFormatter> formatters = [
      UpperCaseTextFormatter(),
      ...?customFormatters
    ];

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
        hintStyle:
            AppFonts.fUrbanistLight12.copyWith(color: AppColors.secondaryText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryOrange)),
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
      icon:
          const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryOrange),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: _colorEditable,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryOrange)),
      ),
      hint: Text(hint ?? '',
          style: AppFonts.fUrbanistLight12
              .copyWith(color: AppColors.secondaryText)),
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((String item) {
          // Panggil widget running text yang baru kita buat
          return AutoScrollText(
            text: item.toUpperCase(),
            style: AppFonts.fUrbanistRegular12
                .copyWith(color: AppColors.primaryText),
          );
        }).toList();
      },

      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val.toUpperCase(),
              style: AppFonts.fUrbanistRegular12
                  .copyWith(color: AppColors.primaryText),
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSearchableDropdown(
      {required String? value, required VoidCallback onTap, String? hint}) {
    final bool hasValue =
        value != null && value.trim().isNotEmpty && value.trim() != '-';
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
                hasValue ? value!.toUpperCase() : (hint ?? ''),
                style: hasValue
                    ? AppFonts.fUrbanistRegular12
                        .copyWith(color: AppColors.primaryText)
                    : AppFonts.fUrbanistLight12
                        .copyWith(color: AppColors.secondaryText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: AppColors.primaryOrange, size: 20),
          ],
        ),
      ),
    );
  }

  void _showUnitSearchSheet(BuildContext context) {
    if (controller.isTamu) return;
    controller.resetUnitFilters();

    final TextEditingController searchC = TextEditingController();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.78,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Search field
            Obx(() {
              final hasFilter = controller.filterStatusUnit.value != null;
              return TextField(
                controller: searchC,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: AppColors.primaryOrange),
                  hintText: "Cari Nama Unit / No IO / Plat...",
                  hintStyle: AppFonts.fUrbanistLight12,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  suffixIcon: hasFilter
                      ? IconButton(
                          icon: const Icon(Icons.filter_alt_off_rounded,
                              size: 18, color: AppColors.primaryOrange),
                          tooltip: "Reset filter",
                          onPressed: () {
                            searchC.clear();
                            controller.resetUnitFilters();
                          },
                        )
                      : null,
                ),
                onChanged: (val) => controller.searchUnit(val),
              );
            }),

            const SizedBox(height: 12),

            // Label filter
            Text("Filter Status Unit",
                style: AppFonts.fUrbanistSemiBold12
                    .copyWith(color: AppColors.primaryText)),
            const SizedBox(height: 8),

            Obx(() => Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip(
                      label: "Semua",
                      isSelected: controller.filterStatusUnit.value == null,
                      onTap: () => controller.setFilterStatus(null),
                    ),
                    _buildFilterChip(
                      label: "Unit Utama",
                      icon: Icons.star_rounded,
                      color: AppColors.primaryOrange,
                      isSelected: controller.filterStatusUnit.value == 'U',
                      onTap: () => controller.setFilterStatus('U'),
                    ),
                    _buildFilterChip(
                      label: "Unit Pengganti",
                      icon: Icons.swap_horiz_rounded,
                      color: Colors.blueAccent,
                      isSelected: controller.filterStatusUnit.value == 'S',
                      onTap: () => controller.setFilterStatus('S'),
                    ),
                  ],
                )),

            const SizedBox(height: 8),

            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${controller.filteredUnitList.length} unit ditemukan",
                    style: AppFonts.fUrbanistRegular12
                        .copyWith(color: AppColors.secondaryText),
                  ),
                )),

            Divider(color: Colors.grey.shade200, thickness: 1, height: 12),

            Expanded(
              child: Obx(() {
                if (controller.isLoadingUnit.value) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryOrange));
                }
                if (controller.filteredUnitList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text("Unit tidak ditemukan",
                            style: AppFonts.fUrbanistRegular12
                                .copyWith(color: AppColors.secondaryText)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 4, bottom: 20),
                  itemCount: controller.filteredUnitList.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final unit = controller.filteredUnitList[index];
                    final status = (unit.statusUnit ?? '').toUpperCase();
                    final isUtama = status == 'U';
                    final isPengganti = status == 'S';
                    final String namaUnitRaw = unit.namaUnit?.trim() ?? '';
                    final String displayNamaUnit = (namaUnitRaw.isEmpty ||
                            namaUnitRaw == '-' ||
                            namaUnitRaw == '--')
                        ? (unit.description ?? '-')
                        : namaUnitRaw;

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isUtama
                              ? AppColors.primaryOrange.withOpacity(0.12)
                              : isPengganti
                                  ? Colors.blueAccent.withOpacity(0.10)
                                  : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isUtama
                              ? Icons.star_rounded
                              : isPengganti
                                  ? Icons.swap_horiz_rounded
                                  : Icons.directions_car_outlined,
                          size: 18,
                          color: isUtama
                              ? AppColors.primaryOrange
                              : isPengganti
                                  ? Colors.blueAccent
                                  : Colors.grey,
                        ),
                      ),
                      title: Text(displayNamaUnit.toUpperCase(),
                          style: AppFonts.fUrbanistBold14),
                      subtitle: Text(
                        "${unit.noPolisi ?? '-'} • ${unit.internalOrder ?? '-'}",
                        style: AppFonts.fUrbanistRegular12
                            .copyWith(color: Colors.grey),
                      ),
                      trailing: status.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isUtama
                                    ? AppColors.primaryOrange.withOpacity(0.10)
                                    : Colors.blueAccent.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isUtama
                                    ? 'UTAMA'
                                    : isPengganti
                                        ? 'PENGGANTI'
                                        : status,
                                style: AppFonts.fUrbanistSemiBold10.copyWith(
                                  color: isUtama
                                      ? AppColors.primaryOrange
                                      : Colors.blueAccent,
                                ),
                              ),
                            )
                          : null,
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

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    Color color = Colors.grey,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: isSelected ? Colors.white : Colors.grey.shade600),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppFonts.fUrbanistSemiBold12.copyWith(
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMainUnitSearchSheet(BuildContext context) {
    controller.searchMainUnit('');
    final TextEditingController searchC = TextEditingController();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.72,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              "Unit yang Digantikan",
              style: AppFonts.fUrbanistBold16
                  .copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchC,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: AppColors.primaryOrange),
                hintText: "Cari Nama Unit / No IO / Plat...",
                hintStyle: AppFonts.fUrbanistLight12,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) => controller.searchMainUnit(val),
            ),
            const SizedBox(height: 8),
            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${controller.filteredMainUnitList.length} unit utama ditemukan",
                    style: AppFonts.fUrbanistRegular12
                        .copyWith(color: AppColors.secondaryText),
                  ),
                )),
            Divider(color: Colors.grey.shade200, thickness: 1, height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: Colors.blueAccent),
                  const SizedBox(width: 6),
                  Text(
                    "Hanya menampilkan Unit Utama",
                    style: AppFonts.fUrbanistRegular12
                        .copyWith(color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.filteredMainUnitList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text("Unit Utama tidak ditemukan",
                            style: AppFonts.fUrbanistRegular12
                                .copyWith(color: AppColors.secondaryText)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 4, bottom: 20),
                  itemCount: controller.filteredMainUnitList.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final unit = controller.filteredMainUnitList[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded,
                            size: 18, color: AppColors.primaryOrange),
                      ),
                      title: Text(
                        _resolveUnitDisplayName(unit).toUpperCase(),
                        style: AppFonts.fUrbanistBold14,
                      ),
                      subtitle: Text(
                        "${unit.noPolisi ?? '-'} • ${unit.internalOrder ?? '-'}",
                        style: AppFonts.fUrbanistRegular12
                            .copyWith(color: Colors.grey),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'UTAMA',
                          style: AppFonts.fUrbanistSemiBold10
                              .copyWith(color: AppColors.primaryOrange),
                        ),
                      ),
                      onTap: () => controller.onReplacedUnitSelected(unit),
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

  String _resolveUnitDisplayName(MasterIoModel unit) {
    final nama = (unit.namaUnit ?? '').trim();
    if (nama.isEmpty || nama == '-') {
      final desc = (unit.description ?? '').trim();
      if (desc.isNotEmpty) {
        return desc.length > 30 ? '${desc.substring(0, 30)}...' : desc;
      }
      return '-';
    }
    return nama;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text('Form Pengeluaran Solar',
            style: AppFonts.fUrbanistBold18
                .copyWith(color: AppColors.primaryOrange)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundGrey,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.primaryOrange, size: 20),
            onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 0, 24, 30 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: "Jenis Transaksi & Unit",
              icon: Icons.directions_car_filled_rounded,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel("Jenis Pengeluaran"),
                  Obx(() => _buildStandardDropdown(
                        items: controller.jenisBonList,
                        value: controller.selectedJenisBon.value,
                        onChanged: (val) => controller.switchJenisBon(val),
                        hint: "Pilih Jenis",
                      )),
                ]),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _buildLabel("Kategori"),
                          Obx(() => _buildStandardDropdown(
                                items: controller.jenisKategoriList,
                                value:
                                    controller.selectedKategoriKendaraan.value,
                                onChanged: (val) =>
                                    controller.switchKategoriKendaraan(val),
                                hint: "Pilih Kategori",
                              )),
                        ])),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _buildLabel("Kode Kebun/Pabrik"),
                          Obx(() {
                            if (controller.isLoadingUnitsPerArea.value) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryOrange)),
                              );
                            }

                            if (controller.selectedKategoriKendaraan.value!
                                .contains('INTERNAL NON')) {
                              return _buildStandardDropdown(
                                items: controller.listTitleUnitPerArea,
                                value: controller.selectedKodeKebunPabrik.value,
                                onChanged: (val) =>
                                    controller.onKodeKebunPabrikChanged(val),
                                hint: "Pilih Kode",
                              );
                            } else {
                              String val = controller.selectedKodeKebunPabrik.value ?? "-";
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _colorReadOnly,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  val,
                                  style: AppFonts.fUrbanistRegular12
                                      .copyWith(color: AppColors.primaryText),
                                ),
                              );
                            }
                          }),
                        ])),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final unit = controller.selectedUnit.value;
                  final displayNama =
                      unit != null ? _resolveUnitDisplayName(unit) : null;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 4,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Nama Unit"),
                                _buildSearchableDropdown(
                                  hint: "Pilih Unit",
                                  value: displayNama,
                                  onTap: () => _showUnitSearchSheet(context),
                                ),
                              ])),
                      const SizedBox(width: 12),
                      Expanded(
                          flex: 4,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  String tipe = controller.tipeUnit.value
                                          ?.toUpperCase() ??
                                      "";
                                  String label = "No. Kendaraan";
                                  if (tipe == "AB" || tipe == "GS") {
                                    label = "No. Unit";
                                  }
                                  return _buildLabel(label);
                                }),
                                Obx(() => _buildTextField(
                                      controller: controller.platController,
                                      readOnly: controller.isPlatReadOnly.value,
                                      hint: "No. Plat/Unit",
                                    )),
                              ])),
                    ],
                  );
                }),
                Obx(() {
                  if (!controller.isUnitPengganti.value) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_horiz_rounded,
                                size: 16, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Pilih Unit Utama yang digantikan untuk mengambil No. IO-nya.",
                                style: AppFonts.fUrbanistRegular12
                                    .copyWith(color: Colors.blueAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Field: Unit yang Diganti (full width)
                      _buildLabel("Unit yang Diganti"),
                      _buildSearchableDropdown(
                        hint: "Pilih Unit Utama yang Digantikan",
                        value: controller.selectedReplacedUnit.value != null
                            ? _resolveUnitDisplayName(
                                controller.selectedReplacedUnit.value!)
                            : null,
                        onTap: () => _showMainUnitSearchSheet(context),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),

                Obx(() => _buildLabel(
                    controller.isTamu ? "Cost Center" : "No. IO")),
                Obx(() => _buildTextField(
                    controller: controller.ioController,
                    readOnly: controller.isIoReadOnly.value,
                    hint: controller.isTamu ? "Input Cost Center" : "-")),
              ],
            ),

            Obx(() {
              if (controller.isTamu) return const SizedBox.shrink();

              return _buildSectionCard(
                title: "Data HM/KM",
                icon: Icons.speed_rounded,
                children: [
                  Obx(() {
                    if (controller.tipeUnit.value == null) return const SizedBox.shrink();
                    String tipe = controller.tipeUnit.value?.toUpperCase() ?? "";
                    String labelPrefix = (tipe == "AB") ? "HM" : "KM";

                    if (controller.isTipeKendaraan) {
                      return Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              _buildLabel("$labelPrefix Sebelumnya"),
                              _buildTextField(
                                  controller: controller.hmKmAwalC,
                                  readOnly: controller.isHmKmAwalReadOnly.value,
                                  hint: "0",
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                            ])),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              _buildLabel("$labelPrefix Saat ini"),
                              _buildTextField(
                                  controller: controller.hmKmAkhirC,
                                  readOnly: controller.isHmKmAkhirReadOnly.value,
                                  hint: "0",
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                            ])),
                      ]);
                    } else {
                      return Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              _buildLabel("Tanggal Awal"),
                              _buildTextField(
                                  controller: controller.dateAwalC,
                                  readOnly: true,
                                  forceEditableColor: true,
                                  hint: "dd/MM/yyyy",
                                  onTap: () => controller.pickDate(context, true)),
                            ])),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              _buildLabel("Tanggal Akhir"),
                              _buildTextField(
                                  controller: controller.dateAkhirC,
                                  readOnly: true,
                                  forceEditableColor: true,
                                  hint: "dd/MM/yyyy",
                                  onTap: () => controller.pickDate(context, false)),
                            ])),
                      ]);
                    }
                  }),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              String tipe = controller.tipeUnit.value?.toUpperCase() ?? "";
                              String prefix = (tipe == "AB") ? "HM" : "KM";
                              return _buildLabel("Varian $prefix");
                            }),
                            _buildTextField(
                                controller: controller.varianC,
                                readOnly: true,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                hint: "0"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Rasio"),
                            _buildTextField(
                              controller: controller.ratioInput,
                              readOnly: controller.isRatioReadOnly.value,
                              hint: "0",
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              customFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                                DecimalInputFormatter(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  _buildDivider(),

                  Row(
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            _buildLabel("Estimasi Liter"),
                            _buildTextField(
                              controller: controller.pengisianSolarC,
                              readOnly: !controller.isTipeGenset,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              hint: "Input Liter",
                              customFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                                DecimalInputFormatter(),
                              ],
                            ),
                          ])),
                    ],
                  ),
                ],
              );
            }),

            _buildSectionCard(
              title: "Identitas Supir",
              icon: Icons.person_pin_circle_rounded,
              children: [
                Obx(() {
                  String tipe = controller.tipeUnit.value?.toUpperCase() ?? "";
                  String label = "Nama Supir";
                  if (tipe == "AB") label = "Nama Operator";
                  if (tipe == "GS") label = "Pengambil Solar";
                  return _buildLabel(label);
                }),
                _buildTextField(
                    controller: controller.driverNameC,
                    hint: "Input Nama Lengkap"),
                const SizedBox(height: 12),
                _buildLabel("Keterangan"),
                _buildTextField(
                    controller: controller.keteranganC,
                    hint: "Tambahkan Catatan (Opsional)...",
                    maxLines: 1),
                const SizedBox(height: 12),
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildLabel("Foto Odometer (KM Kendaraan)"),

                      // Cek apakah foto sudah diambil
                      if (controller.fotoOdometer.value != null)
                        Stack(
                          children: [
                            Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                                image: DecorationImage(
                                  image:
                                      FileImage(controller.fotoOdometer.value!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: controller.hapusFotoOdometer,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.alertSoftRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            )
                          ],
                        )
                      else
                        InkWell(
                          onTap: controller.takeOdometerPhoto,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundGrey,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOrange
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: AppColors.primaryOrange, size: 28),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    "Ketuk di sini untuk mengambil foto",
                                    style: AppFonts.fUrbanistSemiBold12
                                        .copyWith(color: AppColors.primaryText),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    "Wajib melampirkan foto KM/HM kendaraan",
                                    style: AppFonts.fUrbanistRegular10.copyWith(
                                        color: AppColors.secondaryText),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text("Proses Pengisian",
                    style: AppFonts.fUrbanistBold16
                        .copyWith(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
