class KonfigurasiApprovalModel {
  int? id;
  String? transactionType;
  String? kodeUnit;
  String? levelApproval;
  int? stepApproval;
  bool? statusActive;
  String? createdAt;

  KonfigurasiApprovalModel({
    this.id,
    this.transactionType,
    this.kodeUnit,
    this.levelApproval,
    this.stepApproval,
    this.statusActive,
    this.createdAt,
  });

  factory KonfigurasiApprovalModel.fromJson(Map<String, dynamic> json) {
    return KonfigurasiApprovalModel(
      id: json['id'],
      transactionType: json['transaction_type'],
      kodeUnit: json['kode_unit'],
      levelApproval: json['level_approval'],
      stepApproval: json['step_approval'],
      statusActive: json['status_active'],
      createdAt: json['created_at'],
    );
  }
}