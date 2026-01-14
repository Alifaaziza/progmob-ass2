import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });
}

class PlaceDetail {
  final double lat;
  final double lng;
  final String name;
  final String formattedAddress;

  PlaceDetail({
    required this.lat,
    required this.lng,
    required this.name,
    required this.formattedAddress,
  });
}

class PlacesService {
  // TODO: ganti dengan API key kamu (yang sudah di-restrict)
  static const String _apiKey = "PASTE_API_KEY_KAMU_DI_SINI";

  static Future<List<PlaceSuggestion>> autocomplete({
    required String input,
    required String sessionToken,
    String? countryCode, // contoh: "id"
  }) async {
    final uri = Uri.https(
      "maps.googleapis.com",
      "/maps/api/place/autocomplete/json",
      {
        "input": input,
        "key": _apiKey,
        "sessiontoken": sessionToken,
        if (countryCode != null) "components": "country:$countryCode",
        "language": "id",
      },
    );

    final res = await http.get(uri);
    final data = jsonDecode(res.body);

    if (data["status"] != "OK") {
      // lihat penyebab pastinya di Run/Debug console
      // contoh status: REQUEST_DENIED, INVALID_REQUEST, OVER_QUERY_LIMIT
      print("PLACES AUTOCOMPLETE STATUS: ${data["status"]}");
      print("PLACES AUTOCOMPLETE ERROR: ${data["error_message"]}");
      return [];
    }

    final preds = (data["predictions"] as List).cast<Map<String, dynamic>>();

    return preds.map((p) {
      final sf = p["structured_formatting"] ?? {};
      return PlaceSuggestion(
        placeId: p["place_id"],
        mainText: (sf["main_text"] ?? p["description"]).toString(),
        secondaryText: (sf["secondary_text"] ?? "").toString(),
      );
    }).toList();
  }

  static Future<PlaceDetail> getDetail({
    required String placeId,
    required String sessionToken,
  }) async {
    final uri = Uri.https(
      "maps.googleapis.com",
      "/maps/api/place/details/json",
      {
        "place_id": placeId,
        "key": _apiKey,
        "sessiontoken": sessionToken,
        "fields": "name,formatted_address,geometry/location",
        "language": "id",
      },
    );

    final res = await http.get(uri);
    final data = jsonDecode(res.body);

    if (data["status"] != "OK") {
      throw Exception(data["error_message"] ?? "Places detail error");
    }

    final r = data["result"];
    final loc = r["geometry"]["location"];

    return PlaceDetail(
      lat: (loc["lat"] as num).toDouble(),
      lng: (loc["lng"] as num).toDouble(),
      name: (r["name"] ?? "").toString(),
      formattedAddress: (r["formatted_address"] ?? "").toString(),
    );
  }
}
