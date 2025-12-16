import 'package:e_fuel/datas/models/master_storage/master_storage_model.dart';
import 'package:hive/hive.dart';
import '../storage_unit/storage_unit_model.dart';

part 'unit_to_storage_model.g.dart';

@HiveType(typeId: 24)
class UnitToStorageModel {
  @HiveField(0)
  final StorageUnitModel unit;

  @HiveField(1)
  final List<MasterStorageModel> masterStorage;

  UnitToStorageModel({
    required this.unit,
    required this.masterStorage,
  });

  factory UnitToStorageModel.fromJson(Map<String, dynamic> json) {
    return UnitToStorageModel(
      // Mapping key 'unit'
      unit: StorageUnitModel.fromJson(json['unit'] ?? {}),

      // Mapping key 'master_storage'
      masterStorage: json['master_storage'] != null
          ? (json['master_storage'] as List)
          .map((i) => MasterStorageModel.fromJson(i))
          .toList()
          : [],
    );
  }
}

@HiveType(typeId: 25)
class UnitToStorageItemModel {
  @HiveField(0)
  final String kodeStorage;
  @HiveField(1)
  final String namaStorage;
  @HiveField(2)
  final String status;

  UnitToStorageItemModel({
    required this.kodeStorage,
    required this.namaStorage,
    required this.status,
  });

  factory UnitToStorageItemModel.fromJson(Map<String, dynamic> json) {
    return UnitToStorageItemModel(
      kodeStorage: json['kode_storage'] ?? '',
      namaStorage: json['nama_storage'] ?? '',
      status: json['status'] ?? 'N',
    );
  }
}