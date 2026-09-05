import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../services/pengembalian_service.dart';

class PengembalianController extends GetxController {
  final PengembalianService _service = Get.find<PengembalianService>();

  final isLoading = false.obs;
  final transaksiList = <PengembalianSolarModel>[].obs;

  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  
  final startDateFilter = Rxn<DateTime>();
  final endDateFilter = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final data = await _service.getListPengembalian();
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
      Get.snackbar('Error', 'Gagal memuat data pengembalian');
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
