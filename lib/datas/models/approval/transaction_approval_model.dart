class TransactionApprovalModel {
  final int id;
  final String transactionType; // FIN atau FOT
  final String levelApproval;
  final String noPo;
  final String? noIo;
  final String noBast;
  final String statusApprove;
  final String? tglApprove;
  final String createdAt;

  TransactionApprovalModel({
    required this.id,
    required this.transactionType,
    required this.levelApproval,
    required this.noPo,
    this.noIo,
    required this.noBast,
    required this.statusApprove,
    this.tglApprove,
    required this.createdAt,
  });

  factory TransactionApprovalModel.fromJson(Map<String, dynamic> json) {
    return TransactionApprovalModel(
      id: json['id'] ?? 0,
      transactionType: json['transaction_type'] ?? '',
      levelApproval: json['level_approval'] ?? '',
      noPo: json['no_po'] ?? '-',
      noIo: json['no_io'],
      noBast: json['no_bast'] ?? '-',
      statusApprove: json['status_approve'] ?? 'PENDING',
      tglApprove: json['tgl_approve'],
      createdAt: json['created_at'] ?? '',
    );
  }
}