import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../providers/home_provider.dart';
import '../models/todo.dart';
import '../services/osm_search_service.dart';

class MapPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapPage({super.key, required this.latitude, required this.longitude});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  late LatLng _center;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();

    _center = LatLng(widget.latitude, widget.longitude);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToUserLocation();
    });
  }

  // =======================
  // 📍 Ambil lokasi user
  // =======================
  Future<void> _moveToUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _center = LatLng(position.latitude, position.longitude);
      _mapController.move(_center, 16);
    } catch (_) {
      // kalau permission ditolak, map tetap jalan
    }
  }

  // =======================
  // 📌 Load marker todo
  // =======================
  void _loadMarkers(List<Todo> todos) {
    final newMarkers = <Marker>[];

    // marker lokasi user / center
    newMarkers.add(
      Marker(
        point: _center,
        width: 40,
        height: 40,
        child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
      ),
    );

    for (final todo in todos) {
      if (todo.latitude == null || todo.longitude == null) continue;

      newMarkers.add(
        Marker(
          point: LatLng(todo.latitude!, todo.longitude!),
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_on,
            color: todo.isDone ? Colors.green : Colors.red,
            size: 36,
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  // =======================
  // 🔍 Search lokasi (OSM)
  // =======================
  Future<void> _searchLocation() async {
    final query = await showDialog<String>(
      context: context,
      builder: (_) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Cari lokasi'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Contoh: Monas Jakarta',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Cari'),
            ),
          ],
        );
      },
    );

    if (query == null || query.isEmpty) return;

    final results = await OSMSearchService.search(query);
    if (results.isEmpty) return;

    final location = OSMSearchService.parseLatLng(results.first);

    _mapController.move(location, 16);
  }

  // =======================
  // 🧱 UI
  // =======================
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarkers(provider.todos);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Todo (OpenStreetMap)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchLocation,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _moveToUserLocation,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _center, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.todoapp',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
