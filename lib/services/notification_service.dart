import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/todo.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  Future<void> showTodoNearby(Todo todo) async {
    const androidDetails = AndroidNotificationDetails(
      'todo_location',
      'Todo Location',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      todo.id ?? 0,
      'Todo di Sekitarmu 📍',
      todo.title,
      details,
    );
  }
}
