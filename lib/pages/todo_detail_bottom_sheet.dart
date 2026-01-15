import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoDetailBottomSheet extends StatelessWidget {
  final Todo todo;

  const TodoDetailBottomSheet({super.key, required this.todo});

  void openNavigation() {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${todo.latitude},${todo.longitude}';
    launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todo.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            todo.address ?? 'Tidak ada alamat',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
