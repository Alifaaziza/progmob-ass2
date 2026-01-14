import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/todo.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class AddTodoPage extends StatefulWidget {
  final Function(Todo) onAdd;

  const AddTodoPage({super.key, required this.onAdd});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(); // ✅ catatan

  LatLng? _pickedLocation;
  String? _address;

  bool _saving = false;
  bool _gettingGps = false;
  bool _gettingAddress = false;

  WeatherInfo? _weather;     // ✅ cuaca
  bool _gettingWeather = false;

  Future<void> _setLocationAndFetchInfo(LatLng loc) async {
    setState(() {
      _pickedLocation = loc;
      _address = null;
      _weather = null;
      _gettingAddress = true;
      _gettingWeather = true;
    });

    // Ambil alamat
    try {
      final addr = await LocationService.getAddress(loc.latitude, loc.longitude);
      if (!mounted) return;
      setState(() => _address = addr);
    } catch (_) {
      if (!mounted) return;
      setState(() => _address = "Alamat tidak ditemukan");
    } finally {
      if (mounted) setState(() => _gettingAddress = false);
    }

    // Ambil cuaca
    try {
      final w = await WeatherService.getCurrent(loc.latitude, loc.longitude);
      if (!mounted) return;
      setState(() => _weather = w);
    } catch (_) {
      // kalau gagal, biarkan null (tidak mengganggu todo)
    } finally {
      if (mounted) setState(() => _gettingWeather = false);
    }
  }

  Future<void> _useMyLocation() async {
    setState(() => _gettingGps = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      final myLoc = LatLng(pos.latitude, pos.longitude);
      await _setLocationAndFetchInfo(myLoc);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi GPS berhasil digunakan ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil lokasi GPS: $e')),
      );
    } finally {
      if (mounted) setState(() => _gettingGps = false);
    }
  }

  Future<void> _saveTodo() async {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul wajib diisi')),
      );
      return;
    }

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tekan "Pakai Lokasiku (GPS)" dulu')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final address = _address ??
          await LocationService.getAddress(
            _pickedLocation!.latitude,
            _pickedLocation!.longitude,
          );

      final todo = Todo(
        title: title,
        note: note, // ✅ catatan
        placeName: "Lokasi Saya",
        address: address,
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
      );

      widget.onAdd(todo);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan todo: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _pickedLocation != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Todo + Lokasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // JUDUL
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Todo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ CATATAN
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Tulis catatan di sini...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ HANYA GPS
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: (_saving || _gettingGps) ? null : _useMyLocation,
                icon: _gettingGps
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_gettingGps
                    ? 'Mengambil lokasi...'
                    : 'Pakai Lokasiku (GPS)'),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ INFO LOKASI
            if (hasLocation)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _gettingAddress
                          ? const Text('Mengambil alamat...')
                          : Text(_address ?? 'Alamat tidak ditemukan'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // ✅ INFO CUACA
            if (hasLocation)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _gettingWeather
                    ? const Text('Mengambil cuaca saat ini...')
                    : (_weather == null
                        ? const Text('Cuaca tidak tersedia (cek API key).')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cuaca: ${_weather!.description}",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text("Suhu: ${_weather!.tempC.toStringAsFixed(1)}°C"),
                              Text("Kelembapan: ${_weather!.humidity}%"),
                              Text("Angin: ${_weather!.windMs.toStringAsFixed(1)} m/s"),
                            ],
                          )),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveTodo,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
