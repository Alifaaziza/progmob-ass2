import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/database_service.dart';
import '../models/note_model.dart';
import '../main.dart'; // IMPORTANT! supaya bisa akses themeNotifier

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PrefsService prefs = PrefsService.instance;
  final DatabaseService _database = DatabaseService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Note> _notes = [];
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

  void _addOrUpdateNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      return;
    }

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

  void _showNoteDetails(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(child: Text(note.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
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
                      decoration: const InputDecoration(
                        labelText: "Judul",
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: _contentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Isi Catatan",
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
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
          ),
        );
      },
    ).then((_) => _resetForm());
  }

  void _toggleTheme() {
    final newValue = !prefs.isDarkMode;

    prefs.setDarkMode(newValue);

    themeNotifier.value = newValue;

    setState(() {}); 
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
            icon: Icon(
              prefs.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
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
          : Column(
              children: [
                // LAST OPEN TIME
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
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
                ),

                Expanded(
                  child: _notes.isEmpty
                      ? const Center(child: Text("Belum ada catatan"))
                      : ListView.builder(
                          itemCount: _notes.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final note = _notes[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(note.title),
                                subtitle: Text(
                                  note.content.length > 100
                                      ? "${note.content.substring(0, 100)}..."
                                      : note.content,
                                ),
                                onTap: () => _showNoteDetails(note),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editNote(note),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _deleteNote(note.id!),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _resetForm();
          _showNoteDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
