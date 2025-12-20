class UrlApiStatic {
  static String API_END_POINT = 'http://112.78.149.227:8000/api';
  static String API_END_POINT_DBK = 'http://192.168.1.8:8085/api';
  static String TOKEN_API_KEY = r"Xy9$2fG7!LpQz#8VmRt6&NsWb@3KdEj4UhPoYxCq";

  // POST
  static String API_PAIR_AUTH = '/authentifikasi/pair';
  static String API_CREATE_INBOUND_OPEN = '/e_fuel/inbound-open/create'; // Create Inbound Penerimaan
  static String API_CREATE_INBOUND_TANK = '/e_fuel/inbound-open/create-tank-inbound';
  static String API_CREATE_INBOUND_FOT = '/e_fuel/inbound-open/create-fot'; // Create Inbound Pengeluaran
  static String API_CREATE_KONFIGURASI_APPROVAL = '/e_fuel/konfigurasi-approval/create';
  static String API_CREATE_TRANSACTION_APPROVAL = '/e_fuel/transaksi-approval/create';
  static String API_POST_FCM_TOKEN = '/absensi/user-devices';
  static String API_POST_SIGNATURE_APPROVAL = '/e_fuel/transaksi-approval/upload-signature/{no_doc}';
  static String API_POST_IMAGE_PENGELUARAN = '/e_fuel/inbound-open/upload-photos/{no_doc}';

  // GET
  static String API_GET_UNIT = '/unit-list/';
  static String API_GET_INBOUND_OPEN_LIST = '/e_fuel/inbound-open/list';
  static String API_GET_KONFIGURASI_APPROVAL_LIST = '/e_fuel/konfigurasi-approval/list';
  static String API_GET_TRANSACTION_APPROVAL_LIST = '/e_fuel/transaksi-approval/list';
  static String API_GET_LITER_KABLIBRASI = '/e_fuel/master-kalibrasi/get-liter';
  static String API_GET_INBOUND_OPEN_DETAIL = '/e_fuel/fuel-inbound-open/detail/{no_doc}';

  static String API_GET_MASTER_STORAGE = '/e_fuel/masterstorage';
  static String API_GET_MASTER_TANK = '/e_fuel/mastersolartank';
  static String API_GET_CHILD_UNIT_TO_STORAGE = '/e_fuel/cunitstorage';
  static String API_GET_CHILD_STORAGE_TO_TANK = '/e_fuel/cstoragetank';
  static String API_GET_CHILD_DETAIL_STORAGE_TANK = '/e_fuel/cdetailstoragetank';

  static String API_GET_MASTER_IO_LIST = '/e_fuel/master-io/list';
  static String API_GET_MASTER_IO_DETAIL = '/e_fuel/master-io/{internal_order}';

  // GET DATA FROM DBK
  static String API_GET_EMPLOYEE_DBK = '/Employee/GetAllPaged';

  // PUT
  static String API_UPDATE_STATUS_DOC_INBOUND = '/e_fuel/inbound-open/update-status/{no_doc}';
  static String API_UPDATE_STATUS_TRANSACTION_APPROVAL = '/e_fuel/transaksi-approval/update-status/{no_doc}';

}