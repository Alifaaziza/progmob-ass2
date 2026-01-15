// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Untuk testing, pakai fake data dulu
  static Future<Map<String, dynamic>?> getWeather(double lat, double lng) async {
    try {
      // Fake delay untuk simulasi network
      await Future.delayed(const Duration(seconds: 1));
      
      // Fake data untuk testing
      return {
        'name': 'Jakarta',
        'weather': [
          {'description': 'cerah berawan', 'main': 'Clear'}
        ],
        'main': {'temp': 28.5, 'humidity': 65},
        'sys': {'country': 'ID'},
      };
      
      // Nanti jika sudah punya API Key, ganti dengan:
      /*
      final apiKey = 'YOUR_API_KEY';
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$apiKey&units=metric&lang=id'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      */
    } catch (e) {
      print('Error get weather: $e');
    }
    return null;
  }
}