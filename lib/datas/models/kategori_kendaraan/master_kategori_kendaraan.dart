class MasterKategoriKendaraan {
  String kategoriKendaraan;
  String namaKategori;
  bool isActive;

  MasterKategoriKendaraan({
    required this.kategoriKendaraan,
    required this.namaKategori,
    required this.isActive
  });

  factory MasterKategoriKendaraan.fromJson(Map<String, dynamic> json) {
    return MasterKategoriKendaraan(
        kategoriKendaraan: json['kategori_kendaraan'],
        namaKategori: json['nama_kategori'],
        isActive: json['is_active']
    );
  }
}