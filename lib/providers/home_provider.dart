import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/location_monitor_service.dart';
import '../utils/location_checker.dart';

class HomeProvider extends ChangeNotifier {
  final DatabaseService database;
  final LocationService locationService;
  final LocationMonitorService locationMonitorService;
  final LocationChecker locationChecker;

  HomeProvider({
    required this.database,
    required this.locationService,
    required this.locationMonitorService,
    required this.locationChecker,
  });

  List<Todo> _todos = [];
  bool _monitorStarted = false;

  List<Todo> get todos => _todos;

  // =====================
  // 📥 LOAD TODOS
  // =====================
  Future<void> loadTodos() async {
    _todos = await database.getTodos();
    notifyListeners();

    // start monitoring SEKALI
    if (!_monitorStarted) {
      locationMonitorService.start(_todos);
      _monitorStarted = true;
    }
  }

  // =====================
  // ➕ ADD TODO
  // =====================
  Future<void> addTodo(Todo todo) async {
    final id = await database.insertTodo(todo);
    todo.id = id;

    _todos.add(todo);
    notifyListeners();
  }

  // =====================
  // 📍 CHECK NEARBY TODO
  // =====================
  Future<void> checkNearbyTodos() async {
    final position = await locationService.getCurrentLocation();

    for (final todo in _todos) {
      if (todo.latitude == null || todo.longitude == null) continue;
      if (todo.isDone) continue;

      final distance = locationService.calculateDistance(
        position.latitude,
        position.longitude,
        todo.latitude!,
        todo.longitude!,
      );

      if (distance <= 200) {
        debugPrint('🔔 Todo dekat lokasi: ${todo.title}');
        // nanti:
        // notificationService.show(todo);
      }
    }
  }

  // =====================
  // ✅ TOGGLE DONE
  // =====================
  Future<void> toggleTodoDone(Todo todo) async {
    todo.isDone = !todo.isDone;
    await database.updateTodo(todo);
    notifyListeners();
  }

  // =====================
  // ❌ DELETE TODO
  // =====================
  Future<void> deleteTodo(int id) async {
    await database.deleteTodo(id);
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }
}
