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
      
      print('Lokasi didapat: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      
      await _getLocationName();
      
      notifyListeners();
      
      await _getWeatherData();
      await _checkAppMode();
      await _checkNearbyTodos();
      
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // PERBAIKAN METHOD: GET LOCATION NAME FROM COORDINATES
  Future<void> _getLocationName() async {
    if (_currentPosition == null) return;
    
    try {
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // FILTER: Hapus Plus Codes (kode seperti JV9H+2H2)
        String _removePlusCodes(String text) {
          // Regex untuk mendeteksi Plus Codes
          final plusCodeRegex = RegExp(r'[A-Z0-9]{4,}\+[A-Z0-9]{2,}');
          if (plusCodeRegex.hasMatch(text)) {
            // Hapus kode plus dan koma/kurung sebelumnya
            return text.replaceAll(plusCodeRegex, '').replaceAll(', ,', ',').trim();
          }
          return text;
        }
        
        // Coba beberapa format nama lokasi
        List<String> possibleNames = [];
        
        // Format 1: Street + SubLocality (Jalan + Kecamatan)
        if (placemark.street != null && placemark.street!.isNotEmpty &&
            placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          String name = '${placemark.street}, ${placemark.subLocality}';
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Format 2: SubLocality + Locality (Kecamatan + Kota)
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty &&
            placemark.locality != null && placemark.locality!.isNotEmpty) {
          String name = '${placemark.subLocality}, ${placemark.locality}';
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Format 3: Locality + AdministrativeArea (Kota + Provinsi)
        if (placemark.locality != null && placemark.locality!.isNotEmpty &&
            placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          String name = '${placemark.locality}, ${placemark.administrativeArea}';
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Format 4: Hanya SubLocality (Kecamatan)
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          String name = placemark.subLocality!;
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Format 5: Hanya Locality (Kota)
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          String name = placemark.locality!;
          name = _removePlusCodes(name);
          if (name.isNotEmpty && !name.contains(RegExp(r'[A-Z0-9]{4,}\+'))) {
            possibleNames.add(name);
          }
        }
        
        // Pilih nama terbaik (prioritaskan yang lebih panjang/detail)
        if (possibleNames.isNotEmpty) {
          // Pilih yang paling panjang (biasanya paling detail)
          possibleNames.sort((a, b) => b.length.compareTo(a.length));
          _locationName = possibleNames.first;
        } else {
          // Fallback: Koordinat format friendly
          final lat = _currentPosition!.latitude.toStringAsFixed(2);
          final lng = _currentPosition!.longitude.toStringAsFixed(2);
          _locationName = 'Area ($lat, $lng)';
        }
        
      } else {
        // Fallback: Koordinat format friendly
        final lat = _currentPosition!.latitude.toStringAsFixed(2);
        final lng = _currentPosition!.longitude.toStringAsFixed(2);
        _locationName = 'Area ($lat, $lng)';
      }
      
      // Bersihkan karakter aneh
      _locationName = _locationName
          .replaceAll(' ,', ',')
          .replaceAll(',,', ',')
          .replaceAll('  ', ' ')
          .trim();
          
      // Hapus koma di akhir jika ada
      if (_locationName.endsWith(',')) {
        _locationName = _locationName.substring(0, _locationName.length - 1).trim();
      }
      
      notifyListeners();
      
    } catch (e) {
      print('Error get location name: $e');
      // Fallback ke koordinat friendly
      if (_currentPosition != null) {
        final lat = _currentPosition!.latitude.toStringAsFixed(2);
        final lng = _currentPosition!.longitude.toStringAsFixed(2);
        _locationName = 'Lokasi ($lat, $lng)';
      } else {
        _locationName = 'Lokasi Anda';
      }
      notifyListeners();
    }
  }

  Future<void> _getWeatherData() async {
    if (_currentPosition != null) {
      _weatherData = await WeatherService.getWeather(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      notifyListeners();
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

  String getWeatherDescription() {
    if (_weatherData == null) return 'Mengambil data cuaca...';
    
    try {
      final weather = _weatherData!['weather'][0];
      final main = _weatherData!['main'];
      
      return '${weather['description']} • ${main['temp']}°C';
    } catch (e) {
      return 'Cuaca tidak tersedia';
    }
  }
  
  String getFormattedCoordinates() {
    if (_currentPosition == null) return '';
    
    return '${_currentPosition!.latitude.toStringAsFixed(4)}, '
           '${_currentPosition!.longitude.toStringAsFixed(4)}';
  }
}