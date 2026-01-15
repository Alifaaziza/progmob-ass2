import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/prefs_service.dart';
import '../models/note_model.dart';

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
      context.read<HomeProvider>().loadTodos();
      context.read<HomeProvider>().checkNearbyTodos();
      final homeProvider = context.read<HomeProvider>();
      homeProvider.locationChecker.checkNearbyTodos(homeProvider.todos);
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
            icon: Icon(
              themeNotifier.value ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () {
              themeNotifier.value = !themeNotifier.value;
              PrefsService.instance.setDarkMode(themeNotifier.value);
            },
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

              const SizedBox(height: 20),

              // TODO SECTION
              Text(
                "Todo + Lokasi",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),

              if (provider.todos.isEmpty) const Text("Belum ada todo"),

              ...provider.todos.map(
                (todo) => Dismissible(
                  key: Key(todo.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    if (todo.id != null) {
                      provider.deleteTodo(todo.id!);
                    }
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
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
                      trailing: IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: () {
                          if (todo.latitude != null && todo.longitude != null) {
                            openMap(todo.latitude!, todo.longitude!);
                          }
                        },
                      ),
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
            MaterialPageRoute(builder: (_) => const AddTodoPage()),
          );
        },
      ),
    );
  }
}
