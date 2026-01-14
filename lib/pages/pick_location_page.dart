import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/picked_place.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  final TextEditingController _searchController = TextEditingController();
  final _uuid = const Uuid();
  late String _sessionToken;

  LatLng selectedLocation = const LatLng(-6.2088, 106.8456);
  GoogleMapController? _mapController;

  bool _loadingMyLocation = false;
  bool _loadingPick = false;

  String _placeName = "Jakarta";
  String _address = "Indonesia";

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.v4();
  }

  Future<void> _goToMyLocation() async {
    setState(() => _loadingMyLocation = true);
    try {
      final pos = await LocationService.getCurrentLocation();
      final myLatLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        selectedLocation = myLatLng;
        _placeName = "Lokasi Saya";
        _address = "Koordinat dari GPS";
      });

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: myLatLng, zoom: 16),
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi kamu berhasil diambil ✅")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ambil lokasi: $e")),
      );
    } finally {
      if (mounted) setState(() => _loadingMyLocation = false);
    }
  }

  Future<void> _selectSuggestion(PlaceSuggestion s) async {
    setState(() => _loadingPick = true);
    try {
      final detail = await PlacesService.getDetail(
        placeId: s.placeId,
        sessionToken: _sessionToken,
      );

      final latLng = LatLng(detail.lat, detail.lng);

      setState(() {
        selectedLocation = latLng;
        _placeName = detail.name.isNotEmpty ? detail.name : s.mainText;
        _address = detail.formattedAddress.isNotEmpty
            ? detail.formattedAddress
            : s.secondaryText;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );

      _sessionToken = _uuid.v4();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ambil detail tempat: $e")),
      );
    } finally {
      if (mounted) setState(() => _loadingPick = false);
    }
  }

  void _confirm() {
    Navigator.pop(
      context,
      PickedPlace(
        location: selectedLocation,
        placeName: _placeName,
        address: _address,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadingMyLocation ? null : _goToMyLocation,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirm,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TypeAheadField<PlaceSuggestion>(
              controller: _searchController,
              debounceDuration: const Duration(milliseconds: 350),

              /// 🔒 OPSI A (AMAN)
              hideOnEmpty: true,
              hideOnLoading: false,

              /// Semua logic pesan di sini
              emptyBuilder: (context) {
                final q = _searchController.text.trim();

                if (q.isEmpty) {
                  return const SizedBox.shrink();
                }

                if (q.length < 3) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Ketik minimal 3 huruf untuk melihat saran.",
                    ),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Tidak ada saran. Coba kata lain.",
                  ),
                );
              },

              suggestionsCallback: (pattern) async {
                final q = pattern.trim();
                if (q.length < 3) return [];

                return PlacesService.autocomplete(
                  input: q,
                  sessionToken: _sessionToken,
                  countryCode: "id",
                );
              },

              itemBuilder: (context, s) {
                return ListTile(
                  leading: const Icon(Icons.place),
                  title: Text(s.mainText),
                  subtitle:
                      s.secondaryText.isEmpty ? null : Text(s.secondaryText),
                );
              },

              onSelected: (s) async => _selectSuggestion(s),

              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: "Cari tempat...",
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _loadingPick
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.search),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _placeName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _address,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: selectedLocation,
                zoom: 14,
              ),
              onMapCreated: (c) => _mapController = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onTap: (latLng) {
                setState(() {
                  selectedLocation = latLng;
                  _placeName = "Pin Lokasi";
                  _address = "Dipilih manual di peta";
                });
              },
              markers: {
                Marker(
                  markerId: const MarkerId('picked'),
                  position: selectedLocation,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
