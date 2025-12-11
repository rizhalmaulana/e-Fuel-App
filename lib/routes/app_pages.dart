import 'package:e_fuel/modules/home/views/home_view.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_sebelum_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_setelah_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_tracking_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_verifikasi_bast_binding.dart';
import 'package:e_fuel/modules/penerimaan/controllers/penerimaan_sebelum_controller.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_sebelum_form.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_verifikasi_bast_view.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_view.dart';
import 'package:e_fuel/modules/pengisian_solar/bindings/pengisian_solar_binding.dart';
import 'package:e_fuel/modules/pengisian_solar/views/pengisian_solar_view.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/login_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/penerimaan/views/penerimaan_setelah_view.dart';
import '../modules/penerimaan/views/penerimaan_tracking_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;
  // static const INITIAL = '${Routes.PENERIMAAN_SEBELUM_FORM}?step=2';

  static const LOGIN = Routes.LOGIN;
  static const HOME = Routes.HOME;
  static const PENERIMAAN = Routes.PENERIMAAN;
  static const PENERIMAAN_SEBELUM = Routes.PENERIMAAN_SEBELUM_FORM;

  static const PENGISIAN_SOLAR = Routes.PENGISIAN_SOLAR;

  static const PENERIMAAN_SETELAH = Routes.PENERIMAAN_SETELAH;
  static const PENERIMAAN_VERIFIKASI_BAST = Routes.PENERIMAAAN_VERIFIKASI_BAST;
  static const PENERIMAAN_TRACKING = Routes.PENERIMAAN_TRACKING;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: Routes.PENERIMAAN,
      page: () => const PenerimaanView(),
      binding: PenerimaanBinding(),
    ),
    GetPage(
      name: Routes.PENERIMAAN_SEBELUM_FORM,
      page: () => const PenerimaanSebelumForm(),
      binding: PenerimaanSebelumBinding(),
    ),
    GetPage(
      name: _Paths.PENGISIAN_SOLAR,
      page: () => const PengisianSolarView(),
      binding: PengisianSolarBinding(),
    ),
    GetPage(
      name: Routes.PENERIMAAN_SETELAH,
      page: () => const PenerimaanSetelahView(),
      binding: PenerimaanSetelahBinding(),
    ),
    GetPage(
      name: Routes.PENERIMAAAN_VERIFIKASI_BAST,
      page: () => const PenerimaanVerifikasiBastView(),
      binding: PenerimaanVerifikasiBastBinding(),
    ),
    GetPage(
      name: Routes.PENERIMAAN_TRACKING,
      page: () => const PenerimaanTrackingView(),
      binding: PenerimaanTrackingBinding(),
    ),
  ];
}