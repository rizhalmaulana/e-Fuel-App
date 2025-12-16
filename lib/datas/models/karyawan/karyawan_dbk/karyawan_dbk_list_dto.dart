class KaryawanDbkListDto {
  final String? nip;
  final String? nama;
  final String? jabatan;
  final String? unit;
  final String? status;

  KaryawanDbkListDto({
    this.nip,
    this.nama,
    this.jabatan,
    this.unit,
    this.status,
  });

  factory KaryawanDbkListDto.fromJson(Map<String, dynamic> json) {
    return KaryawanDbkListDto(
      nip: json['nip'],
      nama: json['nama'],
      jabatan: json['jabatan'],
      unit: json['unit'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nip': nip,
      'nama': nama,
      'jabatan': jabatan,
      'unit': unit,
      'status': status,
    };
  }
}

class KaryawanPagedResponse {
  final List<KaryawanDbkListDto>? data;
  final int? totalRecords;
  final int? pageNumber;
  final int? pageSize;
  final int? totalPages;

  KaryawanPagedResponse({
    this.data,
    this.totalRecords,
    this.pageNumber,
    this.pageSize,
    this.totalPages,
  });

  factory KaryawanPagedResponse.fromJson(Map<String, dynamic> json) {
    return KaryawanPagedResponse(
      data: json['data'] == null
          ? []
          : List<KaryawanDbkListDto>.from(
          json['data']!.map((x) => KaryawanDbkListDto.fromJson(x))),
      totalRecords: json['totalRecords'],
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
    );
  }
}