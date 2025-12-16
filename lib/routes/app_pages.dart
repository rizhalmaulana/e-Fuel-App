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
import 'package:e_fuel/modules/pengeluaran/bindings/pengeluaran_tracking_binding.dart';
import 'package:e_fuel/modules/pengeluaran/views/pengeluaran_tracking_view.dart';
import 'package:e_fuel/modules/pengisian_solar/bindings/pengisian_solar_binding.dart';
import 'package:e_fuel/modules/pengisian_solar/views/penerimaan/pengisian_solar_penerimaan_view.dart';
import 'package:e_fuel/modules/pengisian_solar/views/pengeluaran/pengisian_solar_pengeluaran_view.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/login_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/penerimaan/views/penerimaan_setelah_view.dart';
import '../modules/penerimaan/views/penerimaan_tracking_view.dart';
import '../modules/pengeluaran/bindings/pengeluaran_binding.dart';
import '../modules/pengeluaran/bindings/pengeluaran_verifikasi_doc_binding.dart';
import '../modules/pengeluaran/views/pengeluaran_verifikasi_doc_view.dart';
import '../modules/pengeluaran/views/pengeluaran_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;
  // static const INITIAL = '${Routes.PENERIMAAN_SEBELUM_FORM}?step=2';

  static const LOGIN = Routes.LOGIN;
  static const HOME = Routes.HOME;

  // Flow Penerimaan
  static const PENERIMAAN = Routes.PENERIMAAN;
  static const PENERIMAAN_SEBELUM = Routes.PENERIMAAN_SEBELUM_FORM;

  static const PENGISIAN_SOLAR = Routes.PENGISIAN_SOLAR;

  static const PENERIMAAN_SETELAH = Routes.PENERIMAAN_SETELAH;
  static const PENERIMAAN_VERIFIKASI_BAST = Routes.PENERIMAAAN_VERIFIKASI_BAST;
  static const PENERIMAAN_TRACKING = Routes.PENERIMAAN_TRACKING;

  static const PENGELUARAN = Routes.PENGELUARAN;
  static const PENGISIAN_SOLAR_PENGELUARAN = Routes.PENGISIAN_SOLAR_PENGELUARAN;
  static const PENGELUARAN_VERIFIKASI_DOC = Routes.PENGELUARAN_VERIFIKASI_DOC;
  static const PENGELUARAN_TRACKING = Routes.PENGELUARAN_TRACKING;

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
      page: () => const PengisianSolarPenerimaanView(),
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
    GetPage(
      name: Routes.PENGELUARAN,
      page: () => const PengeluaranView(),
      binding: PengeluaranBinding(),
    ),
    GetPage(
      name: Routes.PENGISIAN_SOLAR_PENGELUARAN,
      page: () => const PengisianSolarPengeluaranView(),
      binding: PengisianSolarBinding(),
    ),
    GetPage(
      name: Routes.PENGELUARAN_VERIFIKASI_DOC,
      page: () => const PengeluaranVerifikasiDocView(),
      binding: PengeluaranVerifikasiDocBinding(),
    ),
    GetPage(
      name: Routes.PENGELUARAN_TRACKING,
      page: () => const PengeluaranTrackingView(),
      binding: PengeluaranTrackingBinding(),
    ),
  ];
}