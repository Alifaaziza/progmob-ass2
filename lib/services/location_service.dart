import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS/Location Service belum aktif. Silakan aktifkan dulu.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      await Geolocator.openAppSettings();
      throw Exception('Izin lokasi ditolak permanen. Aktifkan dari Settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  static Future<String> getAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 10));

      if (placemarks.isEmpty) return "Alamat tidak ditemukan";

      final p = placemarks.first;

      final parts = <String>[
        if ((p.name ?? '').trim().isNotEmpty) p.name!.trim(),
        if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
        if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
        if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? '').trim().isNotEmpty) p.administrativeArea!.trim(),
        if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
      ];

      return parts.isEmpty ? "Alamat tidak ditemukan" : parts.join(', ');
    } catch (_) {
      return "Alamat tidak ditemukan";
    }
  }
}
