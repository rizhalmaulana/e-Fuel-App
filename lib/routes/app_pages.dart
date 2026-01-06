import 'package:e_fuel/modules/approval/bindings/approval_bindings.dart';
import 'package:e_fuel/modules/approval/views/approval_views.dart';
import 'package:e_fuel/modules/home/views/home_view.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_sebelum_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_setelah_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_tracking_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_verifikasi_bast_binding.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_sebelum_form.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_verifikasi_bast_view.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_view.dart';
import 'package:e_fuel/modules/pengeluaran/bindings/pengeluaran_bpb_harian_binding.dart';
import 'package:e_fuel/modules/pengeluaran/bindings/pengeluaran_input_bon_sementara_binding.dart';
import 'package:e_fuel/modules/pengeluaran/bindings/pengeluaran_tracking_binding.dart';
import 'package:e_fuel/modules/pengeluaran/views/pengeluaran_bpb_harian_view.dart';
import 'package:e_fuel/modules/pengeluaran/views/pengeluaran_input_bon_sementara_view.dart';
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
import '../modules/report/bindings/report_penerimaan_binding.dart';
import '../modules/report/bindings/report_pengeluaran_binding.dart';
import '../modules/report/views/report_penerimaan_view.dart';
import '../modules/report/views/report_pengeluaran_view.dart';

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

  static const PENGELUARAN_INPUT_BON_SEMENTARA = Routes.PENGELUARAN_INPUT_BON_SEMENTARA;
  static const PENGELUARAN = Routes.PENGELUARAN;
  static const PENGISIAN_SOLAR_PENGELUARAN = Routes.PENGISIAN_SOLAR_PENGELUARAN;
  static const PENGELUARAN_VERIFIKASI_DOC = Routes.PENGELUARAN_VERIFIKASI_DOC;
  static const PENGELUARAN_TRACKING = Routes.PENGELUARAN_TRACKING;
  static const APPROVAL = Routes.APPROVAL;

  static const REPORT_PENERIMAAN = Routes.REPORT_PENERIMAAN;
  static const REPORT_PENGELUARAN = Routes.REPORT_PENGELUARAN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn, // Menggunakan fadeIn untuk Login
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn, // Cupertino sangat smooth untuk Home
      transitionDuration: const Duration(milliseconds: 500),
    ),
    // Alur Penerimaan
    GetPage(
      name: Routes.PENERIMAAN,
      page: () => const PenerimaanView(),
      binding: PenerimaanBinding(),
      transition: Transition.rightToLeftWithFade, // Animasi alur kerja
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENERIMAAN_SEBELUM_FORM,
      page: () => const PenerimaanSebelumForm(),
      binding: PenerimaanSebelumBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.PENGISIAN_SOLAR,
      page: () => const PengisianSolarPenerimaanView(),
      binding: PengisianSolarBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENERIMAAN_SETELAH,
      page: () => const PenerimaanSetelahView(),
      binding: PenerimaanSetelahBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENERIMAAAN_VERIFIKASI_BAST,
      page: () => const PenerimaanVerifikasiBastView(),
      binding: PenerimaanVerifikasiBastBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENERIMAAN_TRACKING,
      page: () => const PenerimaanTrackingView(),
      binding: PenerimaanTrackingBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    // Alur Pengeluaran
    GetPage(
      name: Routes.PENGELUARAN_INPUT_BON_SEMENTARA,
      page: () => const PengeluaranInputBonSementaraView(),
      binding: PengeluaranInputBonSementaraBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENGELUARAN,
      page: () => const PengeluaranView(),
      binding: PengeluaranBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENGISIAN_SOLAR_PENGELUARAN,
      page: () => const PengisianSolarPengeluaranView(),
      binding: PengisianSolarBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENGELUARAN_VERIFIKASI_DOC,
      page: () => const PengeluaranVerifikasiDocView(),
      binding: PengeluaranVerifikasiDocBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENGELUARAN_TRACKING,
      page: () => const PengeluaranTrackingView(),
      binding: PengeluaranTrackingBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENGELUARAN_BPB_HARIAN,
      page: () => const PengeluaranBpbHarianView(),
      binding: PengeluaranBpbHarianBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.APPROVAL,
      page: () => const ApprovalView(),
      binding: ApprovalBindings(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.REPORT_PENERIMAAN,
      page: () => const ReportPenerimaanView(),
      binding: ReportPenerimaanBinding(),
    ),
    GetPage(
      name: Routes.REPORT_PENGELUARAN,
      page: () => const ReportPengeluaranView(),
      binding: ReportPengeluaranBinding(),
    ),
  ];
}