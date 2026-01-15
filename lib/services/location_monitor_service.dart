import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/todo.dart';
import 'notification_service.dart';
import 'location_service.dart';

class LocationMonitorService {
  final LocationService locationService;
  final NotificationService notificationService;

  StreamSubscription<Position>? _subscription;
  final Set<int> _notifiedTodoIds = {};

  LocationMonitorService({
    required this.locationService,
    required this.notificationService,
  });

  // =========================
  // ▶️ START MONITORING
  // =========================
  void start(List<Todo> todos) {
    if (_subscription != null) return; // prevent double start

    _subscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 20, // update tiap 20 meter
          ),
        ).listen((position) {
          for (final todo in todos) {
            if (todo.id == null) continue;
            if (todo.latitude == null || todo.longitude == null) continue;
            if (todo.isDone) continue;
            if (_notifiedTodoIds.contains(todo.id)) continue;

            final distance = locationService.calculateDistance(
              position.latitude,
              position.longitude,
              todo.latitude!,
              todo.longitude!,
            );

            if (distance <= 100) {
              _notifiedTodoIds.add(todo.id!);
              notificationService.showTodoNearby(todo);
            }
          }
        });
  }

  // =========================
  // ⏹ STOP MONITORING
  // =========================
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _notifiedTodoIds.clear();
  }
}
