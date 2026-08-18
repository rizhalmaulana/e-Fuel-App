import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/datas/models/filling/filling_model.dart';
import 'package:e_fuel/datas/models/fuel/fuel_model.dart';
import 'package:e_fuel/datas/models/karyawan/afdeling/afdeling_model.dart';
import 'package:e_fuel/datas/models/karyawan/detail/jenis_karyawan_model.dart';
import 'package:e_fuel/datas/models/karyawan/detail/user_karyawan_model.dart';
import 'package:e_fuel/datas/models/karyawan/jabatan/jabatan_model.dart';
import 'package:e_fuel/datas/models/karyawan/kemandoran/kemandoran_model.dart';
import 'package:e_fuel/datas/models/karyawan/unit/unit_model.dart';
import 'package:e_fuel/datas/models/master_menu/app_menu_model.dart';
import 'package:e_fuel/datas/models/master_storage/master_storage_model.dart';
import 'package:e_fuel/datas/models/master_tank/master_tank_model.dart';
import 'package:e_fuel/datas/models/otorisasi_data_model/otorisasi_data_model.dart';
import 'package:e_fuel/datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import 'package:e_fuel/datas/models/penerimaan/penerimaan_setelah_pengisian/penerimaan_setelah_model.dart';
import 'package:e_fuel/datas/models/pengeluaran/pengeluaran_model.dart';
import 'package:e_fuel/datas/models/storage_to_tank/storage_to_tank_model.dart';
import 'package:e_fuel/datas/models/storage_unit/storage_unit_model.dart';
import 'package:e_fuel/datas/models/transactions/penerimaan/transaction_model.dart';
import 'package:e_fuel/datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import 'package:e_fuel/datas/models/transfer/transfer_solar_model.dart';
import 'package:e_fuel/datas/models/unit_to_storage/unit_to_storage_model.dart';
import 'package:e_fuel/datas/models/user/user_model.dart';
import 'package:e_fuel/datas/models/volume_tangki/iot_tangki_model.dart';
import 'package:e_fuel/datas/models/volume_tangki/tangki_model.dart';
import 'package:e_fuel/datas/models/volume_tangki/ukuran_standar_tangki_model.dart';
import 'package:e_fuel/datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import 'package:e_fuel/modules/auth/services/login_service.dart';
import 'package:e_fuel/modules/auth/services/login_user_service.dart';
import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import 'package:e_fuel/modules/master_flow_process/services/flow_process_service.dart';
import 'package:e_fuel/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lottie/lottie.dart';
import 'configs/app_config.dart';
import 'configs/app_fonts.dart';
import 'configs/app_lotties.dart';
import 'datas/models/auth/auth_response_model.dart';
import 'modules/fuel/services/fuel_sensor_service.dart';
import 'modules/notifications/services/notification_service.dart';

Future<void> initializeDependencies() async {
  Hive.registerAdapter(AuthResponseModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(JabatanModelAdapter());
  Hive.registerAdapter(UserKaryawanModelAdapter());
  Hive.registerAdapter(UnitModelAdapter());
  Hive.registerAdapter(AfdelingModelAdapter());
  Hive.registerAdapter(JenisKaryawanModelAdapter());
  Hive.registerAdapter(AppMenuModelAdapter());
  Hive.registerAdapter(KemandoranModelAdapter());
  Hive.registerAdapter(TankModelAdapter());
  Hive.registerAdapter(StorageTankModelAdapter());
  Hive.registerAdapter(PenerimaanSebelumModelAdapter());
  Hive.registerAdapter(FillingModelAdapter());
  Hive.registerAdapter(PenerimaanSetelahModelAdapter());
  Hive.registerAdapter(TangkiModelAdapter());
  Hive.registerAdapter(IotTangkiModelAdapter());
  Hive.registerAdapter(UkuranStandarTangkiModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(MasterStorageModelAdapter());
  Hive.registerAdapter(StorageUnitModelAdapter());
  Hive.registerAdapter(MasterTankModelAdapter());
  Hive.registerAdapter(UnitToStorageModelAdapter());
  Hive.registerAdapter(UnitToStorageItemModelAdapter());
  Hive.registerAdapter(StorageToTankModelAdapter());
  Hive.registerAdapter(CSTStorageModelAdapter());
  Hive.registerAdapter(CSTTankModelAdapter());
  Hive.registerAdapter(VolumeTankDetailModelAdapter());
  Hive.registerAdapter(PengeluaranModelAdapter());
  Hive.registerAdapter(TransactionPengeluaranModelAdapter());
  Hive.registerAdapter(OtorisasiDataModelAdapter());
  Hive.registerAdapter(OtorisasiAreaModelAdapter());
  Hive.registerAdapter(OtorisasiUnitModelAdapter());
  Hive.registerAdapter(OtorisasiAfdelingModelAdapter());
  Hive.registerAdapter(TransferSolarModelAdapter());

  Get.lazyPut(() => LoginUserService(), fenix: true);
  Get.lazyPut(() => LoginService(), fenix: true);
  Get.lazyPut(() => FuelDataService(), fenix: true);
  Get.lazyPut(() => FuelSensorService(), fenix: true);
  Get.lazyPut(() => FlowProcessService(), fenix: true);
  Get.lazyPut(() => NotificationService(), fenix: true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initVersion();

  await initializeDateFormatting('id_ID', null);
  await Hive.initFlutter();
  await Firebase.initializeApp();

  // Pass all uncaught Flutter framework errors to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await initializeDependencies();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Integrated Fuel Management",
      initialRoute: AppPages.INITIAL,
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id', 'ID'),
      transitionDuration: const Duration(milliseconds: 600),
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Urbanist',
      ),
    );
  }
}

