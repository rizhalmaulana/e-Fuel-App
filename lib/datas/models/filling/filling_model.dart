import 'package:hive/hive.dart';

part 'filling_model.g.dart';

@HiveType(typeId: 15)
class FillingModel {
  @HiveField(0)
  final String transactionId;

  @HiveField(1)
  final String storageCode;

  @HiveField(2)
  final String tankCode;

  // Data Sebelum dan Sesudah Manual

  @HiveField(3)
  final double volumeBefore;
  @HiveField(4)
  final double heightBefore;

  @HiveField(5)
  final double volumeAfter;
  @HiveField(6)
  final double heightAfter;

  @HiveField(7)
  final double volumeVariant;
  @HiveField(8)
  final double heightVariant;

  // Data Sebelum dan Sesudah IoT

  @HiveField(9)
  final double? volumeBeforeIoT;
  @HiveField(10)
  final double? heightBeforeIoT;

  @HiveField(11)
  final double? volumeAfterIoT;
  @HiveField(12)
  final double? heightAfterIoT;

  @HiveField(13)
  final double? volumeVariantIoT;
  @HiveField(14)
  final double? heightVariantIoT;

  @HiveField(15)
  final String timestamp;

  @HiveField(16)
  final String? inputType;

  FillingModel({
    required this.transactionId,
    required this.storageCode,
    required this.tankCode,
    required this.volumeBefore,
    required this.heightBefore,
    required this.volumeAfter,
    required this.heightAfter,
    required this.volumeVariant,
    required this.heightVariant,
    this.volumeBeforeIoT,
    this.heightBeforeIoT,
    this.volumeAfterIoT,
    this.heightAfterIoT,
    this.volumeVariantIoT,
    this.heightVariantIoT,
    required this.timestamp,
    this.inputType,
  });
}