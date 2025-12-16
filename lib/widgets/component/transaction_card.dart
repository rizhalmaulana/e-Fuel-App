import 'package:flutter/material.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_fonts.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const TransactionCard({super.key, required this.transaction});

  String _getDisplayStatus(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'proses':
        return 'Pengecekan';
      case 'pengisian_solar':
      case 'pengisian_solar_pengeluaran': // Handle status baru pengeluaran
        return 'Pengisian';
      case 'setelah_pengisian':
      case 'verifikasi_pengeluaran': // Handle status baru pengeluaran
        return 'Verifikasi';
      case 'verifikasi_bast':
        return 'Pembuatan BAST';
      case 'approval_kasie':
        return 'Apprv. Kasie';
      case 'approval_manager':
        return 'Apprv. Manager';
      case 'selesai':
      case 'approved':
        return 'Selesai';
      default:
        return rawStatus.split('_').map((word) {
          if (word.isNotEmpty) {
            return "${word[0].toUpperCase()}${word.substring(1)}";
          }
          return "";
        }).join(' ');
    }
  }

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
    final String displayStatus = _getDisplayStatus(rawStatus);

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
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      displayStatus.toUpperCase(),
                      style: AppFonts.fUrbanistSemiBold12.copyWith(
                          color: mainColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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