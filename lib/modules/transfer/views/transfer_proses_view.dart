import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transfer_proses_controller.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../widgets/component/auto_scroll_text.dart';

class TransferProsesView extends GetView<TransferProsesController> {
  const TransferProsesView({super.key});

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(
        text,
        style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
      ),
    );
  }

  Widget _buildTextField(TextEditingController textController, {bool readOnly = false}) {
    return TextField(
      controller: textController,
      readOnly: readOnly,
      style: AppFonts.fUrbanistRegular14.copyWith(color: AppColors.primaryText),
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly ? AppColors.backgroundGrey.withOpacity(0.5) : AppColors.alertSoftOrangeSecond,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: AutoScrollText(
        text: text,
        style: AppFonts.fUrbanistRegular14.copyWith(color: AppColors.primaryText),
      ),
    );
  }

  Widget _buildCardSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey, // Memberikan kontras agar card terlihat
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Transfer Solar',
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardSection(
                      title: 'Transaksi & Unit',
                      icon: Icons.assignment_outlined,
                      children: [
                        _buildLabel('Tanggal Transaksi'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.dateInbound,
                                style: AppFonts.fUrbanistRegular14.copyWith(color: AppColors.secondaryText),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.primaryText,
                                size: 20,
                              ),
                            ],
                          ),
                        ),

                        _buildLabel('Nama Unit'),
                        _buildReadOnlyField(controller.namaUnitController.text),

                        _buildLabel('No. Transaksi'),
                        _buildTextField(controller.noTransaksiController, readOnly: true),

                        _buildLabel('No. IO'),
                        _buildTextField(controller.noIOController, readOnly: true),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildCardSection(
                      title: 'Pengambilan Solar',
                      icon: Icons.local_gas_station_outlined,
                      children: [
                        _buildLabel('Total Liter'),
                        _buildTextField(controller.totalLiterController, readOnly: true),
                        
                        _buildLabel('Foto Odometer Alat Berat'),
                        GestureDetector(
                          onTap: controller.takeOdometerPhoto,
                          child: Obx(() {
                            if (controller.isTakingPhoto.value) {
                              return Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundGrey,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.primaryOrange),
                                ),
                              );
                            }

                            if (controller.fotoOdometer.value != null) {
                              return Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                  image: DecorationImage(
                                    image: FileImage(controller.fotoOdometer.value!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }

                            return Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.primaryOrange,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Ketuk disini untuk mengambil foto',
                                    style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Wajib melampirkan foto\nOdometer kendaraan',
                                    textAlign: TextAlign.center,
                                    style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Container (Sticky)
            Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Proses Transfer Solar',
                        style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
