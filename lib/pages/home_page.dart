import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../services/database_service.dart';
import '../models/note_model.dart';

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
  Note? _editingNote; // Untuk edit mode

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
      // CREATE - Tambah note baru
      final newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _database.insertNote(newNote);
    } else {
      // UPDATE - Edit note existing
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
    _loadNotes(); // Reload data dari database
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
    _loadNotes(); // Reload data
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
            child: const Text('Tutup'),
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
      barrierLabel: _editingNote == null ? "Tambah Catatan" : "Edit Catatan",
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.25),
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C4033),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Judul",
                        filled: true,
                        fillColor: const Color(0xFFFFF5E4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _contentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Isi Catatan",
                        filled: true,
                        fillColor: const Color(0xFFFFF5E4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _addOrUpdateNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB29470),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        _editingNote == null ? "Simpan" : "Update",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
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

  void _logout() async {
    await prefs.clear();
    await _database.deleteAllNotes(); // Hapus semua data user
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final username = prefs.username;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB29470),
        elevation: 0,
        title: Text(
          "Halo, $username 👋",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(
              child: Text(
                "Belum ada catatan",
                style: TextStyle(
                  color: Color(0xFF8B7355),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5E4),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF5C4033),
                      ),
                    ),
                    subtitle: Text(
                      note.content.length > 100
                          ? '${note.content.substring(0, 100)}...'
                          : note.content,
                      style: const TextStyle(
                        color: Color(0xFF8B7355),
                        height: 1.4,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFFB29470),
                          ),
                          onPressed: () => _editNote(note),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Color(0xFFB29470),
                          ),
                          onPressed: () => _deleteNote(note.id!),
                        ),
                      ],
                    ),
                    onTap: () => _showNoteDetails(note),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB29470),
        onPressed: () {
          _resetForm();
          _showNoteDialog();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
