import 'package:flutter/material.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_fonts.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const TransactionCard({super.key, required this.transaction});

  String _getDisplayStatus(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'proses':
        return 'Pengecekan';
      case 'setelah_pengisian':
        return 'Verifikasi';
      case 'approval':
        return 'Approval';
      case 'selesai':
        return 'Selesai';
      default:
        return rawStatus.replaceAll('_', ' ');
    }
  }

  Color _getStatusColor(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'selesai':
        return AppColors.fuelGreen;
      case 'approval':
        return Colors.orange;
      case 'setelah_pengisian':
        return Colors.blueAccent;
      default: // 'proses'
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String rawStatus = (transaction['status'] ?? 'Proses').toString();
    final String displayStatus = _getDisplayStatus(rawStatus); // Pakai teks yang sudah dipercantik

    final String id = (transaction['id'] ?? '-').toString();
    final String unit = (transaction['unit'] ?? '-').toString();
    final String platNomer = (transaction['plat'] ?? 'Tidak Ada Plat').toString();
    final String amount = (transaction['amount'] ?? '0 Ltr').toString();
    final String date = (transaction['date'] ?? '-').toString();
    final String type = (transaction['type'] ?? 'FIN').toString();

    final Color headerColor = _getStatusColor(rawStatus);
    final IconData statusIcon = rawStatus.toLowerCase() == 'selesai' ? Icons.check_circle : Icons.access_time_filled;
    final IconData typeIcon = type == 'FIN' ? Icons.input : Icons.output;

    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 36,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: headerColor.withOpacity(0.9),
              child: Row(
                children: [
                  Icon(
                    statusIcon,
                    color: AppColors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      displayStatus.toUpperCase(),
                      style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(typeIcon, size: 12, color: AppColors.secondaryText),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                              platNomer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText)
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  amount,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)
                              ),
                              const SizedBox(height: 2),
                              Text(
                                  date,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.fUrbanistLight10.copyWith(color: AppColors.secondaryText)
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.secondaryText),
                        ),
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