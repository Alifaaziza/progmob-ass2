import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  LatLng selectedLocation = const LatLng(-6.2088, 106.8456); // Jakarta

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedLocation);
            },
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedLocation,
          zoom: 14,
        ),
        onTap: (latLng) {
          setState(() {
            selectedLocation = latLng;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId('picked'),
            position: selectedLocation,
          ),
        },
      ),
    );
  }
}
