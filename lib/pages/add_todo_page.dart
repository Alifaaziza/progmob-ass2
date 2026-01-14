import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

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

  // STATE TANGGAL
  DateTime _selectedDate = DateTime.now();

  // ================= PICK LOCATION =================
  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const PickLocationPage()),
    );

    if (result != null) {
      setState(() {
        _pickedLocation = result;
        _address = null;
      });
    }
  }

  // ================= PICK DATE =================
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ================= SAVE TODO =================
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
      date: _selectedDate, // ✅ FIX
    );

    widget.onAdd(todo);

    if (!mounted) return;

    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Todo + Lokasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Todo',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(context),
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map),
              label: const Text('Pilih Lokasi di Map'),
            ),

            const SizedBox(height: 12),

            if (_pickedLocation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latitude: ${_pickedLocation!.latitude}'),
                  Text('Longitude: ${_pickedLocation!.longitude}'),
                ],
              ),

            const Spacer(),

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
