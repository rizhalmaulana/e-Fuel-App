import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../../../../helpers/connectivity_helper.dart';
import '../../../../helpers/network_error_helper.dart';
import '../../../../widgets/dialog/dialog_flexible.dart';
import '../services/pengembalian_service.dart';

class PengembalianController extends GetxController {
  final PengembalianService _service = Get.find<PengembalianService>();

  final isLoading = false.obs;
  final transaksiList = <PengembalianSolarModel>[].obs;
  final errorMessage = RxnString();
  final isOfflineError = false.obs;

  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  
  final startDateFilter = Rxn<DateTime>();
  final endDateFilter = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData({bool showDialogOnError = true}) async {
    isLoading.value = true;
    errorMessage.value = null;
    isOfflineError.value = false;

    try {
      final netStatus = await ConnectivityHelper.checkNetworkStatus();
      if (netStatus != NetworkCheckStatus.connected) {
        isOfflineError.value = true;
        errorMessage.value = netStatus == NetworkCheckStatus.slowOrUnreachable
            ? 'Sinyal internet terlalu lambat atau tidak merespons. Periksa jaringan Anda lalu coba lagi.'
            : 'Perangkat tidak terhubung ke jaringan internet. Aktifkan Wi-Fi atau data seluler, lalu coba lagi.';
        isLoading.value = false;

        if (showDialogOnError) {
          final retryConnected = await ConnectivityHelper.validateNetwork(
            title: netStatus == NetworkCheckStatus.slowOrUnreachable
                ? 'Jaringan Tidak Stabil'
                : 'Tidak Ada Jaringan',
            message:
                'Gagal memuat data Pengembalian Solar karena tidak ada koneksi internet. Pastikan jaringan Anda aktif, lalu coba lagi.',
          );
          if (retryConnected) {
            await fetchData(showDialogOnError: true);
          }
        }
        return;
      }

      final data = await _service
          .getListPengembalian()
          .timeout(const Duration(seconds: 12));
      // Sort by created_at descending
      data.sort((a, b) {
        try {
          DateTime dateA = DateTime.parse(a.createdAt);
          DateTime dateB = DateTime.parse(b.createdAt);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
      transaksiList.assignAll(data);
    } catch (e) {
      final friendly = NetworkErrorHelper.getFriendlyErrorMessage(e);
      errorMessage.value = friendly;
      isOfflineError.value = friendly.toLowerCase().contains('internet') ||
          friendly.toLowerCase().contains('jaringan') ||
          friendly.toLowerCase().contains('koneksi');

      if (showDialogOnError) {
        DialogFlexible.showInfo(
          title: isOfflineError.value ? 'Tidak Ada Jaringan' : 'Gagal Memuat Data',
          message: friendly,
          color: AppColors.alertSoftRed,
          icon: isOfflineError.value
              ? Icons.wifi_off_rounded
              : Icons.error_outline_rounded,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<PengembalianSolarModel> get filteredTransaksiList {
    var result = transaksiList.toList();

    if (startDateFilter.value != null && endDateFilter.value != null) {
      result = result.where((item) {
        if (item.createdAt.isEmpty) return false;
        try {
          final itemDate = DateTime.parse(item.createdAt);
          final start = startDateFilter.value!;
          final end = endDateFilter.value!.add(const Duration(hours: 23, minutes: 59, seconds: 59));
          return itemDate.isAfter(start.subtract(const Duration(seconds: 1))) && itemDate.isBefore(end.add(const Duration(seconds: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((item) => 
        item.namaUnit.toLowerCase().contains(query) || 
        item.noDoc.toLowerCase().contains(query) ||
        item.kodeUnit.toLowerCase().contains(query)
      ).toList();
    }

    return result;
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      initialDateRange: startDateFilter.value != null && endDateFilter.value != null
          ? DateTimeRange(start: startDateFilter.value!, end: endDateFilter.value!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE67E22), // AppColors.primary (approximate, adjust if needed)
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      startDateFilter.value = picked.start;
      endDateFilter.value = picked.end;
    }
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    startDateFilter.value = null;
    endDateFilter.value = null;
  }
}
