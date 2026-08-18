import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportTransferController extends GetxController {
  final title = 'Laporan Transfer Solar'.obs;
  final isLoading = false.obs;

  final dateFrom = ''.obs;
  final dateTo = ''.obs;

  final transactionList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    dateFrom.value = DateFormat('dd/MM/yyyy').format(now);
    dateTo.value = DateFormat('dd/MM/yyyy').format(now);
    
    // Load Dummy Data
    _loadDummyData();
  }

  void _loadDummyData() {
    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 800), () {
      transactionList.assignAll([
        {
          'no_doc': 'EXCA MINI 01',
          'date': '26/05/2026',
          'nopol': 'E031ABE001',
          'operator': 'RIJALE',
          'estimasi': 1000.0,
          'aktual': 850.0,
          'status': 'Selesai',
        },
        {
          'no_doc': 'Doc. E021-2-25-2-0724',
          'date': '26/05/2026',
          'nopol': 'EXCA MINI 01',
          'operator': 'RIJALE',
          'estimasi': 1000.0,
          'aktual': 850.0,
          'status': 'Selesai',
        },
      ]);
      isLoading.value = false;
    });
  }

  Future<void> pickDate(BuildContext context, RxString dateObs) async {
    DateTime initialDate = DateTime.now();
    if (dateObs.value.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(dateObs.value);
      } catch (e) {
        // ignore
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF9800), // AppColors.primaryOrange
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateObs.value = DateFormat('dd/MM/yyyy').format(picked);
      _loadDummyData(); // Simulate filter refresh
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
