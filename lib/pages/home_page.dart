import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/prefs_service.dart';
import '../models/note_model.dart';
import '../models/todo.dart';
import '../pages/add_todo_page.dart';
import '../pages/CalendarPage.dart';
import '../pages/map_page.dart';
import '../providers/home_provider.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PrefsService prefs = PrefsService.instance;

  // NOTE CONTROLLER
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Note> _notes = [];
  bool _isLoading = true;
  Note? _editingNote;

  @override
  void initState() {
    super.initState();
    _updateLastAppOpen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeProvider>();
      provider.loadTodos();
      provider.getCurrentLocation(); // Ambil lokasi saat init
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateLastAppOpen() {
    prefs.setLastAppOpen(DateTime.now());
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
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void openMap(double lat, double lng) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPage(latitude: lat, longitude: lng),
      ),
    );
  }

  // =========================
  // EDIT TODO FUNCTION
  // =========================
  void _editTodo(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTodoPage(
          todoToEdit: todo,
          onAdd: (updatedTodo) async {
            final provider = context.read<HomeProvider>();
            await provider.database.updateTodo(updatedTodo);
            await provider.loadTodos();
          },
        ),
      ),
    );
  }

  // =========================
  // DELETE TODO FUNCTION
  // =========================
  void _deleteTodo(Todo todo) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Todo'),
        content: Text('Yakin ingin menghapus "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = context.read<HomeProvider>();
      await provider.database.deleteTodo(todo.id!);
      await provider.loadTodos();
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${todo.title}" telah dihapus'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper untuk warna mode aplikasi
  Color _getModeColor(String mode) {
    if (mode.contains('Pagi')) return Colors.orange;
    if (mode.contains('Siang')) return Colors.blue;
    if (mode.contains('Malam')) return Colors.purple;
    if (mode.contains('Tengah Malam')) return Colors.indigo;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final username = prefs.username;
    final lastOpen = prefs.lastAppOpen;
    final formatted =
        "${lastOpen.day}/${lastOpen.month}/${lastOpen.year} ${lastOpen.hour}:${lastOpen.minute}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Halo, $username"),
        actions: [
          IconButton(
            icon: Icon(prefs.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarPage()),
              );
            },
          ),
        ],
      ),

      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          // Auto refresh lokasi
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.currentPosition == null) {
              provider.getCurrentLocation();
            }
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // LAST OPEN
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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

              const SizedBox(height: 16),

              // =============== LOKASI & CUACA ===============
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    const Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Lokasi & Cuaca',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // STATUS LOKASI
                    if (provider.currentPosition == null)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Mengambil lokasi...'),
                        ],
                      )
                    else ...[
                      // NAMA LOKASI (GANTI KOORDINAT DENGAN NAMA LOKASI)
                      Row(
                        children: [
                          const Icon(Icons.place, size: 14, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // NAMA LOKASI
                                Text(
                                  provider.locationName, // NAMA LOKASI DARI PROVIDER
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // KOORDINAT KECIL (OPSIONAL)
                                const SizedBox(height: 2),
                                Text(
                                  '${provider.currentPosition!.latitude.toStringAsFixed(4)}, '
                                  '${provider.currentPosition!.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // MODE APLIKASI
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getModeColor(provider.appMode),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              provider.appMode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // CUACA
                      if (provider.weatherData != null)
                        Row(
                          children: [
                            const Icon(Icons.cloud, size: 14, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.getWeatherDescription(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      else
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Mengambil data cuaca...'),
                          ],
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =============== TODO DEKAT ANDA ===============
              if (provider.nearbyTodos.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.near_me, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Todo Dekat Anda',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dalam radius 5 km dari lokasi Anda',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          ...provider.nearbyTodos.map((todo) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.place, size: 14, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        todo.address ?? '-',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // =============== SEMUA TODO ===============
              Text(
                "Todo + Lokasi",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),

              if (provider.todos.isEmpty) 
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.list, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Belum ada todo'),
                      Text('Tambahkan todo pertama Anda!', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),

              ...provider.todos.map(
                (todo) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (_) {
                        provider.toggleTodoDone(todo);
                      },
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(todo.address ?? '-'),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'location',
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 18),
                              SizedBox(width: 8),
                              Text('Lihat Lokasi'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editTodo(todo);
                        } else if (value == 'delete') {
                          _deleteTodo(todo);
                        } else if (value == 'location' && todo.latitude != null && todo.longitude != null) {
                          openMap(todo.latitude!, todo.longitude!);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTodoPage(
                onAdd: (todo) async {
                  final provider = context.read<HomeProvider>();
                  await provider.database.insertTodo(todo);
                  await provider.loadTodos();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}