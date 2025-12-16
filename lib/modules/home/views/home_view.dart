import 'package:e_fuel/configs/app_icons.dart';
import 'package:e_fuel/widgets/dialog/dialog_on_development.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/component/total_volume_card.dart';
import '../../../widgets/component/transaction_card.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  void _showDevelopmentModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const DialogOnDevelopment();
      },
    );
  }

  Widget _buildPermissionWarning() {
    return Obx(() {
      if (controller.isPermissionComplete) {
        return const SizedBox.shrink();
      }

      // Logic membuat kalimat: "Kamera, Lokasi dan Penyimpanan"
      final list = controller.deniedPermissionsList;
      String deniedText = '';

      if (list.length == 1) {
        deniedText = list.first;
      } else {
        final lastItem = list.last;
        final otherItems = list.sublist(0, list.length - 1).join(', ');
        deniedText = '$otherItems dan $lastItem';
      }

      return GestureDetector(
        onTap: () {
          controller.checkAndRequestPermissions();
        },
        child: Container(
          color: AppColors.alertSoftRed.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.warning, color: AppColors.alertSoftRed, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  // Teks Dinamis
                  'Aplikasi membutuhkan izin $deniedText. Ketuk untuk mengizinkan atau tekan ikon pengaturan.',
                  style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.alertSoftRed),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.alertSoftRed),
                onPressed: () => controller.openAppSettingsPage(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 80),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            const SizedBox(height: 14),

            Obx(() => Text(
              'Hi, ${controller.userName.value}',
              style: AppFonts.fUrbanistBold16.copyWith(
                color: AppColors.white,
              ),
            )),
            const SizedBox(height: 4),
            Obx(() => Text(
              controller.userAddress.value,
              style: AppFonts.fUrbanistMedium12.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            )),
            Obx(() => Text(
              controller.greeting.value,
              style: AppFonts.fUrbanistMedium12.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () { _showDevelopmentModal(Get.context!); },
          child: Row(
            children: [
              Text(
                controller.unitTitle.value,
                style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.white),
              ),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.white),
              onPressed: () {},
            ),

            PopupMenuButton<String>(
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'logout') {
                  controller.logout();
                } else if (value == 'info') {
                  _showDevelopmentModal(Get.context!);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'info',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: AppColors.darkText, size: 20),
                      const SizedBox(width: 12),
                      Text('Info Profile', style: AppFonts.fUrbanistMedium14),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: AppColors.alertSoftRed, size: 20),
                      const SizedBox(width: 12),
                      Text('Keluar', style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.alertSoftRed)),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 18,
                child: Text(
                  controller.profileInitials.value,
                  style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildTotalVolumeCardSection(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0.0, -60.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Obx(() => TotalVolumeCard(
          totalVolume: controller.totalVolumeDisplay.value.toString(),
          tankList: controller.tankListDisplay,
          storageLocations: controller.storageLocations,
          selectedStorage: controller.selectedStorage.value,
          onStorageChanged: controller.changeStorageLocation,
          showDropdown: true,
          showTotalVolume: true,
        )),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final List<Map<String, dynamic>> menus = [
      {
        'icon': AppIcons.icPenerimaan,
        'label': 'Penerimaan',
        'onTap': () => Get.toNamed(Routes.PENERIMAAN_SEBELUM_FORM)
      },
      {
        'icon': AppIcons.icPengeluaran,
        'label': 'Pengeluaran',
        'onTap': () => Get.toNamed(Routes.PENGELUARAN)
      },
      {
        'icon': AppIcons.icPenerimaan2,
        'label': 'Transaksi Penerimaan',
        'onTap': () => _showDevelopmentModal(context)
      },
      {
        'icon': AppIcons.icPenerimaan2,
        'label': 'Transaksi Pengeluaran',
        'onTap': () => _showDevelopmentModal(context)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Menu Utama',
            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: menus.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final menu = menus[index];
              return _buildMenuItem(
                  menu['icon'],
                  menu['label'],
                  onTap: menu['onTap']
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String iconPath, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.fieldBackground),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryText.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: Image.asset(
                  iconPath,
                  color: AppColors.primaryText,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.fUrbanistMedium12.copyWith(
                  color: AppColors.darkText,
                  height: 1.2,
                  fontSize: 11
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingTransaction() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Transaksi',
                  style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final List<Map<String, dynamic>> displayList =
            controller.selectedTransactionTab.value == 0
                ? controller.ongoingTransactions
                : controller.historyTransactions;

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
                          controller.selectedTransactionTab.value == 0
                              ? "Tidak ada transaksi berjalan"
                              : "Belum ada riwayat transaksi",
                          style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final tx = displayList[index];
                  return GestureDetector(
                    onTap: () => controller.navigateToTransactionDetail(tx),
                    child: Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 4, right: 4),
                      child: TransactionCard(transaction: tx),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPermissionWarning(),
              _buildHeader(context),
              _buildTotalVolumeCardSection(context),

              Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  children: [
                    _buildMenuSection(context),
                    _buildOutstandingTransaction(),
                  ],
                ),
              ),

              // SizedBox di bawah dikurangi sedikit karena ada negative margin di atas
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}