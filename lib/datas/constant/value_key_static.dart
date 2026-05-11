class ValueKeyStatic {
  // 🔑 Static Keys untuk Nama Box (hanya prefix, nama akun akan ditambahkan)
  static const String USER_BOX = 'userBox';
  static const String USER_BOX_DEV = 'userBox_dev';

  // 🔑 Static Keys untuk Data di DALAM Box
  static const String AUTH_DATA_KEY = 'auth_data_object'; // Untuk AuthResponseModel lengkap
  static const String TOKEN_ACCESS_KEY = 'access'; // Untuk access token string mentah
  static const String TOKEN_REFRESH_KEY = 'refresh'; // Untuk refresh token string mentah

  static const String APP_STATUS_BOX = 'app_status_box';
  static const String ACTIVE_USERNAME_KEY = 'active_username';

  // 🔑 Static Keys untuk Data di DALAM Box
  static const String LIST_STORAGE_KEY = 'list_storage_data';
  static const String LIST_TANK_MASTER_KEY = 'list_tank_master_data';

  static const String LIST_STORAGE_TANK_IOT_KEY = 'list_storage_tank_iot_data';
  static const String TEMP_SNAPSHOT_DATA_KEY = 'temp_snapshot_data_key';

  // 🔑 Static Box untuk Nama Box Fuel Data (Prefix per user)
  static const String LIST_STORAGE_FUEL_BOX = 'list_storage_fuel_box';
  static const String LAST_SELECTED_STORAGE_KEY = 'last_selected_storage_name';
  static const String LAST_SELECTED_STORAGE_CODE_KEY = 'last_selected_storage_coded';

  // 🔑 Static Keys untuk Nama Box Fuel Data (Prefix per user)
  static const String FUEL_DATA_BOX = 'fuelDataBox'; // Prefix nama box
  static const String FUEL_DATA_IOT_BOX = 'fuelDataIoTBox'; // Prefix nama box

  // Key baru untuk menyimpan list tangki manual dari API
  static const String API_MANUAL_TANKS_KEY = 'api_manual_tanks_list';
  static const String LATEST_STOCK_CACHE_KEY = 'latest_stock_cache_data';

  static String CODE_TRANSACTION_PENERIMAAN = "FIN";
  static String CODE_TRANSACTION_PENGELUARAN = "FOT";
}