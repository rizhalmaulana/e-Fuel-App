import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:e_fuel/configs/app_config.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../../datas/network/api_client_network.dart'; // Sesuaikan path
import '../../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../../datas/constant/url_api_static.dart';
import '../../../auth/services/login_service.dart';

class PenerimaanApiService {
  final Dio _dio = ApiClientNetwork.dio;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Options _getOptions() {
    try {
      final loginService = Get.find<LoginService>();
      final auth = loginService.getCurrentAuth();
      final token = auth?.access ?? ''; // Sesuaikan field token Anda

      return Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    } catch (e) {
      return Options();
    }
  }

  Future<List<dynamic>> getInboundOpenList({
    required String kodeUnit,
    required String docType,
  }) async {
    try {
      final response = await _dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_INBOUND_OPEN_LIST,
        queryParameters: {
          'kode_unit': kodeUnit,
          'doc_type': docType,
        },
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          return response.data['data'];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error Fetch Inbound List: $e");
      return []; // Return kosong jika error agar tidak crash
    }
  }

  Future<Map<String, dynamic>> submitInboundOpen({
    required Map<String, dynamic> formMap,
    required List<File?> photos,
  }) async {
    try {
      String jsonPayload = jsonEncode(formMap);

      FormData formData = FormData.fromMap({
        'payload': jsonPayload
      });

      for (int i = 0; i < photos.length; i++) {
        if (photos[i] != null && photos[i]!.existsSync()) {
          formData.files.add(MapEntry(
            'foto${i + 1}',
            await MultipartFile.fromFile(photos[i]!.path),
          ));
        }
      }

      final response = await _dio.post(
        UrlApiStatic.API_CREATE_INBOUND_OPEN,
        data: formData,
        options: _getOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? "Respon server sukses namun status false");
      }

    } catch (e) {
      rethrow;
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

  Future<bool> createInboundTank(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        UrlApiStatic.API_CREATE_INBOUND_TANK,
        data: payload,
        options: _getOptions(),
      );

      if (response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? "Gagal menyimpan data tank.");
      }
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

    // Pastikan Anda sudah punya konstanta ini di UrlApiStatic
    // Contoh: static String API_POST_SIGNATURE_APPROVAL = '/e_fuel/transaksi-approval/upload-signature/{no_doc}';
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
      // Biasanya Upload menggunakan POST, sesuaikan jika API Anda menggunakan PUT
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

  Future<dynamic> updateFcmToken(String fcmToken) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    String url = UrlApiStatic.API_END_POINT + UrlApiStatic.API_POST_FCM_TOKEN;
    String deviceId = await _getDeviceId();

    final Map<String, dynamic> dataPayload = {
      "device_id": deviceId,
      "level_approval": auth?.user.otorisasi.first,
      "fcm_token": fcmToken,
      "app_name": AppConfig.appName,
      "version": AppConfig.versionProd,
    };

    print("🔵 [DEBUG] Payload: $dataPayload");

    try {
      var response = await _dio.post(
        url,
        data: dataPayload,
        options: Options(
            contentType: 'application/json',
            headers: {
              "Authorization": "Bearer $token",
            }
        ),
      );
      return response.data;
    } catch (e) {
      print("⚠️ Gagal update FCM token ke server: $e");
    }
  }

  Future<String> _getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        // return "${androidInfo.model} (${androidInfo.id})"; -- "Redmi Note 10 (TP1A.220624.014)"
        return androidInfo.id; //TP1A.220624.014
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? "unknown_ios_id";
      }
    } catch (e) {
      print("Gagal mengambil Device ID: $e");
    }
    return "unknown_device";
  }
}