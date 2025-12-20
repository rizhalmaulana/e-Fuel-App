import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../datas/models/bon_sementara/bon_sementara_model.dart';
import '../../auth/services/login_service.dart';
import '../services/bon_sementara_local_service.dart';

class PengeluaranBpbHarianController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final BonSementaraLocalService _localService = BonSementaraLocalService();

  var bpbList = <BonSementaraModel>[].obs;
  var filteredBpbList = <BonSementaraModel>[].obs;
  final searchTextC = TextEditingController();
  final Map<String, TextEditingController> costCenterControllers = {};
  final Map<String, TextEditingController> noteControllers = {};

  var isLoading = false.obs;
  var selectedUnitCode = 'E000'.obs;
  var selectedDate = "Pilih Tanggal".obs;
  var totalVolume = 0.0.obs;
  var totalQty = 0.obs;

  TextEditingController getCostCenterController(String io) {
    return costCenterControllers.putIfAbsent(io, () => TextEditingController());
  }

  TextEditingController getNoteController(String io) {
    return noteControllers.putIfAbsent(io, () => TextEditingController());
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserUnitCode();
    loadBpbData();
  }

  void _loadUserUnitCode() {
    final authData = _loginService.getCurrentAuth();
    if (authData != null) {
      selectedUnitCode.value = authData.currentKodeUnit ?? 'Unknown';
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      selectedDate.value = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> loadBpbData() async {
    isLoading.value = true;
    try {
      // Mengambil data dari lokal Hive
      var localData = await _localService.getMasterList();

      // Filter: Hanya tampilkan data yang sudah memiliki Liter (sudah diproses)
      bpbList.value = localData.where((item) => (item.liter ?? 0) > 0).toList();
      filteredBpbList.assignAll(bpbList);
      _calculateTotals();
    } finally {
      isLoading.value = false;
    }
  }

  void searchBpb(String query) {
    if (query.isEmpty) {
      filteredBpbList.assignAll(bpbList);
    } else {
      var result = bpbList.where((item) {
        final io = (item.internalOrder ?? "").toLowerCase();
        final unit = (item.namaUnit ?? "").toLowerCase();
        return io.contains(query.toLowerCase()) || unit.contains(query.toLowerCase());
      }).toList();
      filteredBpbList.assignAll(result);
    }
    _calculateTotals();
  }

  void _calculateTotals() {
    totalQty.value = filteredBpbList.length;
    totalVolume.value = filteredBpbList.fold(0.0, (sum, item) => sum + (item.liter ?? 0.0));
  }
}