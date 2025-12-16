import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_fuel/datas/models/karyawan/karyawan_dbk/karyawan_dbk_list_dto.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../../datas/constant/url_api_static.dart';
import '../../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../../datas/models/master_io/master_io_model.dart';
import '../../../../datas/network/api_client_network.dart';
import '../../../auth/services/login_service.dart';

class PengeluaranApiService {
  final Dio _dio = ApiClientNetwork.dio;

  Options _getOptions() {
    try {
      final loginService = Get.find<LoginService>();
      final auth = loginService.getCurrentAuth();
      final token = auth?.access ?? '';

      return Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    } catch (e) {
      return Options();
    }
  }

  Options _getOptionsDBK() {
    try {
      final token = UrlApiStatic.TOKEN_API_KEY;

      return Options(
        headers: {
          "ApiKey": token,
        },
      );
    } catch (e) {
      return Options();
    }
  }

  Future<List<MasterIoModel>> getMasterIoList() async {
    try {
      final response = await _dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_MASTER_IO_LIST,
        options: _getOptions(),
        queryParameters: {
          'internal_order': null,
          'nama_unit': null,
          'is_active': true,
        },
      );

      if (response.statusCode == 200) {
        List dataRaw;
        if (response.data is List) {
          dataRaw = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          dataRaw = response.data['data'];
        } else {
          dataRaw = [];
        }

        return dataRaw.map((e) => MasterIoModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data unit');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<KaryawanPagedResponse> getEmployees({
    int page = 1,
    int pageSize = 20,
    String? search,
    required String kodeUnit
  }) async {
    final String url = UrlApiStatic.API_END_POINT_DBK + UrlApiStatic.API_GET_EMPLOYEE_DBK;
    print("Requesting URL: $url");

    final response = await _dio.get(
      url,
      options: _getOptionsDBK(),
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'search': search,
        'unit': kodeUnit,
      },
    );

    if (response.statusCode == 200) {
      return KaryawanPagedResponse.fromJson(response.data);
    } else {
      throw Exception('Gagal mengambil data karyawan');
    }
  }

  Future<Map<String, dynamic>> createInboundFot({
    required Map<String, dynamic> payloadMap,
    required List<File?> photos,
  }) async {
    try {
      // 1. Convert Payload Map ke JSON String
      String jsonPayload = jsonEncode(payloadMap);

      // 2. Siapkan FormData
      FormData formData = FormData.fromMap({
        'payload': jsonPayload, // Key 'payload' berisi JSON String
      });

      // 3. Attach Foto (foto1, foto2, foto3)
      for (int i = 0; i < photos.length; i++) {
        if (photos[i] != null && photos[i]!.existsSync()) {
          formData.files.add(MapEntry(
            'foto${i + 1}',
            await MultipartFile.fromFile(
              photos[i]!.path,
              filename: photos[i]!.path.split('/').last,
            ),
          ));
        }
      }

      print("🚀 HIT API: ${UrlApiStatic.API_CREATE_INBOUND_FOT}");
      print("📦 Payload: $jsonPayload");

      final response = await _dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_INBOUND_FOT,
        data: formData,
        options: _getOptions(),
      );

      // 5. Handle Response
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow; // Lempar error ke Controller untuk dihandle
    }
  }

  Future<List<KonfigurasiApprovalModel>> getKonfigurasiApproval({
    required String transactionType,
    required String kodeUnit,
    required bool statusActive,
  }) async {
    try {
      final response = await _dio.get(
        UrlApiStatic.API_GET_KONFIGURASI_APPROVAL_LIST,
        queryParameters: {
          'transaction_type': transactionType,
          'kode_unit': kodeUnit,
          'status_active': statusActive,
        },
        options: _getOptions(),
      );

      List data = response.data;
      return data.map((e) => KonfigurasiApprovalModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createTransactionApproval({
    required String noDoc,
    required String kodeUnit,
    required String transactionType,
  }) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    String url = UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_TRANSACTION_APPROVAL;

    // Payload Sesuai Request Baru
    Map<String, dynamic> payloadData = {
      "no_doc": noDoc,
      "kode_unit": kodeUnit,
      "transaction_type": transactionType,
    };

    print("🔵 [DEBUG] URL Step 3: $url");
    print("🔵 [DEBUG] Payload Step 3: $payloadData");

    try {
      var response = await _dio.post(
        url,
        data: payloadData,
        options: Options(
          contentType: 'application/json',
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateStatusTransactionApproval({
    required String noDoc,
    required String levelApproval,
    required String statusApprove,
    required String catatan,
    required bool isSign,
    required bool isPartnerSign,
  }) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    String endpoint = UrlApiStatic.API_UPDATE_STATUS_TRANSACTION_APPROVAL;
    String url;

    if (endpoint.contains('{no_doc}')) {
      url = UrlApiStatic.API_END_POINT + endpoint.replaceAll('{no_doc}', noDoc);
    } else {
      url = "${UrlApiStatic.API_END_POINT}$endpoint/$noDoc";
    }

    // Payload JSON Murni
    Map<String, dynamic> payloadData = {
      "status_approve": statusApprove,
      "level_approval": levelApproval,
      "catatan": catatan,
      "is_sign": isSign,
      "is_partner_sign": isPartnerSign,
    };

    print("🔵 [DEBUG] URL Step 4 (Update Status): $url");
    print("🔵 [DEBUG] Payload Step 4: $payloadData");

    try {
      var response = await _dio.put(
        url,
        data: payloadData,
        options: Options(
            contentType: 'application/json',
            headers: {
              "Authorization": "Bearer $token",
            }
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        print("❌ [SERVER ERROR] Status: ${e.response?.statusCode}");
        print("❌ [SERVER ERROR] Data: ${e.response?.data}");
      }
      rethrow;
    }
  }

  Future<dynamic> uploadSignatureTransactionApproval({
    required String noDoc,
    required String levelApproval,
    required File imageSign1,
    required File imageSign2,
  }) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    String endpoint = UrlApiStatic.API_POST_SIGNATURE_APPROVAL;
    String url;

    if (endpoint.contains('{no_doc}')) {
      url = UrlApiStatic.API_END_POINT + endpoint.replaceAll('{no_doc}', noDoc);
    } else {
      url = "${UrlApiStatic.API_END_POINT}$endpoint/$noDoc";
    }

    // Gunakan FormData untuk Upload File
    FormData formData = FormData.fromMap({
      'level_approval': levelApproval,
      'image_sign1': await MultipartFile.fromFile(
        imageSign1.path,
        filename: imageSign1.path.split('/').last,
      ),
      'image_sign2': await MultipartFile.fromFile(
        imageSign2.path,
        filename: imageSign2.path.split('/').last,
      ),
    });

    print("🔵 [DEBUG] URL Step 5 (Upload Signature): $url");

    try {
      var response = await _dio.post(
        url,
        data: formData,
        options: Options(
            headers: {
              "Authorization": "Bearer $token",
            }
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        print("❌ [UPLOAD ERROR] Status: ${e.response?.statusCode}");
        print("❌ [UPLOAD ERROR] Data: ${e.response?.data}");
      }
      rethrow;
    }
  }
}