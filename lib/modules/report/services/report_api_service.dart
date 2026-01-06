import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../datas/constant/url_api_static.dart';
import '../../../datas/models/report/report_transaction_model.dart';
import '../../../datas/network/api_client_network.dart';
import '../../auth/services/login_service.dart';

class ReportApiService {
  final Dio _dio = ApiClientNetwork.dio;
  final LoginService _loginService = Get.find<LoginService>();

  Future<List<ReportTransactionModel>> getAllTransactions({
    required String startDate,
    required String endDate,
    required String transactionType,
  }) async {
    final auth = _loginService.getCurrentAuth();
    final token = auth?.access ?? '';
    final kodeUnit = auth?.currentKodeUnit ?? '';

    // [DEBUG] Print Parameter
    print("🔵 [API REQUEST] Type: $transactionType | Unit: $kodeUnit | Date: $startDate s/d $endDate");

    try {
      final response = await _dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_ALL_TRANSACTION_LIST,
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
          'kode_unit': kodeUnit,
          'transaction_type': transactionType,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      // [DEBUG] Print Response
      print("🟢 [API RESPONSE] Status: ${response.statusCode}");
      // print("🟢 [API DATA] ${response.data}"); // Uncomment jika ingin liat raw data

      if (response.statusCode == 200) {
        List dataRaw = [];

        // [VALIDASI] Cek struktur JSON (List langsung atau dibungkus "data")
        if (response.data is List) {
          dataRaw = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          dataRaw = response.data['data']; // Jika response: {"data": [...]}
        }

        print("🟢 [API PARSING] Ditemukan ${dataRaw.length} data");

        return dataRaw.map((e) => ReportTransactionModel.fromJson(e)).toList();
      } else {
        print("🔴 [API ERROR] Status Code bukan 200");
        return [];
      }
    } catch (e) {
      print("🔴 [API EXCEPTION] Error fetching report: $e");
      return [];
    }
  }
}