import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  Position? currentPosition;

  Future<Position?> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        Get.snackbar("Akses Ditolak", "Izin Lokasi diperlukan untuk mengambil foto dengan koordinat.");
        return null;
      }
    }

    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      Get.snackbar("Lokasi Mati", "Harap aktifkan layanan lokasi (GPS) Anda.");
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