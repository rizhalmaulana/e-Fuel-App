part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;

  // Penerimaan
  static const PENERIMAAN = _Paths.PENERIMAAN;
  static const PENERIMAAN_SEBELUM_FORM = _Paths.PENERIMAAN_SEBELUM_FORM;

  static const PENGISIAN_SOLAR = _Paths.PENGISIAN_SOLAR;

  static const PENERIMAAN_SETELAH = _Paths.PENERIMAAN_SETELAH;
  static const PENERIMAAAN_VERIFIKASI_BAST = _Paths.PENERIMAAN_VERIFIKASI_BAST;
  static const PENERIMAAN_TRACKING = _Paths.PENERIMAAN_TRACKING;

  // Pengeluaran
  static const PENGELUARAN_INPUT_BON_SEMENTARA = _Paths.PENGELUARAN_INPUT_BON_SEMENTARA;
  static const PENGELUARAN = _Paths.PENGELUARAN;
  static const PENGISIAN_SOLAR_PENGELUARAN = _Paths.PENGISIAN_SOLAR_PENGELUARAN;
  static const PENGELUARAN_VERIFIKASI_DOC = _Paths.PENGELUARAN_VERIFIKASI_DOC;
  static const PENGELUARAN_TRACKING = _Paths.PENGELUARAN_TRACKING;
  static const PENGELUARAN_BPB_HARIAN = _Paths.PENGELUARAN_BPB_HARIAN;

  // Approval
  static const APPROVAL = _Paths.APPROVAL;

  // Report
  static const REPORT_PENERIMAAN = _Paths.REPORT_PENERIMAAN;
  static const REPORT_DETAIL_PENERIMAAN = _Paths.REPORT_DETAIL_PENERIMAAN;

  static const REPORT_PENGELUARAN = _Paths.REPORT_PENGELUARAN;
  static const REPORT_DETAIL_PENGELUARAN = _Paths.REPORT_DETAIL_PENGELUARAN;
}

abstract class _Paths {
  _Paths._();
  static const LOGIN = '/login';
  static const HOME = '/home';

  static const PENERIMAAN = '/penerimaan';
  static const PENERIMAAN_SEBELUM_FORM = '/penerimaan-sebelum-form';
  static const PENGISIAN_SOLAR = '/pengisian-solar';
  static const PENERIMAAN_SETELAH = '/penerimaan-setelah';
  static const PENERIMAAN_VERIFIKASI_BAST = '/penerimaan-verifikasi-bast';
  static const PENERIMAAN_TRACKING = '/penerimaan-tracking';

  static const PENGELUARAN_INPUT_BON_SEMENTARA = '/pengeluaran-input-bon-sementara';
  static const PENGELUARAN = '/pengeluaran';
  static const PENGISIAN_SOLAR_PENGELUARAN = '/pengisian-solar-pengeluaran';
  static const PENGELUARAN_VERIFIKASI_DOC = '/pengeluaran-verifikasi-doc';
  static const PENGELUARAN_TRACKING = '/pengeluaran-tracking';
  static const PENGELUARAN_BPB_HARIAN = '/pengeluaran-bpb-harian';

  static const APPROVAL = '/approval';

  static const REPORT_PENERIMAAN = '/report-penerimaan';
  static const REPORT_DETAIL_PENERIMAAN = '/report-detail-penerimaan';

  static const REPORT_PENGELUARAN = '/report-pengeluaran';
  static const REPORT_DETAIL_PENGELUARAN = '/report-detail-pengeluaran';
}
