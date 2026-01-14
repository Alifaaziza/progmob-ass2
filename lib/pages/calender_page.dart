import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../models/todo.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    final List<Todo> dailyTodos = provider.todos
        .where((todo) => _isSameDay(todo.date, _selectedDate))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          // ================= DATE NAV =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // ================= TODO LIST =================
          Expanded(
            child: dailyTodos.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada todo di tanggal ini',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: dailyTodos.length,
                    itemBuilder: (context, index) {
                      final todo = dailyTodos[index];

                      return ListTile(
                        leading: Icon(
                          todo.isDone
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: todo.isDone ? Colors.green : Colors.orange,
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
                        trailing: Checkbox(
                          value: todo.isDone,
                          onChanged: (_) {
                            provider.toggleTodoDone(todo);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
