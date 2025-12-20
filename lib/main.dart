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
import 'package:firebase_database/firebase_database.dart';
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

    // Jalankan seed satu kali, lalu beri komentar jika sudah berhasil
    // runAllSeeds();
  }

  Future<bool> _initProcess() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      final loginService = Get.find<LoginService>();
      return await loginService.initializeSessionFromHive();
    } catch (e) {
      print("Error saat cek session: $e");
      return false;
    }
  }

  // Future<void> runAllSeeds() async {
  //   final List<Map<String, dynamic>> kmData = [
  //     {
  //       "IO": "E031KRL902",
  //       "NamaUnitIO": "DC Askep",
  //       "Km Awal": 22013,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031KRL905",
  //       "NamaUnitIO": "DC Askep WM",
  //       "Km Awal": 116525,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031KRLX01",
  //       "NamaUnitIO": "DC Konsultan WM",
  //       "Km Awal": 109895,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031KRL903",
  //       "NamaUnitIO": "DC PK",
  //       "Km Awal": 3439,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031KRD901",
  //       "NamaUnitIO": "DT 01",
  //       "Km Awal": 132220,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031KRD902",
  //       "NamaUnitIO": "DT 02",
  //       "Km Awal": 129557,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031KRD903",
  //       "NamaUnitIO": "DT 03",
  //       "Km Awal": 127343,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031KRD904",
  //       "NamaUnitIO": "DT 04",
  //       "Km Awal": 100021,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031ABE904",
  //       "NamaUnitIO": "Exca 313",
  //       "Km Awal": "",
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031ABE902",
  //       "NamaUnitIO": "Exca Long Arm 01",
  //       "Km Awal": 6962,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031ABE905",
  //       "NamaUnitIO": "Exca Long Arm 02",
  //       "Km Awal": 2772,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031ABE907",
  //       "NamaUnitIO": "Exca PC 200-01",
  //       "Km Awal": 944,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031ABE908",
  //       "NamaUnitIO": "Exca PC 200-02",
  //       "Km Awal": 10317,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031ABE901",
  //       "NamaUnitIO": "Exca PC 50-01",
  //       "Km Awal": "",
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031ABE906",
  //       "NamaUnitIO": "Exca PC 50-02",
  //       "Km Awal": 2733,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031ABG901",
  //       "NamaUnitIO": "Grader",
  //       "Km Awal": 8138,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031MSP906",
  //       "NamaUnitIO": "GST 15 KVA Afd 3",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     },
  //     {
  //       "IO": "E031MSP905",
  //       "NamaUnitIO": "GST 33 KVA Afd 1",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     },
  //     {
  //       "IO": "E031MSP904",
  //       "NamaUnitIO": "GST 33 KVA Afd 2",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     },
  //     {
  //       "IO": "E031MSP903",
  //       "NamaUnitIO": "GST 50 KVA Afd 1",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     },
  //     {
  //       "IO": "E031MSP003",
  //       "NamaUnitIO": "GST 85 KVA Afd 3",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     },
  //     {
  //       "IO": "E031ABA903",
  //       "NamaUnitIO": "MDC",
  //       "Km Awal": "",
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031KRT901",
  //       "NamaUnitIO": "TUS",
  //       "Km Awal": 4181,
  //       "DateAwal": ""
  //     },
  //     {
  //       "IO": "E031MSW001",
  //       "NamaUnitIO": "WP 01 Afd 1",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     },
  //     {
  //       "IO": "E031MSW002",
  //       "NamaUnitIO": "WP 02 Afd 3",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     },
  //     {
  //       "IO": "E031MSW004",
  //       "NamaUnitIO": "WP Bibitan",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     },
  //     {
  //       "IO": "E031MSW005",
  //       "NamaUnitIO": "WP Pioneer WM",
  //       "Km Awal": "",
  //       "DateAwal": "2025-12-18"
  //     }
  //   ];
  //   final List<Map<String, dynamic>> ratioData = [
  //     {"IO": "E031KRL902", "NamaUnitIO": "DC Askep", "Ratio": "8", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031KRL905", "NamaUnitIO": "DC Askep WM", "Ratio": "7.5", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031KRLX01", "NamaUnitIO": "DC Konsultan WM", "Ratio": "0", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031KRL903", "NamaUnitIO": "DC PK", "Ratio": "7.8", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031KRD901", "NamaUnitIO": "DT 01", "Ratio": "3.7", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031KRD902", "NamaUnitIO": "DT 02", "Ratio": "3.5", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031KRD903", "NamaUnitIO": "DT 03", "Ratio": "4", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031KRD904", "NamaUnitIO": "DT 04", "Ratio": "3.3", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031ABE904", "NamaUnitIO": "Exca 313", "Ratio": "12.5", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031ABE902", "NamaUnitIO": "Exca Long Arm 01", "Ratio": "13.2", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031ABE905", "NamaUnitIO": "Exca Long Arm 02", "Ratio": "13.2", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031ABE907", "NamaUnitIO": "Exca PC 200-01", "Ratio": "0", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031ABE908", "NamaUnitIO": "Exca PC 200-02", "Ratio": "0", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031ABE901", "NamaUnitIO": "Exca PC 50-01", "Ratio": "5.5", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031ABE906", "NamaUnitIO": "Exca PC 50-02", "Ratio": "5.5", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031ABG901", "NamaUnitIO": "Grader", "Ratio": "12.8", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031MSP906", "NamaUnitIO": "GST 15 KVA Afd 3", "Ratio": "0", "Tipe": "GS", "Operation": "7", "operationHoliday": "0"},
  //     {"IO": "E031MSP905", "NamaUnitIO": "GST 33 KVA Afd 1", "Ratio": "2.5", "Tipe": "GS", "Operation": "7", "operationHoliday": "-2"},
  //     {"IO": "E031MSP904", "NamaUnitIO": "GST 33 KVA Afd 2", "Ratio": "0", "Tipe": "GS", "Operation": "7", "operationHoliday": "0"},
  //     {"IO": "E031MSP903", "NamaUnitIO": "GST 50 KVA Afd 1", "Ratio": "6.8", "Tipe": "GS", "Operation": "7", "operationHoliday": "2"},
  //     {"IO": "E031MSP003", "NamaUnitIO": "GST 85 KVA Afd 3", "Ratio": "0", "Tipe": "GS", "Operation": "7", "operationHoliday": "0"},
  //     {"IO": "E031ABA903", "NamaUnitIO": "MDC", "Ratio": "0", "Tipe": "AB", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031KRT901", "NamaUnitIO": "TUS", "Ratio": "3.7", "Tipe": "KD", "Operation": "0", "operationHoliday": "0"},
  //     {"IO": "E031MSW001", "NamaUnitIO": "WP 01 Afd 1", "Ratio": "1.5", "Tipe": "GS", "Operation": "7", "operationHoliday": "2"},
  //     {"IO": "E031MSW002", "NamaUnitIO": "WP 02 Afd 3", "Ratio": "0", "Tipe": "GS", "Operation": "7", "operationHoliday": "0"},
  //     {"IO": "E031MSW004", "NamaUnitIO": "WP Bibitan", "Ratio": "0", "Tipe": "GS", "Operation": "7", "operationHoliday": "0"},
  //     {"IO": "E031MSW005", "NamaUnitIO": "WP Pioneer WM", "Ratio": "0", "Tipe": "GS", "Operation": "7", "operationHoliday": "0"}
  //   ];
  //
  //   String now = DateTime.now().toIso8601String();
  //   DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  //
  //   try {
  //     // 1. SEED InitiateKM
  //     for (var item in kmData) {
  //       String cleanId = item["IO"].toString().replaceAll(RegExp(r'[.#$\[\]]'), '_');
  //       double valKm = double.tryParse(item["Km Awal"].toString()) ?? 0.0;
  //
  //       await dbRef.child("InitiateKM").child(cleanId).set({
  //         "NoUnitIO": item["IO"],
  //         "NamaUnitIO": item["NamaUnitIO"],
  //         "KMAwal": valKm,
  //         "DateAwal": item["DateAwal"],
  //         "createDate": now,
  //         "updateDate": now,
  //       });
  //     }
  //
  //     // 2. SEED InitiateRatio
  //     for (var item in ratioData) {
  //       String cleanId = item["IO"].toString().replaceAll(RegExp(r'[.#$\[\]]'), '_');
  //       double valRatio = double.tryParse(item["Ratio"].toString().replaceAll(',', '.')) ?? 0.0;
  //
  //       await dbRef.child("InitiateRatio").child(cleanId).set({
  //         "NoUnitIO": item["IO"],
  //         "NamaUnitIO": item["NamaUnitIO"],
  //         "Ratio": valRatio,
  //         "Tipe": item["Tipe"],
  //         "Operation": int.tryParse(item["Operation"].toString()) ?? 0,
  //         "OperationHoliday": int.tryParse(item["operationHoliday"].toString()) ?? 0,
  //         "createDate": now,
  //         "updateDate": now,
  //       });
  //     }
  //     print("✅ SEED BERHASIL: 27 Unit dengan DateAwal telah diperbarui.");
  //   } catch (e) {
  //     print("❌ SEED GAGAL: $e");
  //   }
  // }

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
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 600),
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
