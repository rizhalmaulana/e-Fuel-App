import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../../datas/constant/url_api_static.dart';
import '../../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../../datas/models/kategori_kendaraan/master_kategori_kendaraan.dart';
import '../../../../datas/models/master_io/master_io_model.dart';
import '../../../../datas/models/pengeluaran/detail_pengeluaran_model.dart';
import '../../../../datas/models/pengeluaran/pengeluaran_daily_model.dart';
import '../../../../datas/models/pengeluaran/pengeluaran_outstanding_model.dart';
import '../../../../datas/models/volume_storage/volume_storage.dart';
import '../../../../datas/network/api_client_network.dart';
import '../../../auth/services/login_service.dart';

class PengeluaranApiService {
  final ApiClientNetwork _apiClient = ApiClientNetwork();

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

  Future<List<MasterIoModel>> getMasterIoList({String? unitId}) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_MASTER_IO_LIST,
        options: _getOptions(),
        queryParameters: {
          'internal_order': null,
          'unit_id': unitId,
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

        return dataRaw.map((e) {
          String? namaUnit = e['nama_unit'];
          final bool namaKosong = namaUnit == null ||
              namaUnit.toString().trim().isEmpty ||
              namaUnit.toString().trim() == '-' ||
              namaUnit.toString().trim() == '--';
          if (namaKosong) {
            String desc = e['deskripsi_unit'] ?? '';
            if (desc.trim().isNotEmpty) {
              e['nama_unit'] =
                  desc.length > 20 ? '${desc.substring(0, 20)}...' : desc;
            } else {
              e['nama_unit'] = '-';
            }
          }
          return MasterIoModel.fromJson(e);
        }).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getMasterIoList", e);
        return [];
      }
    }
  }

  Future<List<MasterKategoriKendaraan>> getMasterKategoriKendaraan({String? kodeKategori, String? namaKategori, bool? isActive = false}) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_MASTER_KATEGORI_KENDARAAN,
        options: _getOptions(),
        queryParameters: {
          'kode_kategori': null,
          'nama_kategori': null,
          'is_active': true,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> listData = response.data['data'];
        return listData.map((e) => MasterKategoriKendaraan.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getMasterKategoriKendaraan", e);
        return [];
      }
    }
  }

  Future<Map<String, dynamic>?> getMasterIoDetail(String internalOrder) async {
    try {
      String url =
          UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_MASTER_IO_DETAIL;

      final response = await _apiClient.dio.get(
        url,
        queryParameters: {'internal_order': internalOrder},
        options: _getOptions(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getMasterIoDetail", e);
        return null;
      }
    }
  }

  Future<List<dynamic>> getUnitsPerArea(String kodeUnit) async {
    try {
      String endpoint = UrlApiStatic.API_GET_UNIT_PER_AREA
          .replaceAll('{kode_unit}', kodeUnit);

      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + endpoint,
        options: _getOptions(),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getUnitsPerArea", e);
        return [];
      }
    }
  }

  Future<List<MasterIoModel>> getVendorList() async {
    String urlTarget = UrlApiStatic.API_END_POINT +
        UrlApiStatic.API_GET_MASTER_IO_VENDOR_LIST.trim();
    try {
      final response = await _apiClient.dio.get(
        urlTarget,
        options: _getOptions(),
        queryParameters: {
          'is_active': 'true',
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

        return dataRaw.map<MasterIoModel>((e) {
          return MasterIoModel(
            // Trim untuk membersihkan kemungkinan trailing whitespace/tab dari API
            internalOrder: e['internal_order']?.toString().trim(),
            kodeUnit: e['kode_unit']?.toString(),
            namaUnit: e['nama_unit']?.toString(),
            isActive: true,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getVendorList", e);
        return [];
      }
    }
  }

  Future<List<MasterIoModel>> getTamuList(String kodeKategori) async {
    String urlTarget = UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_MASTER_IO_TAMU;

    try {
      final response = await _apiClient.dio.get(
        urlTarget,
        options: _getOptions(),
        queryParameters: {
          'kode_kategori': kodeKategori,
          'is_active': 'true',
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

        return dataRaw.map<MasterIoModel>((e) {
          return MasterIoModel(
            costCenter: e['cost_center']?.toString().trim(),
            namaUnit: e['nama_unit']?.toString(),
            kodeUnit: e['kode_unit']?.toString(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getTamuList", e);
        return [];
      }
    }
  }

  Future<List<KonfigurasiApprovalModel>> getKonfigurasiApproval({
    required String transactionType,
    required String kodeUnit,
    required bool statusActive,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_KONFIGURASI_APPROVAL_LIST,
        queryParameters: {
          'transaction_type': transactionType,
          'kode_unit': kodeUnit,
          'status_active': statusActive,
        },
        options: _getOptions(),
      );

      if (response.statusCode == 200 && response.data != null) {
        List dataRaw;
        if (response.data is List) {
          dataRaw = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          dataRaw = response.data['data'];
        } else {
          dataRaw = [];
        }
        return dataRaw.map<KonfigurasiApprovalModel>((e) => KonfigurasiApprovalModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getKonfigurasiApproval", e);
        return [];
      }
    }
  }

  Future<VolumeStorage?> fetchLatestStockStorage({
    required String unitId,
    required String storageCode,
    String? internalOrder,
    required String dateLog,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_LATEST_STORAGE_STOCK,
        queryParameters: {
          'kode_unit': unitId,
          'kode_storage': storageCode,
          'internal_order': internalOrder,
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
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("fetchLatestStockStorage", e);
        return null;
      }
    }
  }

  Future<Map<String, dynamic>> createInboundOpen({
    required Map<String, dynamic> formMap,
    required List<File?> photos,
  }) async {
    try {
      String jsonPayload = jsonEncode(formMap);
      FormData formData = FormData.fromMap({'payload': jsonPayload});

      for (int i = 0; i < photos.length; i++) {
        if (photos[i] != null && photos[i]!.existsSync()) {
          formData.files.add(MapEntry(
            'foto${i + 1}',
            await MultipartFile.fromFile(photos[i]!.path),
          ));
        }
      }

      final response = await _apiClient.dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_INBOUND_OPEN,
        data: formData,
        options: _getOptions(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("createInboundOpen", e);
        return {};
      }
    }
  }

  Future<Map<String, dynamic>> createInboundFot({
    required Map<String, dynamic> payloadMap,
    required List<File?> photos,
  }) async {
    try {
      String jsonPayload = jsonEncode(payloadMap);
      debugPrint("Json Payload : $jsonPayload");

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

      final response = await _apiClient.dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_INBOUND_FOT,
        data: formData,
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("createInboundFot", e);
        return {};
      }
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
    String url = UrlApiStatic.API_END_POINT +
        UrlApiStatic.API_CREATE_TRANSACTION_APPROVAL;

    Map<String, dynamic> payloadData = {
      "no_doc": noDoc,
      "kode_unit": kodeUnit,
      "transaction_type": transactionType,
    };

    try {
      var response = await _apiClient.dio.post(url,
          data: payloadData,
          options: Options(
            contentType: 'application/json',
            headers: {
              "Authorization": "Bearer $token",
            },
          ));

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("createTransactionApproval", e);
        return {};
      }
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

    String url = UrlApiStatic.API_END_POINT +
        UrlApiStatic.API_UPDATE_STATUS_TRANSACTION_APPROVAL;

    Map<String, dynamic> payloadData = {
      "status_approve": statusApprove,
      "level_approval": levelApproval,
      "catatan": catatan,
      "is_sign": isSign,
      "is_partner_sign": isPartnerSign,
    };

    try {
      var response = await _apiClient.dio.put(
        url,
        queryParameters: {'no_doc': noDoc},
        data: payloadData,
        options: Options(contentType: 'application/json', headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("updateStatusTransactionApproval", e);
        return {};
      }
    }
  }

  Future<dynamic> updateStatusTransactionApprovalBpb({
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

    String url =
        "${UrlApiStatic.API_END_POINT}${UrlApiStatic.API_UPDATE_STATUS_TRANSACTION_APPROVAL_BPB}";

    Map<String, dynamic> payloadData = {
      "status_approve": statusApprove,
      "level_approval": levelApproval,
      "catatan": catatan,
      "is_sign": isSign,
      "is_partner_sign": isPartnerSign,
    };

    try {
      var response = await _apiClient.dio.put(
        url,
        queryParameters: {
          'no_doc': noDoc,
        },
        data: payloadData,
        options: Options(contentType: 'application/json', headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};

    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("updateStatusTransactionApprovalBpb", e);
        return {};
      }
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

    String url =
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_POST_SIGNATURE_APPROVAL;

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
      var response = await _apiClient.dio.post(
        url,
        queryParameters: {'no_doc': noDoc},
        data: formData,
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};

    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("uploadSignatureTransactionApproval", e);
        return {};
      }
    }
  }

  Future<dynamic> uploadImagePengeluaran({
    required String noDoc,
    File? foto1,
    required File foto2,
    required File foto3,
  }) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    String url =
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_POST_IMAGE_PENGELUARAN;

    FormData formData = FormData.fromMap({
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
      var response = await _apiClient.dio.post(
        url,
        queryParameters: {'no_doc': noDoc},
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("uploadImagePengeluaran", e);
        return {};
      }
    }
  }

  Future<List<PengeluaranDailyModel>> getDailyTransactions({
    required String dateInbound,
    required String kodeUnit,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT +
            UrlApiStatic.API_GET_TRANSACTION_PENGELUARAN_DAILY,
        queryParameters: {
          'tanggal_transaksi': dateInbound,
          'kode_unit': kodeUnit,
        },
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        List dataRaw = response.data;
        return dataRaw.map((e) => PengeluaranDailyModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getDailyTransactions", e);
        return [];
      }
    }
  }

  Future<DetailPengeluaranModel?> getDetailPengeluaran(String noDoc) async {
    try {
      final String url =
          UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_DETAIL_PENGELUARAN;
      final response = await _apiClient.dio.get(
        url,
        queryParameters: {'no_doc': noDoc},
        options: _getOptions(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> body =
            response.data is Map ? response.data as Map<String, dynamic> : {};
        final bool success = body['success'] == true;
        if (success && body['data'] != null) {
          return DetailPengeluaranModel.fromJson(
              body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getDetailPengeluaran", e);
        return null;
      }
    }
  }

  Future<List<PengeluaranOutstandingModel>> getOutstandingTransactions() async {
    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT +
            UrlApiStatic.API_GET_OUTSTANDING_INBOUND_OPEN,
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        List dataRaw = response.data;
        return dataRaw
            .map((e) => PengeluaranOutstandingModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("getDetailPengeluaran", e);
        return [];
      }
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

    String url = UrlApiStatic.API_END_POINT +
        UrlApiStatic.API_POST_ACTUAL_LITER_PENGELUARAN;

    Map<String, dynamic> payload = {
      'aktual_liter': aktual,
      'varian_liter': varianLiter
    };

    try {
      var response = await _apiClient.dio.post(
        url,
        queryParameters: {'no_doc': noDoc},
        data: payload,
        options: Options(contentType: 'application/json', headers: {
          "Authorization": "Bearer $token",
        }),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("updateAktualLiterPengeluaran", e);
        return {};
      }
    }
  }

  Future<dynamic> updateAktualLiterPengeluaranBPB({
    required String noDoc,
    required double aktual,
    required double varianLiter,
  }) async {
    final loginService = Get.find<LoginService>();
    final auth = loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    String url =
        "${UrlApiStatic.API_END_POINT}${UrlApiStatic.API_POST_ACTUAL_LITER_PENGELUARAN_BPB}";

    Map<String, dynamic> payload = {
      'aktual_liter': aktual,
      'varian_liter': varianLiter
    };

    try {
      var response = await _apiClient.dio.post(
        url,
        queryParameters: {
          'no_doc': noDoc,
        },
        data: payload,
        options: Options(contentType: 'application/json', headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("updateAktualLiterPengeluaranBPB", e);
        return {};
      }
    }
  }

  Future<Map<String, dynamic>> createTransactionEBPB({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_TRANSACTION_EBPB,
        data: payload,
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("createTransactionEBPB", e);
        return {};
      }
    }
  }

  Future<dynamic> createTransactionEBPBApproval({
    required String noDoc,
    required String kodeUnit,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        UrlApiStatic.API_END_POINT +
            UrlApiStatic.API_CREATE_TRANSACTION_EBPB_APPROVAL,
        data: {
          "no_doc": noDoc,
          "kode_unit": kodeUnit,
        },
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("createTransactionEBPBApproval", e);
        return {};
      }
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
          filename:
              'sign_ebpb_$safeFileNameDoc.png', // Contoh output: sign_ebpb_02_E-BPB_AFDTR_02_2026.png
        ),
      });

      final response = await _apiClient.dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_UPLOAD_SIGNATURE_EBPB,
        data: formData,
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};

    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("uploadSignatureEBPB", e);
        return {};
      }
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
      final response = await _apiClient.dio.put(
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

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};

    } catch (e) {
      if (e is DioException) {
        throw _handleDioError(e);
      } else {
        _logError("updateStatusEBPB", e);
        return {};
      }
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      String serverMsg = "";
      try {
        if (e.response?.data != null && e.response?.data is Map) {
          serverMsg = (e.response?.data['message'] ?? e.response?.data['error'] ?? e.response?.data.toString());
        }
      } catch (_) {}

      if (serverMsg.isNotEmpty && 
          !serverMsg.toLowerCase().contains("html") && 
          !serverMsg.toLowerCase().contains("exception")) {
        return serverMsg;
      }

      switch (e.response!.statusCode) {
        case 400: return 'Permintaan tidak valid, periksa kembali input Anda.';
        case 401: return 'Sesi habis, silakan login kembali.';
        case 403: return 'Akses ditolak oleh server.';
        case 404: return 'Data atau layanan tidak ditemukan.';
        case 422: return 'Data yang diinputkan tidak lengkap atau tidak sesuai.';
        case 500:
        case 502:
        case 503: return 'Server sedang bermasalah atau sibuk. Coba beberapa saat lagi.';
        default: return 'Terjadi kesalahan pada server (Kode: ${e.response!.statusCode}).';
      }
    } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'Waktu koneksi habis. Pastikan sinyal internet stabil dan coba lagi.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    } else {
      return 'Gagal terhubung ke server. Silakan coba lagi.';
    }
  }

  void _logError(String context, dynamic e) {
    print("⚠️ [$context] Unexpected Error: $e");
    
    if (e is! DioException) {
      if (Get.isSnackbarOpen != true) {
        Get.snackbar(
          'Terjadi Kesalahan',
          'Terdapat kendala pada sistem ($context). Silakan coba lagi.',
          backgroundColor: const Color(0xFFE57373),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }
}
