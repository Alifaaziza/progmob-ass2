// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // ⬇️ GANTI INI DENGAN API KEY ASLI!
  static const String apiKey = '08e7eadf7049e7783191b01a17d46287';
  
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>?> getWeather(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?lat=$lat&lon=$lng&appid=$apiKey&units=metric&lang=id'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Weather API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error get weather: $e');
      return null;
    }
  }
}