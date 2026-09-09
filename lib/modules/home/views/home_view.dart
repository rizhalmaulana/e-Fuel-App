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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 60),
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
                      style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ),
                  const SizedBox(width: 8),
                  _buildUnitSelector(context),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: AppColors.white, size: 24),
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                _buildProfileAvatar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final isMultiUnit = controller.availableUnits.length > 1;
      final decoration = BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withOpacity(0.3), width: 1),
      );

      Widget unitContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              controller.unitTitle.value,
              style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isMultiUnit) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 16),
          ]
        ],
      );

      if (isMultiUnit) {
        return PopupMenuButton<Map<String, dynamic>>(
          offset: const Offset(0, 35),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (unit) => controller.switchUnit(unit),
          itemBuilder: (context) => controller.availableUnits.map((u) {
            return PopupMenuItem(
              value: u,
              height: 40,
              child: Text("${u['kode_unit']} - ${u['nama_unit']}", style: AppFonts.fUrbanistMedium12),
            );
          }).toList(),
          child: Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: decoration,
            child: unitContent,
          ),
        );
      } else {
        return Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        radius: 20,
        child: Text(controller.profileInitials.value, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
      ),
    );
  }

  Widget _popItem(IconData icon, String label, {Color color = AppColors.darkText}) {
    return Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 12), Text(label, style: AppFonts.fUrbanistMedium14.copyWith(color: color))]);
  }

  Widget _buildTotalVolumeCardSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // (Total Volume)
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Volume",
                        style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 4),
                      Obx(() => FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${TextConvertHelper().formatNumber(controller.totalVolumeDisplay.value)} L",
                          style: AppFonts.fUrbanistBold24.copyWith(color: AppColors.primary),
                        ),
                      )),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // (Pilih Storage)
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pilih Storage",
                        style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 6),
                      _buildCompactCapsuleDropdown(context),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.fieldBackground,
            ),

            Obx(() {
              if (!controller.showOfflineBanner) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 14, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Menampilkan data terakhir tersimpan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.onRefreshData(),
                      child: Text(
                        'Perbarui',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            // List Tank menyamping
            Obx(() {
              final tanks = controller.tankListDisplay.take(2).toList();

              if (tanks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dns_outlined, size: 24, color: AppColors.secondaryText.withOpacity(0.5)),
                      const SizedBox(height: 4),
                      Text(
                        "Tidak ada Tank",
                        style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Row(
                children: tanks.asMap().entries.map((entry) {
                  int index = entry.key;
                  var tank = entry.value;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == tanks.length - 1 ? 0 : 8.0),
                      child: _buildMicroTankItem(tank),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroTankItem(Map<String, String> tankData) {
    String displayVol = tankData['volume'] ?? '0 L';
    String lastUpdate = tankData['last_update'] ?? '-';
    String code = tankData['code'] ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.fieldBackground),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 8, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(lastUpdate, style: AppFonts.fUrbanistRegular10.copyWith(fontSize: 8, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(displayVol, style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCapsuleDropdown(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.storageLocations.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.fieldBackground)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Text("Tidak ada Storage", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText))]),
        );
      }

      String? validValue = controller.storageLocations.contains(controller.selectedStorage.value)
          ? controller.selectedStorage.value
          : controller.storageLocations.first;

      return Container(
        constraints: BoxConstraints(minWidth: 100, maxWidth: screenWidth * 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.fieldBackground)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: validValue,
            isDense: true,
            isExpanded: true,
            dropdownColor: AppColors.white,
            elevation: 4,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.secondaryText),
            style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primaryText),
            onChanged: (val) {
              if (val != null) controller.changeStorageLocation(val);
            },
            items: controller.storageLocations.map((String value) {
              String displayText = value.contains('-') ? value.split('-').last.trim() : value;
              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayText, style: AppFonts.fUrbanistMedium12, maxLines: 1, overflow: TextOverflow.ellipsis),
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
        Color tabColor;
        if (index == 0) {
          tabColor = AppColors.primary;
        } else if (index == 1) {
          tabColor = AppColors.primaryOrange;
        } else {
          tabColor = AppColors.primary;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? tabColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? tabColor : AppColors.fieldBackground),
          ),
          child: Text(
            label,
            style: isSelected ? AppFonts.fUrbanistSemiBold12.copyWith(color: Colors.white) : AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
          ),
        );
      }),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('MENU UTAMA', style: AppFonts.fUrbanistBold14),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.menuList.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: controller.availableMenuTabs.map((tab) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildTabItem(tab['label'], tab['index']),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: Obx(() {
            final displayMenu = controller.filteredMenuList;
            if (displayMenu.isEmpty) {
              return Center(child: Text("Tidak ada menu tersedia", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: displayMenu.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final menu = displayMenu[index];
                return _menuItem(
                    menu['icon'],
                    menu['label'],
                        () => controller.handleMenuTap(menu['action'], context),
                    screenWidth
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _menuItem(String icon, String label, VoidCallback onTap, double screenWidth) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: Center(child: Image.asset(icon, width: 32, height: 32)),
          ),
          const SizedBox(height: 10),
          SizedBox(
              width: (screenWidth * 0.22).clamp(75.0, 100.0),
              child: Text(label, textAlign: TextAlign.center, style: AppFonts.fUrbanistSemiBold10, maxLines: 2, overflow: TextOverflow.ellipsis)
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingTransaction(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                  String sectionTitle = controller.isApprover.value ? 'PROSES APPROVAL' : 'DRAFT TRANSAKSI';
                  return Text(sectionTitle, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText));
                }),
                Obx(() {
                  if (controller.isApprover.value) {
                    return Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.fieldBackground),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedApprovalFilter.value,
                          isDense: true,
                          icon: const Icon(Icons.filter_list, size: 14, color: AppColors.secondaryText),
                          style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primaryText),
                          onChanged: (val) {
                            if (val != null) controller.selectedApprovalFilter.value = val;
                          },
                          items: ['Semua', 'Penerimaan', 'E-BPB'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: AppFonts.fUrbanistMedium10),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.fieldBackground),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedDraftFilter.value,
                          isDense: true,
                          icon: const Icon(Icons.filter_list, size: 14, color: AppColors.secondaryText),
                          style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primaryText),
                          onChanged: (val) {
                            if (val != null) controller.selectedDraftFilter.value = val;
                          },
                          items: ['Semua', 'Penerimaan', 'Pengeluaran'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: AppFonts.fUrbanistMedium10),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final List<Map<String, dynamic>> displayList = controller.isApprover.value
                ? controller.filteredApprovalTransactions
                : controller.filteredOutstandingTransactions;

            if (displayList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 110, width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.fieldBackground.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.fieldBackground)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, color: AppColors.secondaryText, size: 36),
                        const SizedBox(height: 8),
                        Text(
                            controller.isApprover.value
                                ? (controller.selectedApprovalFilter.value != 'Semua' ? "Tidak ada approval ${controller.selectedApprovalFilter.value}" : "Tidak ada transaksi berjalan")
                                : (controller.selectedDraftFilter.value != 'Semua' ? "Tidak ada draft ${controller.selectedDraftFilter.value}" : "Tidak ada transaksi berjalan"),
                            style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final tx = displayList[index];
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 4, right: 8),
                    child: _buildSimpleTransactionCard(
                        tx,
                        screenWidth,
                            () => controller.navigateToTransactionDetail(tx)
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

  Widget _buildSimpleTransactionCard(Map<String, dynamic> tx, double screenWidth, VoidCallback onTap) {
    String noDoc = (tx['noBast'] ?? tx['no_doc'] ?? '-').toString();
    String tanggal = (tx['date'] ?? tx['tanggal'] ?? '-').toString();
    String rawStatus = (tx['status'] ?? 'Draft').toString();
    bool isDraft = rawStatus.toLowerCase() == 'draft';
    String type = tx['type'] ?? '';
    String displayStatus = tx['title'] ?? (isDraft ? "Draft Penerimaan" : "Penerimaan");

    Color statusColor;
    if (type == 'EBPB' || type == 'FOT') {
      statusColor = AppColors.primaryOrange;
    } else if (type == 'FIN') {
      statusColor = AppColors.fuelGreen;
    } else {
      statusColor = isDraft ? AppColors.fuelGreen : AppColors.primary;
    }

    Color statusBgColor = statusColor.withOpacity(0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (screenWidth * 0.48).clamp(150.0, 200.0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(displayStatus,
                    style: AppFonts.fUrbanistBold10.copyWith(color: statusColor)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(noDoc, style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.secondaryText),
                    const SizedBox(width: 6),
                    Expanded(child: Text(tanggal, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: AppColors.fieldBackground.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(
                      isDraft ? "Lanjutkan" : "Cek Detail",
                      style: AppFonts.fUrbanistSemiBold12.copyWith(color: statusColor)
                  )
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
                  _buildHeader(context),

                  Transform.translate(
                    offset: const Offset(0, -35),
                    child: Column(
                      children: [
                        _buildTotalVolumeCardSection(context),
                        const SizedBox(height: 16),
                        _buildMenuSection(context),
                        _buildOutstandingTransaction(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}