import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // cek GPS aktif atau tidak
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service belum aktif');
    }

    // cek permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<String> getAddress(double lat, double lng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(lat, lng);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.country}";
    }

    return "Alamat tidak ditemukan";
  }
}
