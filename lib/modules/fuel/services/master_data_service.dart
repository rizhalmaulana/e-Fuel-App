import 'package:dio/dio.dart';
import 'package:e_fuel/datas/models/inbound/inbound_model.dart';
import 'package:e_fuel/datas/models/storage_to_tank/storage_to_tank_model.dart';
import 'package:e_fuel/datas/models/unit_to_storage/unit_to_storage_model.dart';
import 'package:e_fuel/datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import 'package:get/get.dart';
import '../../../../datas/constant/url_api_static.dart';
import '../../auth/services/login_service.dart';

class MasterDataService {
  final Dio _dio = Dio();
  final LoginService _loginService = Get.find<LoginService>();

  MasterDataService() {
    _dio.options.baseUrl = UrlApiStatic.API_END_POINT;
    _dio.options.connectTimeout = const Duration(seconds: 20);
  }

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
      if (e.response != null) {
        String serverMsg = e.response?.data['detail'] ??
            e.response?.data['message'] ??
            e.response?.statusMessage ??
            "Server Error";

        print("⚠️ [$context] Error ${e.response?.statusCode}: $serverMsg");
      } else {
        print("⚠️ [$context] Connection Error: ${e.message}");
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

      final response = await _dio.get(
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
      _logError("GetStorage", e);
      return []; // Return list kosong agar UI tidak crash
    }
  }

  // GET TANK FROM STORAGE
  Future<List<StorageToTankModel>> getTankFromStorage({
    required String unitId,
    required String storageId,
    String status = 'Y'
  }) async {
    try {
      final response = await _dio.get(
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
      _logError("GetTank", e);
      return [];
    }
  }

  Future<List<VolumeTankDetailModel>> getTankDetailFromStorage({
    required String unitId,
    required String storageId,
  }) async {
    try {
      final response = await _dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_CHILD_DETAIL_STORAGE_TANK,
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
      final response = await _dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_UNIT,
        options: _getAuthOptionsJson(),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print("⚠️ Error Get Unit: $e");
      return [];
    }
  }

  Future<List<InboundModel>> getInboundOpenList({
    required String kodeUnit,
    String? statusInbound = 'O', // Default Open
    String? docType,
  }) async {
    try {
      final response = await _dio.get(
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
      _logError("GetInboundOpenList", e);
      return [];
    }
  }

  // GET LITER FROM KALIBRASI
  Future<double?> getLiterFromCalibrationService({
    required int kapasitas,
    required double tinggiMm,
  }) async {
    try {
      final response = await _dio.get(
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

    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final detailMsg = e.response?.data['detail'] ?? "Data kalibrasi tidak ditemukan";

        print("ℹ️ Kalibrasi Info: $detailMsg");
        return null;
      }

      _logError("GetKalibrasi", e);
      return null;

    } catch (e) {
      print("⚠️ Error Get Kalibrasi General: $e");
      return null;
    }
  }
}