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
  final CSTStorageModel? masterStorage; // Reuse dari file storage_to_tank_model.dart

  @HiveField(3)
  final CSTTankModel? masterSolarTank; // Reuse dari file storage_to_tank_model.dart

  @HiveField(4)
  final double volume;

  @HiveField(5)
  final double height; // Mapping dari JSON "tinggi"

  @HiveField(6)
  final String? createdAt;

  @HiveField(7)
  final String? updatedAt;

  VolumeTankDetailModel({
    required this.id,
    this.unit,
    this.masterStorage,
    this.masterSolarTank,
    required this.volume,
    required this.height,
    this.createdAt,
    this.updatedAt,
  });

  factory VolumeTankDetailModel.fromJson(Map<String, dynamic> json) {
    return VolumeTankDetailModel(
      id: json['id'] ?? 0,

      // Reuse logic parsing Unit
      unit: json['unit'] != null
          ? StorageUnitModel.fromJson(json['unit'])
          : null,

      // Reuse logic parsing Storage
      masterStorage: json['master_storage'] != null
          ? CSTStorageModel.fromJson(json['master_storage'])
          : null,

      // Reuse logic parsing Tank
      masterSolarTank: json['master_solar_tank'] != null
          ? CSTTankModel.fromJson(json['master_solar_tank'])
          : null,

      // Parsing aman ke double (handle integer atau double dari API)
      volume: (json['volume'] is int)
          ? (json['volume'] as int).toDouble()
          : (json['volume'] as double? ?? 0.0),

      height: (json['tinggi'] is int)
          ? (json['tinggi'] as int).toDouble()
          : (json['tinggi'] as double? ?? 0.0),

      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}