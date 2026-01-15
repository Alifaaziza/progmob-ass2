// lib/services/location_service.dart
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<String> getAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        String address = '';
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          address += placemark.street!;
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += placemark.subLocality!;
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += placemark.locality!;
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += placemark.country!;
        }
        
        return address;
      }
      return '$lat, $lng';
    } catch (e) {
      print('Error get address: $e');
      return '$lat, $lng';
    }
  }
}