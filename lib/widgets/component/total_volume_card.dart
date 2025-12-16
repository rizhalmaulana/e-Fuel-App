import 'package:e_fuel/configs/app_icons.dart';
import 'package:flutter/material.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_fonts.dart';

class TotalVolumeCard extends StatelessWidget {
  final String totalVolume;

  final List<Map<String, String>> tankList;

  final List<String> storageLocations;
  final String selectedStorage;
  final ValueChanged<String?> onStorageChanged;
  final bool showDropdown;
  final bool showTotalVolume;

  const TotalVolumeCard({
    super.key,
    required this.totalVolume,
    required this.tankList, // Wajib List
    required this.storageLocations,
    required this.selectedStorage,
    required this.onStorageChanged,
    this.showDropdown = true,
    this.showTotalVolume = true,
  });

  Widget get _tankIcon {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Image.asset(
        AppIcons.icTank2,
        width: 24,
        height: 24,
        color: AppColors.primaryText,
      ),
    );
  }

  List<Widget> _buildDynamicTankList() {
    if (tankList.length == 1) {
      final tank = tankList[0];
      final labelStyle = AppFonts.fUrbanistLight12.copyWith(color: AppColors.primary);
      final valueStyle = AppFonts.fUrbanistSemiBold10.copyWith(color: AppColors.primary);

      return [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                _tankIcon,
                Text(
                  tank['code'] ?? 'Unknown',
                  textAlign: TextAlign.left,
                  style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText),
                ),
              ],
            ),

            const SizedBox(width: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: 'Volume : ', style: labelStyle),
                  TextSpan(text: '${tank['volume']?.replaceAll(' Ltr', '') ?? '0'} Ltr', style: valueStyle),
                ])),
                const SizedBox(height: 4),
                Text.rich(TextSpan(children: [
                  TextSpan(text: 'Tinggi : ', style: labelStyle),
                  TextSpan(text: '${tank['height']?.replaceAll(' cm', '') ?? '0'} cm', style: valueStyle),
                ])),
              ],
            ),
          ],
        )
      ];
    }

    List<Widget> widgets = [];
    for (int i = 0; i < tankList.length; i++) {
      final tank = tankList[i];
      widgets.add(
        Expanded(
          child: _buildTankDetail(
            tankLabel: tank['code'] ?? 'Unknown',
            volume: tank['volume']?.replaceAll(' Ltr', '') ?? '0',
            tinggi: tank['height']?.replaceAll(' cm', '') ?? '0',
          ),
        ),
      );
      if (i < tankList.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 72,
              child: VerticalDivider(width: 1, thickness: 1, color: AppColors.fieldBackground),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildStorageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      height: 48,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: storageLocations.contains(selectedStorage) ? selectedStorage : null,
          hint: Text(selectedStorage, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.white)),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
          isExpanded: true,
          dropdownColor: Colors.white,
          items: storageLocations.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primary),
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return storageLocations.map<Widget>((String value) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.white),
                ),
              );
            }).toList();
          },

          onChanged: onStorageChanged,
        ),
      ),
    );
  }

  Widget _buildTankDetail({
    required String tankLabel,
    required String volume,
    required String tinggi,
  }) {
    final labelStyle = AppFonts.fUrbanistLight12.copyWith(color: AppColors.primary);
    final valueStyle = AppFonts.fUrbanistSemiBold10.copyWith(color: AppColors.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _tankIcon,
            Text(
              tankLabel,
              textAlign: TextAlign.center,
              style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: 'Volume : ', style: labelStyle),
                TextSpan(text: '$volume Ltr', style: valueStyle),
              ])),
              const SizedBox(height: 4),
              Text.rich(TextSpan(children: [
                TextSpan(text: 'Tinggi : ', style: labelStyle),
                TextSpan(text: '$tinggi cm', style: valueStyle),
              ])),
            ]
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final bool hasHeader = showDropdown || showTotalVolume;
    final bool hasHeader = showDropdown;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          if (showDropdown) _buildStorageDropdown(),

          if (hasHeader)
            Divider(
              height: 1,
              color: AppColors.secondaryText.withOpacity(0.1),
              thickness: 1,
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showTotalVolume)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Total Volume',
                        style: AppFonts.fUrbanistSemiBold14,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalVolume Ltr',
                        style: AppFonts.fUrbanistBold16.copyWith(
                            color: AppColors.primary
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),

                if (tankList.isEmpty)
                  Text("Tidak ada data tangki", style: AppFonts.fUrbanistMedium12)
                else
                  Row(
                    mainAxisAlignment: tankList.length == 1
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildDynamicTankList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}