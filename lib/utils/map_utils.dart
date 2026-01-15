import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapUtils {
  static Future<List<LatLng>> getRoutePolyline(LatLng start, LatLng end) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to get route');
    }

    final data = json.decode(response.body);

    final List coordinates = data['routes'][0]['geometry']['coordinates'];

    return coordinates.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }
}
