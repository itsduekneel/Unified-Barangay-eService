import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarContainer extends StatefulWidget {
  /// Optional callback fired whenever the user taps a date.
  /// This is the only addition — all logic and UI are untouched.
  final ValueChanged<DateTime>? onDateChanged;

  const CalendarContainer({super.key, this.onDateChanged});

  @override
  State<CalendarContainer> createState() => _CalendarContainerState();
}

class _CalendarContainerState extends State<CalendarContainer> {
  late DateTime focusedMonth;
  late DateTime selectedDay;
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    focusedMonth = DateTime(now.year, now.month);
    selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _containerDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthSelector(),
          _buildWeekdayHeader(),
          const Divider(height: 1),
          if (isExpanded) _buildCalendarGrid(),
          const Divider(height: 1),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(focusedMonth),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: Color(0xFF8B2CF5),
                ),
                onPressed: () => _changeMonth(-1),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xFF8B2CF5),
                ),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: days
            .map(
              (day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  color: Color(0xFF8B2CF5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final weeks = _generateCalendarDays();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Table(
        children: weeks
            .map(
              (week) => TableRow(
            children: week.map((day) => _buildDayCell(day)).toList(),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildDayCell(int? day) {
    if (day == null) return const SizedBox.shrink();

    final date = DateTime(focusedMonth.year, focusedMonth.month, day);
    final isSelected = _isSameDay(date, selectedDay);

    return GestureDetector(
      onTap: () {
        setState(() => selectedDay = date);
        widget.onDateChanged?.call(date); // ← only addition
      },
      child: Container(
        height: 32,
        margin: const EdgeInsets.symmetric(vertical: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B2CF5) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + offset);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<List<int?>> _generateCalendarDays() {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;

    List<List<int?>> weeks = [];
    List<int?> week = List.filled(7, null);

    int currentDay = 1;
    for (int i = startOffset; i < 7; i++) {
      week[i] = currentDay++;
    }
    weeks.add(week);

    while (currentDay <= lastDay) {
      week = List.filled(7, null);
      for (int i = 0; i < 7 && currentDay <= lastDay; i++) {
        week[i] = currentDay++;
      }
      weeks.add(week);
    }
    return weeks;
  }
}
