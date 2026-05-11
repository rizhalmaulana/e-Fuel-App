import 'package:get/get.dart';
import '../../report/services/report_api_service.dart';

class ReportDetailPengeluaranController extends GetxController {
  final ReportApiService _apiService = ReportApiService();

  var isLoading = true.obs;
  var detailData = <String, dynamic>{}.obs;
  String noDoc = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['no_doc'] != null) {
      noDoc = args['no_doc'];
      fetchDetail();
    } else {
      Get.back();
      Get.snackbar("Error", "No Dokumen tidak ditemukan");
    }
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    final data = await _apiService.getDetailPengeluaran(noDoc);
    if (data != null) {
      detailData.assignAll(data);
    } else {
      Get.snackbar("Error", "Gagal memuat detail data pengeluaran");
    }
    isLoading.value = false;
  }
}