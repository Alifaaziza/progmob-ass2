// lib/providers/home_provider.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

import '../services/database_service.dart';
import '../services/weather_service.dart';
import '../models/todo.dart';

class HomeProvider extends ChangeNotifier {
  final DatabaseService database = DatabaseService();
  List<Todo> _todos = [];
  
  // VARIABEL BARU
  Position? _currentPosition;
  Map<String, dynamic>? _weatherData;
  String _appMode = 'Normal';
  List<Todo> _nearbyTodos = [];
  String _locationName = 'Mengambil lokasi...';
  
  // GETTER
  List<Todo> get todos => _todos;
  Position? get currentPosition => _currentPosition;
  Map<String, dynamic>? get weatherData => _weatherData;
  String get appMode => _appMode;
  List<Todo> get nearbyTodos => _nearbyTodos;
  String get locationName => _locationName;

  HomeProvider();

  Future<void> loadTodos() async {
    _todos = await database.getTodos();
    notifyListeners();
  }

  Future<void> toggleTodoDone(Todo todo) async {
    await database.updateTodoDone(todo.id!, !todo.isDone);
    await loadTodos();
  }

  // ============ FITUR LOKASI ============

  Future<void> getCurrentLocation() async {
    try {
      var status = await Permission.location.status;
      
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) {
          print('Permission lokasi ditolak');
          return;
        }
      }

      bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isGpsEnabled) {
        print('GPS tidak aktif');
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      print('📍 Lokasi didapat: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      
      await _getLocationName();
      
      notifyListeners();
      
      await _getWeatherData(); // AMBIL DATA CUACA ASLI DARI API
      await _checkAppMode();
      await _checkNearbyTodos();
      
    } catch (e) {
      print('❌ Error getting location: $e');
    }
  }

  // METHOD: GET LOCATION NAME FROM COORDINATES
  Future<void> _getLocationName() async {
    if (_currentPosition == null) return;
    
    try {
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      ).timeout(const Duration(seconds: 5));
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // Filter Plus Codes
        String _removePlusCodes(String text) {
          final plusCodeRegex = RegExp(r'[A-Z0-9]{4,}\+[A-Z0-9]{2,}');
          if (plusCodeRegex.hasMatch(text)) {
            return text.replaceAll(plusCodeRegex, '').replaceAll(', ,', ',').trim();
          }
          return text;
        }
        
        List<String> possibleNames = [];
        
        // Format 1: Street + SubLocality
        if (placemark.street != null && placemark.street!.isNotEmpty &&
            placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          String name = '${placemark.street}, ${placemark.subLocality}';
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Format 2: SubLocality + Locality
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty &&
            placemark.locality != null && placemark.locality!.isNotEmpty) {
          String name = '${placemark.subLocality}, ${placemark.locality}';
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Format 3: Locality + AdministrativeArea
        if (placemark.locality != null && placemark.locality!.isNotEmpty &&
            placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          String name = '${placemark.locality}, ${placemark.administrativeArea}';
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Format 4: Hanya SubLocality
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          String name = placemark.subLocality!;
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Format 5: Hanya Locality
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          String name = placemark.locality!;
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        if (possibleNames.isNotEmpty) {
          possibleNames.sort((a, b) => b.length.compareTo(a.length));
          _locationName = possibleNames.first;
        } else {
          // Fallback ke nama kota dari Weather API nanti
          final lat = _currentPosition!.latitude.toStringAsFixed(2);
          final lng = _currentPosition!.longitude.toStringAsFixed(2);
          _locationName = 'Area ($lat, $lng)';
        }
        
      } else {
        // Fallback
        final lat = _currentPosition!.latitude.toStringAsFixed(2);
        final lng = _currentPosition!.longitude.toStringAsFixed(2);
        _locationName = 'Area ($lat, $lng)';
      }
      
      // Clean up
      _locationName = _locationName
          .replaceAll(' ,', ',')
          .replaceAll(',,', ',')
          .replaceAll('  ', ' ')
          .trim();
          
      if (_locationName.endsWith(',')) {
        _locationName = _locationName.substring(0, _locationName.length - 1).trim();
      }
      
      notifyListeners();
      
    } catch (e) {
      print('⚠️ Error get location name: $e');
      // Fallback akan diupdate oleh data cuaca nanti
      if (_currentPosition != null) {
        final lat = _currentPosition!.latitude.toStringAsFixed(2);
        final lng = _currentPosition!.longitude.toStringAsFixed(2);
        _locationName = 'Area ($lat, $lng)';
      } else {
        _locationName = 'Lokasi Anda';
      }
      notifyListeners();
    }
  }

  // METHOD BARU: GET WEATHER DATA DARI API ASLI
  Future<void> _getWeatherData() async {
    if (_currentPosition == null) return;
    
    print('🌤 Mengambil data cuaca dari API OpenWeatherMap...');
    
    try {
      // Panggil WeatherService dengan API asli
      _weatherData = await WeatherService.getWeather(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      if (_weatherData != null) {
        print('✅ Data cuaca berhasil didapat');
        
        // PERBAIKAN: Jika locationName masih generic, update dengan nama kota dari API
        if (_locationName.contains('Area') || _locationName.contains('Lokasi')) {
          final cityName = getCityNameFromWeather();
          if (cityName.isNotEmpty && cityName != 'Lokasi Anda') {
            _locationName = cityName;
            print('📍 Update location name dari API: $cityName');
          }
        }
      } else {
        print('⚠️ Data cuaca null dari API');
      }
      
      notifyListeners();
      
    } catch (e) {
      print('❌ Error get weather data: $e');
    }
  }

  Future<void> _checkAppMode() async {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      _appMode = '🌅 Pagi Mode';
    } else if (hour >= 12 && hour < 18) {
      _appMode = '☀️ Siang Mode';
    } else if (hour >= 18 && hour < 24) {
      _appMode = '🌙 Malam Mode';
    } else {
      _appMode = '🌜 Tengah Malam';
    }
    
    notifyListeners();
  }

  Future<void> _checkNearbyTodos() async {
    if (_currentPosition == null || _todos.isEmpty) return;

    _nearbyTodos.clear();
    
    for (var todo in _todos) {
      if (todo.latitude != null && todo.longitude != null) {
        try {
          final distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            todo.latitude!,
            todo.longitude!,
          );
          
          if (distance <= 5000) {
            _nearbyTodos.add(todo);
          }
        } catch (e) {
          print('Error calculate distance: $e');
        }
      }
    }
    
    notifyListeners();
  }

  // METHOD UNTUK GET WEATHER DESCRIPTION (DARI API ASLI)
  String getWeatherDescription() {
    if (_weatherData == null) return 'Mengambil data cuaca...';
    
    try {
      final weather = _weatherData!['weather'][0];
      final main = _weatherData!['main'];
      
      // Format: "awan tersebar • 28.21°C"
      return '${weather['description']} • ${main['temp'].toStringAsFixed(1)}°C';
    } catch (e) {
      return 'Data cuaca tidak tersedia';
    }
  }
  
  // METHOD BARU: GET CITY NAME FROM WEATHER API
  String getCityNameFromWeather() {
    if (_weatherData == null) return 'Lokasi Anda';
    
    try {
      final cityName = _weatherData!['name'];
      return cityName?.toString() ?? 'Lokasi Anda';
    } catch (e) {
      return 'Lokasi Anda';
    }
  }
  
  // METHOD BARU: GET DETAILED WEATHER INFO
  String getDetailedWeatherInfo() {
    if (_weatherData == null) return '';
    
    try {
      final weather = _weatherData!['weather'][0];
      final main = _weatherData!['main'];
      final wind = _weatherData!['wind'] ?? {};
      
      return '''
🌡 Suhu: ${main['temp'].toStringAsFixed(1)}°C
💧 Kelembaban: ${main['humidity']}%
🌬 Angin: ${wind['speed']?.toStringAsFixed(1) ?? '0'} m/s
☁️ ${weather['description']}
''';
    } catch (e) {
      return '';
    }
  }

  String getFormattedCoordinates() {
    if (_currentPosition == null) return '';
    
    return '${_currentPosition!.latitude.toStringAsFixed(4)}, '
           '${_currentPosition!.longitude.toStringAsFixed(4)}';
  }
  
  // METHOD BARU: GET TEMPERATURE
  double? getTemperature() {
    if (_weatherData == null) return null;
    
    try {
      final main = _weatherData!['main'];
      return main['temp']?.toDouble();
    } catch (e) {
      return null;
    }
  }
}