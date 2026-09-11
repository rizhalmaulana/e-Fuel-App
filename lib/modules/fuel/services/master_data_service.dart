import 'package:dio/dio.dart';
import 'package:e_fuel/datas/models/inbound/inbound_model.dart';
import 'package:e_fuel/datas/models/storage_to_tank/storage_to_tank_model.dart';
import 'package:e_fuel/datas/models/unit_to_storage/unit_to_storage_model.dart';
import 'package:e_fuel/datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import 'package:get/get.dart';
import '../../../../datas/constant/url_api_static.dart';
import '../../../../datas/network/api_client_network.dart';
import '../../auth/services/login_service.dart';

class MasterDataService {
  final ApiClientNetwork _apiClient = ApiClientNetwork();
  final LoginService _loginService = Get.find<LoginService>();

  Options _getAuthOptionsJson() {
    final auth = _loginService.getCurrentAuth();
    return Options(
      headers: {
        "Authorization": "Bearer ${auth?.access ?? ''}",
        "Content-Type": "application/json",
        "Accept": "application/json", // Penting untuk standar API
      },
    );
  }

  void _logError(String context, dynamic e) {
    if (e is DioException) {
      // Cek jika error murni karena masalah jaringan atau timeout
      bool isNetworkError = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown; // Connection reset by peer sering masuk ke unknown

      if (isNetworkError) {
        print("⚠️ [MasterDataService] Gagal ke server (Timeout), beralih ke data lokal.");
        // Lemparkan custom exception atau kembalikan list kosong
        // agar controller (HomeController) langsung mengeksekusi fallback data lokal.
        throw Exception("NETWORK_TIMEOUT");
      }
    } else {
      print("⚠️ [$context] Unexpected Error: $e");
    }
  }

  Future<List<UnitToStorageModel>> getStorageFromUnit({
    required String unitId,
  }) async {
    try {
      final currentAuth = _loginService.getCurrentAuth();

      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_CHILD_UNIT_TO_STORAGE,
        queryParameters: {
          'unit_id': unitId,
        },
        options: Options(headers: {
          "Authorization": "Bearer ${currentAuth?.access ?? ''}",
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseBody = response.data;
        final singleUnitStorage = UnitToStorageModel.fromJson(responseBody);
        return [singleUnitStorage];
      }
      return [];
    } catch (e) {
      _logError("getStorageFromUnit", e);
      return []; // Return list kosong agar UI tidak crash
    }
  }

  // GET TANK FROM STORAGE
  Future<List<StorageToTankModel>> getTankFromStorage(
      {required String unitId,
      required String storageId,
      String status = 'Y'}) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_CHILD_STORAGE_TO_TANK,
        queryParameters: {
          'unit_id': unitId,
          'storage_id': storageId,
          'status': status,
        },
        options: _getAuthOptionsJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> listData = response.data['data'];
        return listData.map((e) => StorageToTankModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      _logError("getTankFromStorage", e);
      return [];
    }
  }

  Future<List<VolumeTankDetailModel>> getTankDetailFromStorage({
    required String unitId,
    required String storageId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT +
            UrlApiStatic.API_GET_CHILD_DETAIL_STORAGE_TANK,
        queryParameters: {
          'unit_id': unitId,
          'storage_id': storageId,
        },
        options: _getAuthOptionsJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> listData = response.data['data'];
        return listData.map((e) => VolumeTankDetailModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      _logError("GetTankDetail", e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllUnits() async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_UNIT,
        options: _getAuthOptionsJson(),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      _logError("getAllUnits", e);
      return [];
    }
  }

  Future<List<InboundModel>> getInboundOpenList({
    required String kodeUnit,
    String? statusInbound = 'O', // Default Open
    String? docType,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_INBOUND_OPEN_LIST,
        queryParameters: {
          'kode_unit': kodeUnit,
          'status_inbound': statusInbound,
          // 'date_inbound':
          'doc_type': docType
        },
        options: _getAuthOptionsJson(),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((e) => InboundModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      _logError("getInboundOpenList", e);
      return [];
    }
  }

  // GET LITER FROM KALIBRASI
  Future<double?> getLiterFromCalibrationService({
    required int kapasitas,
    required double tinggiMm,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_LITER_KABLIBRASI,
        queryParameters: {
          'capacity': kapasitas,
          'mm_full': (tinggiMm % 1 == 0) ? tinggiMm.toInt() : tinggiMm,
        },
        options: _getAuthOptionsJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['liter'] != null) {
          return (data['liter'] as num).toDouble();
        }
      }
      return null;
    }
    catch (e) {
      _logError("getLiterFromCalibrationService", e);
      return null;
    }
  }
}
