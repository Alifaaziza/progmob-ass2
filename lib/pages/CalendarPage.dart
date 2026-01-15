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
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<Todo> selectedTodos = provider.todos
        .where((todo) => isSameDay(todo.date, _selectedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Calendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFD2B48C),
        foregroundColor: Colors.brown.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.brown.shade900, Colors.brown.shade800],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD2B48C).withOpacity(0.3),
                    Colors.brown.shade50,
                  ],
                ),
        ),
        child: Column(
          children: [
            // Calendar Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.brown.shade800 : const Color(0xFFD2B48C),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedDay.day} ${_getMonthName(_selectedDay.month)} ${_selectedDay.year}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.brown.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDayName(_selectedDay.weekday),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.brown.shade200
                              : Colors.brown.shade800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.brown.shade700
                          : Colors.brown.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${selectedTodos.length} Tasks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.brown.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Calendar
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: isDark ? Colors.brown.shade800 : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
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
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    cellMargin: const EdgeInsets.all(4),
                    defaultTextStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.brown.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                    weekendTextStyle: TextStyle(
                      color: isDark
                          ? Colors.orange.shade300
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.brown.shade600, Colors.brown.shade800],
                      ),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD2B48C),
                          Colors.brown.shade500,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: const Color(0xFFD2B48C),
                      shape: BoxShape.circle,
                    ),
                    markersAlignment: Alignment.bottomCenter,
                    markersMaxCount: 3,
                    markersAutoAligned: false,
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.brown.shade900,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.brown.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                    formatButtonDecoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFD2B48C)
                            : Colors.brown.shade400,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    formatButtonVisible: true,
                    titleCentered: true,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: isDark ? Colors.white : Colors.brown.shade900,
                      size: 28,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white : Colors.brown.shade900,
                      size: 28,
                    ),
                    headerPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: isDark
                          ? Colors.brown.shade200
                          : Colors.brown.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendStyle: TextStyle(
                      color: isDark
                          ? Colors.orange.shade300
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDayCell(
                        context,
                        day,
                        provider,
                        isDark: isDark,
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildDayCell(
                        context,
                        day,
                        provider,
                        isSelected: true,
                        isDark: isDark,
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildDayCell(
                        context,
                        day,
                        provider,
                        isToday: true,
                        isDark: isDark,
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tasks Section
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.brown.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: isDark
                                ? const Color(0xFFD2B48C)
                                : Colors.brown.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tasks for Today',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.brown.shade900,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.brown.shade700
                                  : const Color(0xFFD2B48C).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedTodos.length.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.brown.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: selectedTodos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_note,
                                    size: 60,
                                    color: isDark
                                        ? Colors.brown.shade400
                                        : Colors.brown.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tasks for this day',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.brown.shade300
                                          : Colors.brown.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap + to add a new task',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.brown.shade400
                                          : Colors.brown.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: selectedTodos.length,
                              itemBuilder: (context, index) {
                                final todo = selectedTodos[index];
                                return _buildTaskItem(todo, isDark);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Todo todo, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.brown.shade900 : Colors.brown.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: todo.isDone
                ? Colors.brown.shade100
                : const Color(0xFFD2B48C).withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: todo.isDone ? Colors.brown.shade800 : Colors.brown.shade700,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.brown.shade900,
            decoration: todo.isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: todo.address != null
            ? Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: isDark
                        ? Colors.brown.shade400
                        : Colors.brown.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      todo.address!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.brown.shade400
                            : Colors.brown.shade600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: todo.isDone
                ? Colors.brown.withOpacity(0.2)
                : const Color(0xFFD2B48C).withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            todo.isDone ? 'Done' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: todo.isDone
                  ? Colors.brown.shade800
                  : Colors.brown.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    HomeProvider provider, {
    bool isSelected = false,
    bool isToday = false,
    required bool isDark,
  }) {
    final todos = provider.todos
        .where((todo) => isSameDay(todo.date, day))
        .toList();

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isSelected
            ? LinearGradient(
                colors: [Colors.brown.shade600, Colors.brown.shade800],
              )
            : isToday
            ? LinearGradient(
                colors: [const Color(0xFFD2B48C), Colors.brown.shade500],
              )
            : null,
        color: isSelected || isToday
            ? null
            : isDark
            ? Colors.brown.shade900
            : Colors.brown.shade100,
        boxShadow: (isSelected || isToday)
            ? [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: 14,
                color: isSelected || isToday
                    ? Colors.white
                    : isDark
                    ? Colors.white
                    : Colors.brown.shade900,
              ),
            ),
            if (todos.isNotEmpty) ...[
              const SizedBox(height: 2),
              Wrap(
                spacing: 2,
                children: todos
                    .take(2)
                    .map(
                      (todo) => Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: todo.isDone
                              ? Colors.brown.shade400
                              : const Color(0xFFD2B48C),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
