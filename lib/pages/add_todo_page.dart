import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/todo.dart';
import '../services/location_service.dart';
import 'pick_location_page.dart';

class AddTodoPage extends StatefulWidget {
  final Function(Todo) onAdd;

  const AddTodoPage({super.key, required this.onAdd});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _titleController = TextEditingController();

  LatLng? _pickedLocation;
  String? _address;
  bool _loading = false;

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => const PickLocationPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _pickedLocation = result;
        _address = null;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (_titleController.text.isEmpty || _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul & lokasi wajib diisi')),
      );
      return;
    }

    setState(() => _loading = true);

    _address = await LocationService.getAddress(
      _pickedLocation!.latitude,
      _pickedLocation!.longitude,
    );

    final todo = Todo(
      title: _titleController.text,
      address: _address!,
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
    );

    widget.onAdd(todo);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Todo + Lokasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // JUDUL TODO
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Todo',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // PILIH LOKASI
            ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map),
              label: const Text('Pilih Lokasi di Map'),
            ),

            const SizedBox(height: 12),

            // INFO LOKASI
            if (_pickedLocation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latitude: ${_pickedLocation!.latitude}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    'Longitude: ${_pickedLocation!.longitude}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),

            const Spacer(),

            // SIMPAN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveTodo,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
