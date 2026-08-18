import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../services/pengembalian_service.dart';

class PengembalianController extends GetxController {
  final PengembalianService _service = Get.find<PengembalianService>();

  final isLoading = false.obs;
  final transaksiList = <PengembalianSolarModel>[].obs;

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
}
