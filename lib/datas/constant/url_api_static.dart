class UrlApiStatic {
  static const String API_END_POINT = 'https://digilink.teladanprima.com/api';
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
  static String API_POST_SIGNATURE_SECURITY = '/e_fuel/transaksi-approval/upload-signature-security/{no_doc}';
  static String API_POST_IMAGE_PENGELUARAN = '/e_fuel/inbound-open/upload-photos/{no_doc}';
  static String API_POST_ACTUAL_LITER_PENGELUARAN = '/e_fuel/inbound-open/update-aktual-liter/{no_doc}';

  // EBPB
  static String API_GET_TRANSACTION_LIST_EBPB = '/e_fuel/transaksi-ebpb/list'; // Mengambil Transkasi Approval EBPB
  static String API_GET_APPROVAL_LIST_EBPB = '/e_fuel/transaksi-approval-ebpb/list'; // Mengambil Transkasi Approval EBPB
  static String API_CREATE_TRANSACTION_EBPB_APPROVAL = '/e_fuel/transaksi-approval-ebpb/create';
  static String API_UPLOAD_SIGNATURE_EBPB = '/e_fuel/transaksi-approval-ebpb/upload-signature';
  static String API_UPDATE_STATUS_EBPB = '/e_fuel/transaksi-approval-ebpb/update-status';

  static String API_CREATE_TRANSACTION_EBPB = '/e_fuel/transaksi-ebpb/create';
  static String API_GET_TRANSACTION_DETAIL_EBPB = '/e_fuel/transaksi-ebpb/detail';
  static String API_EXPORT_EBPB_PDF_DOC = '/e_fuel/transaksi-ebpb/export-pdf/{no_doc}';

  // TRANSFER SOLAR ALAT BERAT
  static String API_GET_LIST_ALAT_BERAT = '/e_fuel/inbound-open/list-pengeluaran-alat-berat';
  static String API_GET_DETAIL_ALAT_BERAT = '/e_fuel/inbound-open/detail-transfer-solar/{no_doc}';
  static String API_CREATE_TRANSFER_SOLAR = '/e_fuel/inbound-open/create-transfer-solar';

  // PENGEMBALIAN SOLAR
  static String API_GET_LIST_PENGEMBALIAN_SOLAR = '/e_fuel/inbound-open/list-pengembalian-solar';
  static String API_CREATE_PENGEMBALIAN_SOLAR = '/e_fuel/inbound-open/create-pengembalian-solar';

  // GET
  static String API_GET_UNIT = '/unit-list';
  static String API_GET_INBOUND_OPEN_LIST = '/e_fuel/inbound-open/list';
  static String API_GET_KONFIGURASI_APPROVAL_LIST = '/e_fuel/konfigurasi-approval/list';
  static String API_GET_TRANSACTION_APPROVAL_LIST = '/e_fuel/transaksi-approval/list';
  static String API_GET_LITER_KABLIBRASI = '/e_fuel/master-kalibrasi/get-liter';
  static String API_GET_INBOUND_OPEN_DETAIL = '/e_fuel/fuel-inbound-open/detail/{no_doc}';
  static String API_GET_OUTSTANDING_INBOUND_OPEN = '/e_fuel/inbound-open/outstanding';
  static String API_GET_ALL_TRANSACTION_LIST = '/e_fuel/inbound-open/list-by-date';
  static String API_GET_DETAIL_DOC_FULL_APPROVED = '/e_fuel/inbound-all-approved/detail/{no_doc}';

  static String API_GET_MASTER_STORAGE = '/e_fuel/masterstorage';
  static String API_GET_MASTER_TANK = '/e_fuel/mastersolartank';
  static String API_GET_CHILD_UNIT_TO_STORAGE = '/e_fuel/cunitstorage';
  static String API_GET_CHILD_STORAGE_TO_TANK = '/e_fuel/cstoragetank';
  static String API_GET_CHILD_DETAIL_STORAGE_TANK = '/e_fuel/cdetailstoragetank';
  static String API_GET_TRANSACTION_PENGELUARAN_DAILY = '/e_fuel/transaksi-fot/daily';

  static String API_GET_MASTER_IO_LIST = '/e_fuel/master-io/list';
  static String API_GET_MASTER_IO_VENDOR_LIST = '/e_fuel/master-io/vendor/list';
  static String API_GET_MASTER_IO_DETAIL = '/e_fuel/master-io/{internal_order}';
  static String API_EXPORT_PDF_DOC = '/e_fuel/inbound-all-approved/export-pdf/{no_doc}';

  // Get Current Stock Tank
  // static String API_GET_LAST_STOCK = '/e_fuel/last-stock'; // Get Latest Stock for Penerimaan

  static String API_GET_TANK_STOCK_LIST = '/e_fuel/tank-stock/list'; // Get All Stock
  static String API_GET_LATEST_STORAGE_STOCK = '/e_fuel/storage-stock/latest-volume'; // Get Latest Tank Stock Pengeluaran
  static String API_GET_LATEST_TANK_STOCK = '/e_fuel/tank-stock/latest-volume'; // Get Latest Tank Stock Pengeluaran
  static String API_GET_FLOW_IN = '/e_fuel/tank-stock/flow-out'; // Get Traffic Stock Penerimaan
  static String API_GET_FLOW_OUT = '/e_fuel/tank-stock/flow-in'; // Get Traffic Stock Pengeluaran

  static String API_GET_UNIT_PER_AREA = '/absensi/units/same-area/{kode_unit}';

  // GET DATA FROM DBK
  static String API_GET_EMPLOYEE_DBK = '/Employee/GetAllPaged';

  // PUT
  static String API_UPDATE_STATUS_DOC_INBOUND = '/e_fuel/inbound-open/update-status/{no_doc}';
  static String API_UPDATE_STATUS_TRANSACTION_APPROVAL = '/e_fuel/transaksi-approval/update-status/{no_doc}';
}