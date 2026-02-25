import 'package:e_fuel/modules/home/views/home_skeleton_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';

import '../../../helpers/text_convert_helper.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 45),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Obx(() => Text(
                      'Hi, ${controller.userName.value}',
                      style: AppFonts.fUrbanistBold14.copyWith(
                          color: AppColors.white
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ),

                  const SizedBox(width: 8),

                  _buildUnitSelector(),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: AppColors.white, size: 22),
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                _buildProfileAvatar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Obx(() {
      final isMultiUnit = controller.availableUnits.length > 1;

      // Container Style (Lebih tipis)
      final decoration = BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withOpacity(0.3), width: 1),
      );

      // Konten Text Unit
      Widget unitContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              controller.unitTitle.value,
              style: AppFonts.fUrbanistSemiBold12.copyWith(fontSize: 11, color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isMultiUnit) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 14),
          ]
        ],
      );

      // Wrapper agar bisa di-klik jika multi unit
      if (isMultiUnit) {
        return PopupMenuButton<Map<String, dynamic>>(
          offset: const Offset(0, 30),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (unit) => controller.switchUnit(unit),
          itemBuilder: (context) => controller.availableUnits.map((u) {
            return PopupMenuItem(
              value: u,
              height: 40,
              child: Text(
                  "${u['kode_unit']} - ${u['nama_unit']}",
                  style: AppFonts.fUrbanistMedium12
              ),
            );
          }).toList(),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 130),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Padding diperkecil
            decoration: decoration,
            child: unitContent,
          ),
        );
      } else {
        return Container(
          constraints: const BoxConstraints(maxWidth: 130),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Padding diperkecil
          decoration: decoration,
          child: unitContent,
        );
      }
    });
  }

  Widget _buildProfileAvatar() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) => val == 'logout' ? controller.logout() : null,
      itemBuilder: (context) => [
        PopupMenuItem(value: 'info', child: _popItem(Icons.person_outline, 'Info Profile')),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'logout', child: _popItem(Icons.logout, 'Keluar', color: AppColors.alertSoftRed)),
      ],
      child: CircleAvatar(
        backgroundColor: AppColors.white,
        radius: 18,
        child: Text(controller.profileInitials.value, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
      ),
    );
  }

  Widget _popItem(IconData icon, String label, {Color color = AppColors.darkText}) {
    return Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 12), Text(label, style: AppFonts.fUrbanistMedium14.copyWith(color: color))]);
  }

  Widget _buildTotalVolumeCardSection(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0.0, -35.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER (Label & Dropdown)
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
                  _buildCompactCapsuleDropdown(), // Dropdown Storage
                ],
              ),

              const SizedBox(height: 8),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // KIRI: TOTAL VOLUME
                    Expanded(
                      flex: 3,
                      child: Obx(() => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${TextConvertHelper().formatNumber(controller.totalVolumeDisplay.value)} L",
                            style: AppFonts.fUrbanistBold20.copyWith(
                              color: AppColors.primary,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Estimasi Total",
                            style: AppFonts.fUrbanistMedium10.copyWith(
                                color: AppColors.secondaryText
                            ),
                          )
                        ],
                      )),
                    ),

                    // PEMISAH VERTICAL
                    Container(
                      width: 1,
                      color: AppColors.fieldBackground,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),

                    // KANAN: LIST TANK (DYNAMIC VIEW)
                    Expanded(
                      flex: 5,
                      child: Obx(() {
                        final tanks = controller.tankListDisplay;

                        // KONDISI 1: Jika Tidak Ada Tank / List Kosong
                        if (tanks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.dns_outlined, size: 20, color: AppColors.secondaryText.withOpacity(0.5)),
                                const SizedBox(height: 4),
                                Text(
                                  "Tidak ada Tank",
                                  style: AppFonts.fUrbanistMedium10.copyWith(
                                      color: AppColors.secondaryText
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        // KONDISI 2: Jika Tank Ada (Looping max 2 kolom)
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: tanks.take(2).map((tank) {
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
        ),
      ),
    );
  }

  Widget _buildMicroTankItem(Map<String, String> tankData) {
    String displayVol = tankData['volume'] ?? '0 L';
    String lastUpdate = tankData['last_update'] ?? '-';
    String code = tankData['code'] ?? '-';

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Kode Tangki (TANK 01)
          Text(
            code,
            style: AppFonts.fUrbanistMedium10.copyWith(fontSize: 9, color: AppColors.secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Volume
          Text(
            displayVol,
            style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Last Update
          Row(
            children: [
              const Icon(Icons.access_time, size: 8, color: Colors.grey),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  lastUpdate,
                  style: const TextStyle(fontSize: 7, color: Colors.grey),
                  maxLines: 1,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCompactCapsuleDropdown() {
    return Obx(() {
      // 1. Cek Data Kosong
      if (controller.storageLocations.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.fieldBackground),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Tidak ada Storage",
                  style: AppFonts.fUrbanistMedium10
                      .copyWith(color: AppColors.secondaryText)),
            ],
          ),
        );
      }

      // 2. Validasi Value
      String? validValue;
      if (controller.storageLocations
          .contains(controller.selectedStorage.value)) {
        validValue = controller.selectedStorage.value;
      } else {
        validValue = controller.storageLocations.first;
      }

      // 3. Render Dropdown
      return Container(
        // Beri lebar minimum agar area klik luas
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.fieldBackground),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: validValue,
            isDense: true,
            isExpanded: true, // PENTING: Agar teks panjang tidak merusak layout
            dropdownColor: AppColors.white, // Pastikan background putih
            elevation: 4, // Beri bayangan agar terlihat melayang
            icon: const Icon(Icons.keyboard_arrow_down,
                size: 16, color: AppColors.secondaryText),
            style: AppFonts.fUrbanistMedium12
                .copyWith(color: AppColors.primaryText),
            onChanged: (val) {
              print("🖱️ User tap dropdown: $val"); // Debug tap
              if (val != null) {
                controller.changeStorageLocation(val);
              }
            },
            items: controller.storageLocations.map((String value) {
              // Logic parsing tampilan
              String displayText = value;
              if (value.contains('-')) {
                displayText = value.split('-').last.trim();
              }

              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  displayText,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildTabItem(String label, int index) {
    return GestureDetector(
      onTap: () => controller.changeMenuCategory(index),
      child: Obx(() {
        final isSelected = controller.selectedMenuCategory.value == index;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.fieldBackground,
            ),
          ),
          child: Text(
            label,
            style: isSelected
                ? AppFonts.fUrbanistSemiBold12.copyWith(color: Colors.white)
                : AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
          ),
        );
      }),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MENU UTAMA', style: AppFonts.fUrbanistBold14),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildTabItem('Penerimaan', 0),
              const SizedBox(width: 8),
              _buildTabItem('Pengeluaran', 1),
              const SizedBox(width: 8),
              _buildTabItem('Laporan', 2),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 100,
          child: Obx(() {
            final displayMenu = controller.filteredMenuList;

            if (displayMenu.isEmpty) {
              return Center(
                child: Text(
                  "Tidak ada menu tersedia",
                  style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: displayMenu.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final menu = displayMenu[index];
                return _menuItem(
                  menu['icon'],
                  menu['label'],
                      () => controller.handleMenuTap(menu['action'], context),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _menuItem(String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.fieldBackground, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Center(child: Image.asset(icon, width: 35, height: 35)),
          ),
          const SizedBox(height: 8),
          SizedBox(width: 75, child: Text(label, textAlign: TextAlign.center, style: AppFonts.fUrbanistBold10, maxLines: 2)),
        ],
      ),
    );
  }

  Widget _buildOutstandingTransaction() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  // Jika ada data approval, tampilkan 'PROSES APPROVAL', jika tidak tampilkan 'DRAFT TRANSAKSI'
                  String sectionTitle = controller.approvalTransactions.isNotEmpty
                      ? 'PROSES APPROVAL'
                      : 'TRANSAKSI BERJALAN';

                  return Text(
                    sectionTitle,
                    style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Obx(() {
            // Pilih List mana yang memiliki data
            final List<Map<String, dynamic>> displayList = controller.approvalTransactions.isNotEmpty
                ? controller.approvalTransactions
                : controller.outstandingTransactions;

            if (displayList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 100, width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.fieldBackground),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, color: AppColors.secondaryText, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          "Tidak ada transaksi berjalan",
                          style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final tx = displayList[index];
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 4, right: 4),
                    child: _buildSimpleTransactionCard(
                      tx,
                          () => controller.navigateToTransactionDetail(tx),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSimpleTransactionCard(Map<String, dynamic> tx, VoidCallback onTap) {
    String noDoc = (tx['noBast'] ?? tx['no_doc'] ?? '-').toString();
    String tanggal = (tx['date'] ?? tx['tanggal'] ?? '-').toString();
    String rawStatus = (tx['status'] ?? 'Draft').toString();

    // Jika data dari outstanding, tampilkan label "Draft" dengan warna abu-abu kemerahan / orange.
    // Jika dari approval, tetap "Penerimaan" dengan warna primary (biru).
    bool isDraft = rawStatus.toLowerCase() == 'draft';

    String displayStatus = isDraft ? "Draft Penerimaan" : "Penerimaan";
    Color statusColor = isDraft ? AppColors.fuelGreen : AppColors.primary;
    Color statusBgColor = statusColor.withOpacity(0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Status Badge ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                displayStatus,
                style: AppFonts.fUrbanistBold10.copyWith(color: statusColor),
              ),
            ),

            // --- No Doc & Tanggal ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noDoc,
                  style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.secondaryText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tanggal,
                        style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // --- Tombol Cek Detail / Lanjutkan ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.fieldBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  isDraft ? "Lanjutkan" : "Cek Detail",
                  style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.onRefreshData,
          color: AppColors.primary,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const HomeSkeletonView();
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 35),
                        child: _buildHeader(context),
                      ),

                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        child: _buildTotalVolumeCardSection(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Menu & Transaksi
                  _buildMenuSection(context),
                  _buildOutstandingTransaction(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}