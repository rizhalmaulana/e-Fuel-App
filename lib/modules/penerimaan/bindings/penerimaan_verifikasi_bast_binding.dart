import 'package:e_fuel/helpers/connectivity_helper.dart';
import 'package:e_fuel/modules/penerimaan/controllers/penerimaan_verifikasi_bast_controller.dart';
import 'package:get/get.dart';

class PenerimaanVerifikasiBastBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectivityHelper>(
        () => ConnectivityHelper(),
    );

    Get.lazyPut<PenerimaanVerifikasiBastController>(
          () => PenerimaanVerifikasiBastController(),
    );
  }
}