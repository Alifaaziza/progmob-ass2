import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import '../models/todo.dart';
import '../services/location_service.dart';
import 'pick_location_page.dart';

class AddTodoPage extends StatefulWidget {
  final Function(Todo) onAdd;
  final Todo? todoToEdit; // TAMBAHKAN INI: parameter untuk edit

  const AddTodoPage({
    super.key, 
    required this.onAdd,
    this.todoToEdit, // TAMBAHKAN INI
  });

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

  @override
  void initState() {
    super.initState();
    
    // TAMBAHKAN INI: Isi form dengan data todoToEdit jika ada
    if (widget.todoToEdit != null) {
      _titleController.text = widget.todoToEdit!.title;
      _selectedDate = widget.todoToEdit!.date ?? DateTime.now();
      
      if (widget.todoToEdit!.latitude != null && 
          widget.todoToEdit!.longitude != null) {
        _pickedLocation = LatLng(
          widget.todoToEdit!.latitude!,
          widget.todoToEdit!.longitude!,
        );
        _address = widget.todoToEdit!.address;
      }
    }
  }

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

    // Hanya ambil alamat baru jika lokasi berubah atau belum ada alamat
    try {
  final placemarks = await placemarkFromCoordinates(
    _pickedLocation!.latitude,
    _pickedLocation!.longitude,
  );
  if (placemarks.isNotEmpty) {
    final placemark = placemarks.first;
    _address = '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}';
  } else {
    _address = '${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}';
  }
} catch (e) {
  _address = '${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}';
}

    // TAMBAHKAN INI: Buat todo dengan ID lama jika edit
    final todo = Todo(
      id: widget.todoToEdit?.id, // Simpan ID lama jika edit
      title: _titleController.text,
      address: _address!,
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
      date: _selectedDate, // ✅ FIX
      isDone: widget.todoToEdit?.isDone ?? false, // Pertahankan status isDone
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
      // TAMBAHKAN INI: Judul dinamis berdasarkan mode
      appBar: AppBar(
        title: Text(widget.todoToEdit != null ? 'Edit Todo' : 'Tambah Todo'),
      ),
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

            // TAMBAHKAN INI: Tampilkan alamat lama jika mode edit
            if (_address != null && widget.todoToEdit != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Lokasi: $_address',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveTodo,
                child: _loading
                    ? const CircularProgressIndicator()
                    // TAMBAHKAN INI: Teks dinamis berdasarkan mode
                    : Text(widget.todoToEdit != null ? 'Update Todo' : 'Simpan Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}