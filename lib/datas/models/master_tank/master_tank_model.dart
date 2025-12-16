import 'package:hive/hive.dart';
import '../storage_unit/storage_unit_model.dart';

part 'master_tank_model.g.dart';

@HiveType(typeId: 23)
class MasterTankModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String kodeTank;
  @HiveField(2)
  final String namaTank;
  @HiveField(3)
  final String tankStatus;
  @HiveField(4)
  final StorageUnitModel? unit;

  MasterTankModel({
    required this.id,
    required this.kodeTank,
    required this.namaTank,
    required this.tankStatus,
    this.unit,
  });

  factory MasterTankModel.fromJson(Map<String, dynamic> json) {
    return MasterTankModel(
      id: json['id'] ?? 0,
      kodeTank: json['kode_tank'] ?? '',
      namaTank: json['nama_tank'] ?? '',
      tankStatus: json['tank_status'] ?? 'N',
      unit: json['unit'] != null
          ? StorageUnitModel.fromJson(json['unit'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "kode_tank": kodeTank,
    "nama_tank": namaTank,
    "tank_status": tankStatus,
    "unit": unit?.toJson(),
  };
}