import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


import '../services/prefs_service.dart';
import '../services/database_service.dart';
import '../models/note_model.dart';
import '../models/todo.dart';
import '../pages/add_todo_page.dart';
import '../main.dart'; // themeNotifier

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PrefsService prefs = PrefsService.instance;
  final DatabaseService _database = DatabaseService();

  // NOTE CONTROLLER
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // STATE
  List<Note> _notes = [];
  List<Todo> _todos = [];
  bool _isLoading = true;
  Note? _editingNote;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _updateLastAppOpen();
  }

  void _updateLastAppOpen() {
    prefs.setLastAppOpen(DateTime.now());
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _database.getNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  // =========================
  // NOTE SECTION
  // =========================
  void _addOrUpdateNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) return;

    if (_editingNote == null) {
      final newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _database.insertNote(newNote);
    } else {
      final updatedNote = Note(
        id: _editingNote!.id,
        title: _titleController.text,
        content: _contentController.text,
        createdAt: _editingNote!.createdAt,
        updatedAt: DateTime.now(),
      );
      _database.updateNote(updatedNote);
    }

    _resetForm();
    _loadNotes();
    Navigator.pop(context);
  }

  void _editNote(Note note) {
    _editingNote = note;
    _titleController.text = note.title;
    _contentController.text = note.content;
    _showNoteDialog();
  }

  void _deleteNote(int id) async {
    await _database.deleteNote(id);
    _loadNotes();
  }

  void _resetForm() {
    _titleController.clear();
    _contentController.clear();
    _editingNote = null;
  }

  void _showNoteDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Note Dialog",
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondary) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _editingNote == null ? "Tambah Catatan" : "Edit Catatan",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Isi"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addOrUpdateNote,
                    child: Text(_editingNote == null ? "Simpan" : "Update"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => _resetForm());
  }

  // =========================
  // TODO + LOCATION
  // =========================
  Future<void> _addTodoWithLocation(Todo todo) async {
    setState(() {
      _todos.add(todo);
    });
  }

  // =========================
  // THEME & LOGOUT
  // =========================
  void _toggleTheme() {
    final newValue = !prefs.isDarkMode;
    prefs.setDarkMode(newValue);
    themeNotifier.value = newValue;
  }

  void _logout() async {
    await prefs.clear();
    await _database.deleteAllNotes();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final username = prefs.username;
    final lastOpen = prefs.lastAppOpen;
    final formatted =
        "${lastOpen.day}/${lastOpen.month}/${lastOpen.year} ${lastOpen.hour}:${lastOpen.minute}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Halo, $username 👋"),
        actions: [
          IconButton(
            icon:
                Icon(prefs.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // LAST OPEN
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 10),
                      Text("Terakhir dibuka: $formatted"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // TODO SECTION
                Text("Todo + Lokasi",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),

                ..._todos.map(
                  (todo) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(todo.title),
                      subtitle: Text(todo.address),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // NOTE SECTION
                Text("Catatan",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),

                ..._notes.map(
                  (note) => Card(
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(
                        note.content.length > 100
                            ? "${note.content.substring(0, 100)}..."
                            : note.content,
                      ),
                      onTap: () => _editNote(note),
                    ),
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTodoPage(
                onAdd: _addTodoWithLocation,
              ),
            ),
          );
        },
      ),
    );
  }
}
