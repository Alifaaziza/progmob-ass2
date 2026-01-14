import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickedPlace {
  final LatLng location;
  final String placeName;
  final String address;

  const PickedPlace({
    required this.location,
    required this.placeName,
    required this.address,
  });
}
