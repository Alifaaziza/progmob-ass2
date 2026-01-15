import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSMSearchService {
  static Future<List<Map<String, dynamic>>> search(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$query&format=json&limit=5',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'Flutter Todo App'},
    );

    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  static LatLng parseLatLng(Map<String, dynamic> place) {
    return LatLng(double.parse(place['lat']), double.parse(place['lon']));
  }
}
