import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PrefsService prefs = PrefsService.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<Map<String, String>> _notes = [];

  void _addNote() {
    if (_titleController.text.isEmpty &&
        _contentController.text.isEmpty) return;

    setState(() {
      _notes.add({
        'title': _titleController.text,
        'content': _contentController.text,
      });
    });

    _titleController.clear();
    _contentController.clear();
    Navigator.pop(context);
  }

  void _showAddNoteDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tambah Catatan",
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
                    color: Colors.brown.withOpacity(0.25),
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
                    const Text(
                      "Tambah Catatan",
                      style: TextStyle(
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
                            borderRadius: BorderRadius.circular(14)),
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
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _addNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB29470),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = prefs.username; // sudah aman

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
            onPressed: () async {
              await prefs.clear(); // ← yang benar

              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: _notes.isEmpty
          ? const Center(
              child: Text(
                "Belum ada catatan",
                style: TextStyle(
                    color: Color(0xFF8B7355),
                    fontSize: 16,
                    fontStyle: FontStyle.italic),
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
                        color: Colors.brown.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      note['title']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF5C4033)),
                    ),
                    subtitle: Text(
                      note['content']!,
                      style: const TextStyle(
                        color: Color(0xFF8B7355),
                        height: 1.4,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFB29470)),
                      onPressed: () {
                        setState(() {
                          _notes.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB29470),
        onPressed: _showAddNoteDialog,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded,
            color: Colors.white, size: 28),
      ),
    );
  }
}
