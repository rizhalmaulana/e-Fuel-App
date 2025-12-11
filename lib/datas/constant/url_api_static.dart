class UrlApiStatic {
  static String API_END_POINT = 'http://112.78.149.227:8000/api';

  // POST
  static String API_PAIR_AUTH = '/authentifikasi/pair';
  static String API_CREATE_INBOUND_OPEN = '/e_fuel/inbound-open/create';
  static String API_CREATE_INBOUND_TANK = '/e_fuel/inbound-open/create-tank-inbound';
  static String API_CREATE_KONFIGURASI_APPROVAL = '/e_fuel/konfigurasi-approval/create';
  static String API_CREATE_TRANSACTION_APPROVAL = '/e_fuel/transaksi-approval/create';
  static String API_POST_FCM_TOKEN = '/absensi/user-devices';

  // GET
  static String API_GET_UNIT = '/unit-list/';
  static String API_GET_INBOUND_OPEN_LIST = '/e_fuel/inbound-open/list';
  static String API_GET_KONFIGURASI_APPROVAL_LIST = '/e_fuel/konfigurasi-approval/list';
  static String API_GET_TRANSACTION_APPROVAL_LIST = '/e_fuel/transaksi-approval/list';

  // PUT
  static String API_UPDATE_STATUS_DOC_INBOUND = '/e_fuel/inbound-open/update-status/{no_doc}';
  static String API_UPDATE_STATUS_TRANSACTION_APPROVAL = '/e_fuel/transaksi-approval/update-status/{no_doc}';

}