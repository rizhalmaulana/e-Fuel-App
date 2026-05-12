import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_fuel/datas/models/karyawan/karyawan_dbk/karyawan_dbk_list_dto.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../../datas/constant/url_api_static.dart';
import '../../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../../datas/models/master_io/master_io_model.dart';
import '../../../../datas/models/pengeluaran/pengeluaran_daily_model.dart';
import '../../../../datas/models/volume_storage/volume_storage.dart';
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

  Future<List<dynamic>> getUnitsPerArea(String kodeUnit) async {
    try {
      String endpoint = UrlApiStatic.API_GET_UNIT_PER_AREA.replaceAll('{kode_unit}', kodeUnit);
      final response = await _dio.get(
        UrlApiStatic.API_END_POINT + endpoint,
        options: _getOptions(),
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Error getUnitsPerArea: $e");
      return [];
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

  Future<VolumeStorage?> fetchLatestStockStorage({
    required String unitId,
    required String storageCode,
    required String dateLog,
  }) async {
    try {
      final response = await _dio.get(
        UrlApiStatic.API_GET_LATEST_STORAGE_STOCK,
        queryParameters: {
          'kode_unit': unitId,
          'kode_storage': storageCode,
          'date_log': dateLog,
        },
        options: _getOptions(),
      );
      if (response.data != null && response.data.isNotEmpty) {
        Map<String, dynamic> dataMap;
        if (response.data is String) {
          dataMap = jsonDecode(response.data);
        } else {
          dataMap = response.data;
        }
        return VolumeStorage.fromJson(dataMap);
      }
      return null;
    } catch (e) {
      print("Error fetchLatestStockStorage Pengeluaran: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> createInboundOpen({
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

  Future<Map<String, dynamic>> createInboundFot({
    required Map<String, dynamic> payloadMap,
    required List<File?> photos,
  }) async {
    try {
      String jsonPayload = jsonEncode(payloadMap);

      FormData formData = FormData.fromMap({
        'payload': jsonPayload,
      });

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

      final response = await _dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_INBOUND_FOT,
        data: formData,
        options: _getOptions(),
      );

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

  Future<dynamic> createTransactionApproval({
    required String noDoc,
    required String kodeUnit,
    required String transactionType,
  }) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';
    String url = UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_TRANSACTION_APPROVAL;

    Map<String, dynamic> payloadData = {
      "no_doc": noDoc,
      "kode_unit": kodeUnit,
      "transaction_type": transactionType,
    };

    try {
      var response = await _dio.post(
        url,
        data: payloadData,
        options: Options(
          contentType: 'application/json',
          headers: {
            "Authorization": "Bearer $token",
          },
        )
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

    Map<String, dynamic> payloadData = {
      "status_approve": statusApprove,
      "level_approval": levelApproval,
      "catatan": catatan,
      "is_sign": isSign,
      "is_partner_sign": isPartnerSign,
    };

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

  Future<dynamic> uploadImagePengeluaran({
    required String noDoc,
    required File foto1,
    required File foto2,
    required File foto3,
  }) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    String endpoint = UrlApiStatic.API_POST_IMAGE_PENGELUARAN;
    String url;

    // Handle dynamic URL path
    if (endpoint.contains('{no_doc}')) {
      url = UrlApiStatic.API_END_POINT + endpoint.replaceAll('{no_doc}', noDoc);
    } else {
      url = "${UrlApiStatic.API_END_POINT}$endpoint/$noDoc";
    }

    FormData formData = FormData.fromMap({
      'foto1': await MultipartFile.fromFile(
        foto1.path,
        filename: foto1.path.split('/').last,
      ),
      'foto2': await MultipartFile.fromFile(
        foto2.path,
        filename: foto2.path.split('/').last,
      ),
      'foto3': await MultipartFile.fromFile(
        foto3.path,
        filename: foto3.path.split('/').last,
      ),
    });

    try {
      var response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        print("❌ [UPLOAD IMAGE ERROR] Status: ${e.response?.statusCode}");
        print("❌ [UPLOAD IMAGE ERROR] Data: ${e.response?.data}");
      }
      rethrow;
    }
  }

  Future<List<PengeluaranDailyModel>> getDailyTransactions({
    required String dateInbound,
    required String kodeUnit,
  }) async {
    try {
      final response = await _dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_TRANSACTION_PENGELUARAN_DAILY,
        queryParameters: {
          'date_inbound': dateInbound,
          'kode_unit': kodeUnit,
        },
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        List dataRaw = response.data;
        return dataRaw.map((e) => PengeluaranDailyModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching daily transactions: $e");
      return [];
    }
  }

  Future<dynamic> updateAktualLiterPengeluaran({
    required String noDoc,
    required double aktual,
    required double varianLiter,
  }) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    String endpoint = UrlApiStatic.API_POST_ACTUAL_LITER_PENGELUARAN;
    String url;

    if (endpoint.contains('{no_doc}')) {
      url = UrlApiStatic.API_END_POINT + endpoint.replaceAll('{no_doc}', noDoc);
    } else {
      url = "${UrlApiStatic.API_END_POINT}$endpoint/$noDoc";
    }

    Map<String, dynamic> payload = {
      'aktual_liter': aktual,
      'varian_liter': varianLiter
    };

    try {
      var response = await _dio.post(
        url,
        data: payload,
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
        print("❌ [UPDATE ERROR] Status: ${e.response?.statusCode}");
        print("❌ [UPDATE ERROR] Data: ${e.response?.data}");
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTransactionEBPB({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_TRANSACTION_EBPB,
        data: payload,
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ?? 'Gagal membuat BPB',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createTransactionEBPBApproval({
    required String noDoc,
    required String kodeUnit,
  }) async {
    try {
      final response = await _dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_TRANSACTION_EBPB_APPROVAL,
        data: {
          "no_doc": noDoc,
          "kode_unit": kodeUnit,
        },
        options: _getOptions(),
      );
      return response.data;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<dynamic> uploadSignatureEBPB({
    required String noDoc,
    required String levelApproval,
    required File imageSign,
  }) async {
    try {
      String jsonPayload = jsonEncode({
        "no_doc": noDoc,
        "level_approval": levelApproval,
      });

      String safeFileNameDoc = noDoc.replaceAll('/', '_').replaceAll(' ', '');

      FormData formData = FormData.fromMap({
        'payload': jsonPayload,
        'image_sign': await MultipartFile.fromFile(
          imageSign.path,
          filename: 'sign_ebpb_$safeFileNameDoc.png', // Contoh output: sign_ebpb_02_E-BPB_AFDTR_02_2026.png
        ),
      });

      final response = await _dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_UPLOAD_SIGNATURE_EBPB,
        data: formData,
        options: _getOptions(),
      );
      return response.data;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateStatusEBPB({
    required String noDoc,
    required String statusApprove,
    required String levelApproval,
    required String catatan,
    required bool isSign,
  }) async {
    try {
      final response = await _dio.put(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_UPDATE_STATUS_EBPB,
        data: {
          "no_doc": noDoc,
          "status_approve": statusApprove,
          "level_approval": levelApproval,
          "catatan": catatan,
          "is_sign": isSign,
        },
        options: _getOptions(),
      );
      return response.data;
    } on DioException catch (e) {
      rethrow;
    }
  }
}