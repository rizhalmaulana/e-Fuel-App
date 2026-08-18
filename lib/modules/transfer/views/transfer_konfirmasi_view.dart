import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transfer_konfirmasi_controller.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';

class TransferKonfirmasiView extends GetView<TransferKonfirmasiController> {
  const TransferKonfirmasiView({super.key});

  Widget _buildInfoRow(String label1, String value1, String label2, String value2, {IconData? icon1, IconData? icon2}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon1 != null) ...[
                  Icon(icon1, size: 16, color: AppColors.secondaryText),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label1, style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText)),
                      const SizedBox(height: 4),
                      Text(value1, style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon2 != null) ...[
                  Icon(icon2, size: 16, color: AppColors.secondaryText),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label2, style: AppFonts.fUrbanistRegular10.copyWith(color: AppColors.secondaryText)),
                      const SizedBox(height: 4),
                      Text(value2, style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBox(String title, IconData icon, bool isAlatBerat) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.takePhoto(isAlatBerat),
        child: Obx(() {
          final isLoading = isAlatBerat ? controller.isTakingPhotoAlatBerat.value : controller.isTakingPhotoOperator.value;
          final photoFile = isAlatBerat ? controller.fotoAlatBerat.value : controller.fotoOperator.value;

          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                : photoFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(photoFile, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: AppColors.primaryOrange, size: 24),
                          ),
                          const SizedBox(height: 12),
                          Text(title, style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText)),
                        ],
                      ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Reverted to original background
      appBar: AppBar(
        backgroundColor: AppColors.background, // Reverted to original background
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08), // Darker but very transparent shadow for white background
                      spreadRadius: 2, // Slight spread to make it visible
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBEADB), // Soft orange background
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.description_outlined, color: AppColors.primaryOrange, size: 18),
                              const SizedBox(width: 8),
                              Text('Doc. ${controller.data.noDoc}', style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryOrange)),
                            ],
                          ),
                          Text(controller.data.dateInbound, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Nama Unit', controller.data.namaUnit, 'No. IO', controller.data.noIo, icon1: Icons.local_shipping_outlined, icon2: Icons.confirmation_num_outlined),
                          _buildInfoRow('Nama Supir', controller.data.supirCheck, '', '', icon1: Icons.person_outline, icon2: null),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text('Aktual Pengisian Solar (Ltr)', style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.aktualController,
                            keyboardType: TextInputType.number,
                            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFFBEADB), // Soft orange highlight
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primaryOrange),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.black12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primaryOrange),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pengambilan (Ltr)', style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText)),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: controller.pengambilanController,
                                      readOnly: true,
                                      style: AppFonts.fUrbanistRegular14.copyWith(color: AppColors.secondaryText),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.backgroundGrey,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Varian (Ltr)', style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText)),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundGrey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Obx(() => Text(
                                        controller.varianText,
                                        style: AppFonts.fUrbanistRegular14.copyWith(
                                          color: controller.varianValue.value < 0 ? AppColors.alertSoftRed : AppColors.secondaryText
                                        ),
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wajib Foto', style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildPhotoBox('Alat Berat', Icons.local_shipping, true),
                        const SizedBox(width: 16),
                        _buildPhotoBox('Operator', Icons.person, false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Submit',
                    style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
