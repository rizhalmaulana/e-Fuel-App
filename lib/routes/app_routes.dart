part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;

  static const PENERIMAAN = _Paths.PENERIMAAN;
  static const PENERIMAAN_SEBELUM_FORM = _Paths.PENERIMAAN_SEBELUM_FORM;

  static const PENGISIAN_SOLAR = _Paths.PENGISIAN_SOLAR;

  static const PENERIMAAN_SETELAH = _Paths.PENERIMAAN_SETELAH;
  static const PENERIMAAAN_VERIFIKASI_BAST = _Paths.PENERIMAAN_VERIFIKASI_BAST;
  static const PENERIMAAN_TRACKING = _Paths.PENERIMAAN_TRACKING;

  static const PENGELUARAN = _Paths.PENGELUARAN;
  static const APPROVAL = _Paths.APPROVAL;
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

  static const PENGELUARAN = '/pengeluaran';
  static const APPROVAL = '/approval';
}
