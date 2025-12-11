import 'package:hive/hive.dart';
import '../../tangki/tangki_model.dart';
import '../../tangki/iot_tangki_model.dart';
import '../../tangki/ukuran_standar_tangki_model.dart';

part 'penerimaan_setelah_model.g.dart';

@HiveType(typeId: 16)
class PenerimaanSetelahModel extends HiveObject {
  @HiveField(0)
  String noDoc;

  @HiveField(1)
  List<TangkiModel>? tangkiList;

  @HiveField(2)
  List<IotTangkiModel>? iotTangkiList;

  @HiveField(3)
  List<UkuranStandarTangkiModel>? ukuranStandarList;

  PenerimaanSetelahModel({
    required this.noDoc,
    this.tangkiList,
    this.iotTangkiList,
    this.ukuranStandarList,
  });

  Map<String, dynamic> toApiJson() {
    return {
      "no_doc": noDoc,
      "tanks": tangkiList?.map((e) => e.toApiJson()).toList() ?? [],
      "iot_tanks": iotTangkiList?.map((e) => e.toApiJson()).toList() ?? [],
      "ukuran_standar_tanks": ukuranStandarList?.map((e) => e.toApiJson()).toList() ?? [],
    };
  }
}