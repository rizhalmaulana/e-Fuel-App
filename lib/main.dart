import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/datas/models/fuel/fuel_model.dart';
import 'package:e_fuel/datas/models/karyawan/afdeling/afdeling_model.dart';
import 'package:e_fuel/datas/models/karyawan/detail/jenis_karyawan_model.dart';
import 'package:e_fuel/datas/models/karyawan/detail/user_karyawan_model.dart';
import 'package:e_fuel/datas/models/karyawan/jabatan/jabatan_model.dart';
import 'package:e_fuel/datas/models/karyawan/kemandoran/kemandoran_model.dart';
import 'package:e_fuel/datas/models/karyawan/unit/unit_model.dart';
import 'package:e_fuel/datas/models/master_menu/app_menu_model.dart';
import 'package:e_fuel/datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import 'package:e_fuel/datas/models/transactions/penerimaan/transaction_model.dart';
import 'package:e_fuel/datas/models/user/user_model.dart';
import 'package:e_fuel/modules/auth/services/login_service.dart';
import 'package:e_fuel/modules/auth/services/login_user_service.dart';
import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import 'package:e_fuel/modules/master_flow_process/services/flow_process_service.dart';
import 'package:e_fuel/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Hive.registerAdapter(StorageModelAdapter());
  Hive.registerAdapter(TankModelAdapter());
  Hive.registerAdapter(StorageTankModelAdapter());
  Hive.registerAdapter(PenerimaanSebelumModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  Get.lazyPut(() => LoginUserService(), fenix: true);
  Get.lazyPut(() => LoginService(), fenix: true);
  Get.lazyPut(() => FuelDataService(), fenix: true);
  Get.lazyPut(() => FuelSensorService(), fenix: true);
  Get.lazyPut(() => FlowProcessService(), fenix: true);
  Get.lazyPut(() => NotificationService(), fenix: true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  await Hive.initFlutter();
  await Firebase.initializeApp();

  // Inisialisasi Notification Service
  await initializeDependencies();
  final notificationService = Get.find<NotificationService>();
  await notificationService.init();

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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _initAppFuture;

  @override
  void initState() {
    super.initState();
    _initAppFuture = _initProcess();
  }

  Future<bool> _initProcess() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    await initializeDependencies();

    final loginService = Get.find<LoginService>();
    return await loginService.initializeSessionFromHive();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initAppFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppColors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      AppLotties.loadingTPA,
                      width: 150,
                      height: 150,
                      animate: true,
                      repeat: true,
                      frameRate: FrameRate.max,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tunggu Sebentar...',
                      textAlign: TextAlign.center,
                      style: AppFonts.fUrbanistSemiBold10.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '${AppConfig.appName} versi ${AppConfig.versionDev}',
                  textAlign: TextAlign.center,
                  style: AppFonts.fUrbanistMedium12.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          );
        }

        final isLoggedIn = snapshot.data ?? false;

        return GetMaterialApp(
          title: "Integrated Fuel Management",
          initialRoute: isLoggedIn ? AppPages.INITIAL : Routes.LOGIN,
          debugShowCheckedModeBanner: false,
          getPages: AppPages.routes,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Urbanist',
          ),
        );
      },
    );
  }
}