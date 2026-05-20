import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../controllers/report_detail_penerimaan_controller.dart';

class ReportDetailPenerimaanView extends GetView<ReportDetailPenerimaanController> {
  const ReportDetailPenerimaanView({super.key});

  String _val(dynamic value, [String suffix = ""]) {
    if (value == null || value.toString().isEmpty || value == "null") return "-";
    return "$value $suffix".trim();
  }

  String _formatLiter(dynamic value, [String suffix = "Ltr"]) {
    if (value == null || value.toString().isEmpty || value == "null") return "-";
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return "-";
    final formatted = parsed % 1 == 0 ? parsed.toInt().toString() : parsed.toStringAsFixed(2);
    return "$formatted $suffix".trim();
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
          const Divider(height: 20, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: isHighlight
                ? AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)
                : AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryText),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  Widget _buildTankList(List<dynamic> tanks) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tanks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tank = tanks[index] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _val(tank['nama_tank']),
                    style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText),
                  ),
                  Text(
                    _val(tank['kode_storage']),
                    style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
              const Divider(height: 16),
              _buildRow("Volume Awal", _formatLiter(tank['volume_terkini_liter'])),
              _buildRow("Tinggi Awal", _val(tank['tinggi_terkini_cm'], "cm")),
              _buildRow("Volume Akhir", _formatLiter(tank['volume_akhir_liter'])),
              _buildRow("Tinggi Akhir", _val(tank['tinggi_akhir_cm'], "cm")),
              _buildRow("Varian Volume", _formatLiter(tank['volume_var_liter'])),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          "Detail Penerimaan",
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final data = controller.detailData;
        if (data.isEmpty) {
          return Center(
            child: Text("Detail tidak ditemukan", style: AppFonts.fUrbanistRegular12),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection("Informasi Dokumen", [
              _buildRow("No. Dokumen", _val(data['no_doc'])),
              _buildRow("No. PO", _val(data['no_po'])),
              _buildRow("Tipe Dokumen", _val(data['doc_type_name'])),
              _buildRow("Tanggal Inbound", _val(data['date_inbound'])),
              _buildRow("Unit", "${_val(data['kode_unit'])} - ${_val(data['nama_unit'])}"),
              _buildRow("Storage", "${_val(data['storage_code'])} - ${_val(data['storage_name'])}"),
              _buildRow("Status Inbound", data['status_inbound'] == 'O' ? "Open" : "Approved"),
            ]),

            _buildSection("Informasi Vendor", [
              _buildRow("No. SPB Vendor", _val(data['vendor_spb'])),
              _buildRow("No. Polisi Vendor", _val(data['nopol_vendor'])),
              _buildRow("Nama Supir", _val(data['supir_vendor'])),
              _buildRow("Kapasitas Vendor", _formatLiter(data['kapasitas_vendor'])),
              _buildRow("Volume Vendor", _formatLiter(data['volume_vendor'])),
              _buildRow("Density Vendor", _val(data['density_vendor'])),
              _buildRow("Temp Vendor", _val(data['temp_vendor'], "°C")),
            ]),

            _buildSection("Pemeriksaan Segel & Terra", [
              _buildRow("Terra Vendor", _val(data['terra_vendor'], "mm")),
              _buildRow("Terra Pemeriksaan", _val(data['terra_check'], "mm")),
              _buildRow("Selisih Terra", _val(data['terra_var'], "mm")),
              _buildRow("Kepekaan Tangki", _val(data['tangki_peka'], "mm/L")),
              const SizedBox(height: 8),
              _buildRow("Segel Atas", _val(data['segel_tangki_atas'])),
              _buildRow("Segel Bawah", _val(data['segel_tangki_bawah'])),
              _buildRow("Kondisi Segel", _val(data['segel_kondisi'])),
            ]),

            _buildSection("Hasil Penerimaan (Aktual Total)", [
              _buildRow("Volume Awal", _formatLiter(data['volume_terkini_liter'])),
              _buildRow("Tinggi Awal", _val(data['tinggi_terkini_cm'], "cm")),
              _buildRow("Volume Akhir", _formatLiter(data['volume_akhir_liter'])),
              _buildRow("Tinggi Akhir", _val(data['tinggi_akhir_cm'], "cm")),
              _buildRow("Total Volume Diterima (Varian)", _formatLiter(data['volume_var_liter']), isHighlight: true),
              _buildRow("Tinggi Total Diterima (Varian)", _val(data['tinggi_var_cm'], "cm")),
            ]),

            if (data['tanks'] != null && (data['tanks'] as List).isNotEmpty)
              _buildSection("Rincian per Tangki", [
                _buildTankList(data['tanks'] as List),
              ]),

            if (data['approvals'] != null && (data['approvals'] as List).isNotEmpty)
              _buildSection("Riwayat Persetujuan", [
                Text("Terakreditasi / Disetujui oleh: ${_val(data['created_by'])}", style: AppFonts.fUrbanistRegular12),
              ]),
          ],
        );
      }),
    );
  }
}