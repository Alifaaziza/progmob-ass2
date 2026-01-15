import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../pages/pick_location_page.dart';
import '../providers/home_provider.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _titleController = TextEditingController();

  LatLng? _pickedLocation;
  bool _loading = false;
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
      });
    }
  }

  // ================= PICK DATE =================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
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

    final homeProvider = context.read<HomeProvider>();

    final address = await homeProvider.locationService.getAddress(
      _pickedLocation!.latitude,
      _pickedLocation!.longitude,
    );

    final todo = Todo(
      title: _titleController.text,
      address: address,
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
      date: _selectedDate,
    );

    await homeProvider.addTodo(todo);

    if (!mounted) return;
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
              onTap: _pickDate,
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map),
              label: const Text('Pilih Lokasi di Map'),
            ),

            const SizedBox(height: 12),

            if (_pickedLocation != null)
              Text(
                '📍 ${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}',
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
