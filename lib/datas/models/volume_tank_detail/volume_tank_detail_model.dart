import 'package:hive/hive.dart';
import '../storage_to_tank/storage_to_tank_model.dart';
import '../storage_unit/storage_unit_model.dart';

part 'volume_tank_detail_model.g.dart';

@HiveType(typeId: 29)
class VolumeTankDetailModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final StorageUnitModel? unit;

  @HiveField(2)
  final CSTStorageModel? masterStorage;

  @HiveField(3)
  final CSTTankModel? masterSolarTank;

  @HiveField(4)
  final double volume;

  @HiveField(5)
  final double height;

  @HiveField(6)
  final String? createdAt;

  @HiveField(7)
  final String? updatedAt;

  @HiveField(8)
  final int capacity;

  VolumeTankDetailModel({
    required this.id,
    this.unit,
    this.masterStorage,
    this.masterSolarTank,
    required this.volume,
    required this.height,
    this.createdAt,
    this.updatedAt,
    required this.capacity,
  });

  factory VolumeTankDetailModel.fromJson(Map<String, dynamic> json) {
    // Safe type conversion
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return VolumeTankDetailModel(
      id: _toInt(json['id']),
      unit: json['unit'] != null
          ? StorageUnitModel.fromJson(json['unit'])
          : null,
      masterStorage: json['master_storage'] != null
          ? CSTStorageModel.fromJson(json['master_storage'])
          : null,
      masterSolarTank: json['master_solar_tank'] != null
          ? CSTTankModel.fromJson(json['master_solar_tank'])
          : null,
      volume: _toDouble(json['volume']),
      height: _toDouble(json['tinggi']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      capacity: _toInt(json['capacity']),
    );
  }
}