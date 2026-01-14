import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class HomeProvider extends ChangeNotifier {
  final DatabaseService database;

  List<Todo> _todos = [];

  HomeProvider({required this.database});

  List<Todo> get todos => _todos;

  Future<void> loadTodos() async {
    _todos = await database.getTodos();
    notifyListeners();
  }

  Future<void> checkNearbyTodos() async {
    final position = await LocationService.getCurrentLocation();

    for (final todo in _todos) {
      if (todo.latitude == null || todo.longitude == null) continue;

      final distance = LocationService.calculateDistance(
        position.latitude,
        position.longitude,
        todo.latitude!,
        todo.longitude!,
      );

      if (distance <= 200 && !todo.isDone) {
        debugPrint('Todo dekat lokasi: ${todo.title}');
        // nanti masuk ke NotificationService
      }
    }
  }

  Future<void> toggleTodoDone(Todo todo) async {
    todo.isDone = !todo.isDone;
    await database.updateTodo(todo);
    notifyListeners();
  }
}
