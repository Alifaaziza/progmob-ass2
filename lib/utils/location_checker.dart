import 'package:geolocator/geolocator.dart';
import '../models/todo.dart';
import '../services/notification_service.dart';

class LocationChecker {
  final NotificationService notificationService;

  LocationChecker({required this.notificationService});

  Future<void> checkNearbyTodos(List<Todo> todos) async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    for (final todo in todos) {
      if (todo.latitude == null || todo.longitude == null || todo.isDone) {
        continue;
      }

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        todo.latitude!,
        todo.longitude!,
      );

      if (distance <= 100) {
        await notificationService.showTodoNearby(todo);
      }
    }
  }
}
