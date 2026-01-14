import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/home_provider.dart';
import '../models/todo.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    List<Todo> selectedTodos = provider.todos.where((todo) {
      return isSameDay(todo.date, _selectedDay);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Task Calendar')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) {
              return provider.todos
                  .where((todo) => isSameDay(todo.date, day))
                  .toList();
            },
          ),

          const Divider(),

          Expanded(
            child: selectedTodos.isEmpty
                ? const Center(child: Text('Tidak ada task'))
                : ListView.builder(
                    itemCount: selectedTodos.length,
                    itemBuilder: (context, index) {
                      final todo = selectedTodos[index];
                      return ListTile(
                        title: Text(todo.title),
                        subtitle: Text(todo.address ?? '-'),
                        leading: Icon(
                          todo.isDone
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
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
