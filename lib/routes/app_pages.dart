import 'package:e_fuel/modules/approval/bindings/approval_bindings.dart';
import 'package:e_fuel/modules/approval/bindings/approval_ebpb_binding.dart';
import 'package:e_fuel/modules/approval/views/approval_views.dart';
import 'package:e_fuel/modules/approval/views/approval_ebpb_view.dart';
import 'package:e_fuel/modules/home/views/home_view.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_sebelum_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_setelah_binding.dart';
import 'package:e_fuel/modules/penerimaan/bindings/penerimaan_verifikasi_bast_binding.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_sebelum_view.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_verifikasi_bast_view.dart';
import 'package:e_fuel/modules/penerimaan/views/penerimaan_view.dart';
import 'package:e_fuel/modules/pengeluaran/bindings/pengeluaran_e_bpb_binding.dart';
import 'package:e_fuel/modules/pengeluaran/bindings/pengeluaran_input_bon_sementara_binding.dart';
import 'package:e_fuel/modules/pengeluaran/bindings/pengeluaran_tracking_binding.dart';
import 'package:e_fuel/modules/pengeluaran/views/pengeluaran_e_bpb_view.dart';
import 'package:e_fuel/modules/pengeluaran/views/pengeluaran_input_bon_sementara_view.dart';
import 'package:e_fuel/modules/pengeluaran/views/pengeluaran_tracking_view.dart';
import 'package:e_fuel/modules/pengisian_solar/bindings/pengisian_solar_binding.dart';
import 'package:e_fuel/modules/pengisian_solar/views/penerimaan/pengisian_solar_penerimaan_view.dart';
import 'package:e_fuel/modules/pengisian_solar/views/pengeluaran/pengisian_solar_pengeluaran_view.dart';
import 'package:e_fuel/modules/report/bindings/report_detail_penerimaan_binding.dart';
import 'package:e_fuel/modules/report/bindings/report_detail_pengeluaran_binding.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/login_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/penerimaan/views/penerimaan_setelah_view.dart';
import '../modules/pengeluaran/bindings/pengeluaran_binding.dart';
import '../modules/pengeluaran/bindings/pengeluaran_verifikasi_doc_binding.dart';
import '../modules/pengeluaran/views/pengeluaran_verifikasi_doc_view.dart';
import '../modules/pengeluaran/views/pengeluaran_view.dart';
import '../modules/report/bindings/report_penerimaan_binding.dart';
import '../modules/report/bindings/report_pengeluaran_binding.dart';
import '../modules/report/views/report_penerimaan/report_detail_penerimaan_view.dart';
import '../modules/report/views/report_penerimaan/report_penerimaan_view.dart';
import '../modules/report/views/report_pengeluaran/report_detail_pengeluaran_view.dart';
import '../modules/report/views/report_pengeluaran/report_pengeluaran_view.dart';
import '../modules/report/bindings/report_transfer_binding.dart';
import '../modules/report/views/report_transfer/report_transfer_view.dart';
import 'package:e_fuel/modules/splash/bindings/splash_binding.dart';
import 'package:e_fuel/modules/splash/views/splash_view.dart';
import 'package:e_fuel/modules/pengembalian/bindings/pengembalian_binding.dart';
import 'package:e_fuel/modules/pengembalian/views/pengembalian_view.dart';
import 'package:e_fuel/modules/pengembalian/bindings/pengembalian_proses_binding.dart';
import 'package:e_fuel/modules/pengembalian/views/pengembalian_proses_view.dart';
import 'package:e_fuel/modules/pengembalian/bindings/pengembalian_loading_binding.dart';
import 'package:e_fuel/modules/pengembalian/views/pengembalian_loading_view.dart';
import 'package:e_fuel/modules/pengembalian/bindings/pengembalian_aktual_binding.dart';
import 'package:e_fuel/modules/pengembalian/views/pengembalian_aktual_view.dart';
import 'package:e_fuel/modules/transfer/bindings/transfer_binding.dart';
import 'package:e_fuel/modules/transfer/views/transfer_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;
  static const LOGIN = Routes.LOGIN;
  static const HOME = Routes.HOME;

  // Flow Penerimaan
  static const PENERIMAAN = Routes.PENERIMAAN;
  static const PENERIMAAN_SEBELUM = Routes.PENERIMAAN_SEBELUM_FORM;
  static const PENGISIAN_SOLAR = Routes.PENGISIAN_SOLAR;
  static const PENERIMAAN_SETELAH = Routes.PENERIMAAN_SETELAH;
  static const PENERIMAAN_VERIFIKASI_BAST = Routes.PENERIMAAAN_VERIFIKASI_BAST;

  static const PENGELUARAN_INPUT_BON_SEMENTARA = Routes.PENGELUARAN_INPUT_BON_SEMENTARA;
  static const PENGELUARAN = Routes.PENGELUARAN;
  static const PENGEMBALIAN = Routes.PENGEMBALIAN;
  static const PENGEMBALIAN_LOADING = Routes.PENGEMBALIAN_LOADING;
  static const PENGEMBALIAN_AKTUAL = Routes.PENGEMBALIAN_AKTUAL;
  static const PENGISIAN_SOLAR_PENGELUARAN = Routes.PENGISIAN_SOLAR_PENGELUARAN;
  static const PENGELUARAN_VERIFIKASI_DOC = Routes.PENGELUARAN_VERIFIKASI_DOC;
  static const PENGELUARAN_TRACKING = Routes.PENGELUARAN_TRACKING;
  static const TRANSFER = Routes.TRANSFER;
  static const APPROVAL = Routes.APPROVAL;
  static const APPROVAL_EBPB = Routes.APPROVAL_EBPB;

  static const REPORT_PENERIMAAN = Routes.REPORT_PENERIMAAN;
  static const REPORT_PENGELUARAN = Routes.REPORT_PENGELUARAN;
  static const REPORT_TRANSFER = Routes.REPORT_TRANSFER;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
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
      page: () => const PenerimaanSebelumView(),
      binding: PenerimaanSebelumBinding(),
      transition: Transition.downToUp,
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
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENGEMBALIAN,
      page: () => const PengembalianView(),
      binding: PengembalianBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: Routes.PENGEMBALIAN_PROSES,
      page: () => const PengembalianProsesView(),
      binding: PengembalianProsesBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENGEMBALIAN_LOADING,
      page: () => const PengembalianLoadingView(),
      binding: PengembalianLoadingBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PENGEMBALIAN_AKTUAL,
      page: () => const PengembalianAktualView(),
      binding: PengembalianAktualBinding(),
      transition: Transition.rightToLeft,
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
      name: Routes.PENGELUARAN_EBPB,
      page: () => const PengeluaranEBpbView(),
      binding: PengeluaranEBpbBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.TRANSFER,
      page: () => const TransferView(),
      binding: TransferBinding(),
      transition: Transition.downToUp,
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
      name: Routes.APPROVAL_EBPB,
      page: () => const ApprovalEbpbView(),
      binding: ApprovalEbpbBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.REPORT_PENERIMAAN,
      page: () => const ReportPenerimaanView(),
      binding: ReportPenerimaanBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.REPORT_DETAIL_PENERIMAAN,
      page: () => const ReportDetailPenerimaanView(),
      binding: ReportDetailPenerimaanBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.REPORT_PENGELUARAN,
      page: () => const ReportPengeluaranView(),
      binding: ReportPengeluaranBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.REPORT_DETAIL_PENGELUARAN,
      page: () => const ReportDetailPengeluaranView(),
      binding: ReportDetailPengeluaranBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.REPORT_TRANSFER,
      page: () => const ReportTransferView(),
      binding: ReportTransferBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}