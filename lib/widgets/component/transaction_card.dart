import 'package:flutter/material.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_fonts.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const TransactionCard({super.key, required this.transaction});

  Color _getStatusColor(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'selesai':
      case 'approved':
        return AppColors.fuelGreen; // Hijau
      case 'approval_kasie':
      case 'approval_manager':
        return Colors.orange; // Kuning/Orange
      case 'verifikasi_bast':
      case 'verifikasi_pengeluaran':
        return Colors.blueAccent; // Biru Terang
      default:
        return AppColors.secondaryText; // Abu-abu untuk status awal
    }
  }

  @override
  Widget build(BuildContext context) {
    final String rawStatus = (transaction['status'] ?? 'Proses').toString();

    final String noIO = (transaction['noIO'] ?? '-').toString();
    final String noBast = (transaction['noBast'] ?? '-').toString();
    final String unitOrDesc = (transaction['desc'] ?? '-').toString();
    final String platNomer = (transaction['plat'] ?? 'Tidak Ada Plat').toString();
    final String amount = (transaction['amount'] ?? '0 Ltr').toString();
    final String date = (transaction['date'] ?? '-').toString();

    final Color mainColor = transaction['color'] ?? AppColors.primary;
    final String iconPath = transaction['icon'] ?? '';

    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              width: double.infinity,
              color: mainColor.withOpacity(0.1),
              child: Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                        color: _getStatusColor(rawStatus),
                        shape: BoxShape.circle
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // GROUP 1: ID & Unit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: mainColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: iconPath.isNotEmpty
                                  ? Image.asset(iconPath, width: 12, height: 12, color: mainColor)
                                  : Icon(Icons.description, size: 12, color: mainColor),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                noBast,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.darkText),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 12, color: AppColors.secondaryText),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "$unitOrDesc • $platNomer",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Divider Tipis
                    Divider(height: 8, thickness: 0.5, color: Colors.grey.shade200),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              amount,
                              style: AppFonts.fUrbanistBold14.copyWith(color: mainColor),
                            ),
                            Text(
                              date,
                              style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText, fontSize: 10),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.secondaryText.withOpacity(0.5))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}