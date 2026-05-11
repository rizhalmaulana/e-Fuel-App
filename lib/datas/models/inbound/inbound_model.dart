import 'package:e_fuel/datas/models/volume_tangki/tangki_model.dart';

class InboundModel {
  String? noDoc;
  String? dateInbound;
  String? kodeUnit;
  String? storageCode;
  String? storageName;
  String? statusInbound;
  String? noPo;
  double? volumeVendor;
  String? createdBy;
  List<TangkiModel>? tanks;
  List<InboundApproval>? approvals;

  InboundModel({
    this.noDoc,
    this.dateInbound,
    this.kodeUnit,
    this.storageCode,
    this.storageName,
    this.statusInbound,
    this.noPo,
    this.volumeVendor,
    this.createdBy,
    this.tanks,
    this.approvals,
  });

  factory InboundModel.fromJson(Map<String, dynamic> json) {
    return InboundModel(
      noDoc: json['no_doc'],
      dateInbound: json['date_inbound'],
      kodeUnit: json['kode_unit'],
      storageCode: json['storage_code'],
      storageName: json['storage_name'],
      statusInbound: json['status_inbound'],
      noPo: json['no_po'],
      volumeVendor: json['volume_vendor'] != null
          ? (json['volume_vendor'] as num).toDouble()
          : null,
      createdBy: json['created_by'],
      tanks: json['tanks'] != null
          ? (json['tanks'] as List)
          .map((i) => TangkiModel.fromJson(i))
          .toList()
          : [],
      approvals: json['approvals'] != null
          ? (json['approvals'] as List)
          .map((i) => InboundApproval.fromJson(i))
          .toList()
          : [],
    );
  }
}

class InboundApproval {
  int? id;
  String? levelApproval;
  String? statusApprove;
  String? catatan;

  InboundApproval({
    this.id,
    this.levelApproval,
    this.statusApprove,
    this.catatan,
  });

  factory InboundApproval.fromJson(Map<String, dynamic> json) {
    return InboundApproval(
      id: json['id'],
      levelApproval: json['level_approval'],
      statusApprove: json['status_approve'],
      catatan: json['catatan'],
    );
  }
}