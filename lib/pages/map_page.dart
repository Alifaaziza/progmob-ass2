import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapPage({super.key, required this.latitude, required this.longitude});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late CameraPosition _initialPosition;

  @override
  void initState() {
    super.initState();

    _initialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng todoLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text("Lokasi Todo")),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: {
          Marker(
            markerId: const MarkerId("todo_location"),
            position: todoLocation,
            infoWindow: const InfoWindow(title: "Lokasi Todo"),
          ),
        },
        myLocationEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
