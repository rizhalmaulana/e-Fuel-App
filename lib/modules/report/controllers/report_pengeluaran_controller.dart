import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../datas/models/report/report_transaction_model.dart';
import '../../report/services/report_api_service.dart';

class ReportPengeluaranController extends GetxController {
  final ReportApiService _apiService = ReportApiService();

  final String transactionType = 'FOT';
  final title = 'Laporan Pengeluaran'.obs;

  final dateFromC = TextEditingController();
  final dateToC = TextEditingController();

  var isLoading = false.obs;
  var transactionList = <ReportTransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    final past = now.subtract(const Duration(days: 30));
    dateFromC.text = DateFormat('yyyy-MM-dd').format(past);
    dateToC.text = DateFormat('yyyy-MM-dd').format(now);

    fetchTransactions();
  }

  Future<void> pickDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      String newDate = DateFormat('yyyy-MM-dd').format(picked);
      if (controller.text != newDate) {
        controller.text = newDate;

        transactionList.refresh();
        fetchTransactions();
      }
    }
  }

  Future<void> fetchTransactions() async {
    if (isLoading.value) return;
    isLoading.value = true;
    transactionList.clear();

    try {
      var data = await _apiService.getAllTransactions(
        startDate: dateFromC.text,
        endDate: dateToC.text,
        transactionType: transactionType, // 'FOT'
      );
      transactionList.assignAll(data);
    } catch (e) {
      print("Error fetching pengeluaran: $e");
    } finally {
      isLoading.value = false;
    }
  }
}