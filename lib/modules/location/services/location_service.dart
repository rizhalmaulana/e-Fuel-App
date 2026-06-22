import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:e_fuel/widgets/component/custom_snackbar.dart';
import 'package:e_fuel/configs/app_colors.dart';

class LocationService extends GetxService {
  Position? currentPosition;

  Future<Position?> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        CustomSnackbar.show(
          title: "Akses Ditolak",
          message: "Izin Lokasi diperlukan untuk mengambil foto dengan koordinat.",
          backgroundColor: AppColors.error,
        );
        return null;
      }
    }

    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      CustomSnackbar.show(
        title: "Lokasi Mati",
        message: "Harap aktifkan layanan lokasi (GPS) Anda.",
        backgroundColor: AppColors.error,
      );
      return null;
    }

    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return currentPosition;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  void initialize() {
  }
}