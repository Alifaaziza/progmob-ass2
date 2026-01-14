import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final String description; // contoh: "berawan"
  final double tempC;       // suhu Celsius
  final int humidity;       // %
  final double windMs;      // m/s

  WeatherInfo({
    required this.description,
    required this.tempC,
    required this.humidity,
    required this.windMs,
  });
}

class WeatherService {
  // ✅ GANTI pakai API key OpenWeatherMap kamu
  static const String _apiKey = "bbb797253d953d2bbce4212f5237dcc3";

  static Future<WeatherInfo> getCurrent(double lat, double lon) async {
    final uri = Uri.https("api.openweathermap.org", "/data/2.5/weather", {
      "lat": lat.toString(),
      "lon": lon.toString(),
      "appid": _apiKey,
      "units": "metric",
      "lang": "id",
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Gagal ambil cuaca (${res.statusCode})");
    }

    final data = jsonDecode(res.body);

    final weather = (data["weather"] as List).first;
    final main = data["main"];
    final wind = data["wind"];

    return WeatherInfo(
      description: (weather["description"] ?? "-").toString(),
      tempC: (main["temp"] as num).toDouble(),
      humidity: (main["humidity"] as num).toInt(),
      windMs: (wind["speed"] as num).toDouble(),
    );
  }
}
