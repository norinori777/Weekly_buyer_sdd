import 'package:flutter/material.dart';

import '../domain/weekly_shopping_models.dart';

class WeekHeader extends StatelessWidget {
  const WeekHeader({
    super.key,
    required this.weekRange,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final WeekRange weekRange;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final weekDays = List.generate(7, (index) => weekRange.start.add(Duration(days: index)));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final velocityX = details.velocity.pixelsPerSecond.dx;
        if (velocityX.abs() < 120) {
          return;
        }

        if (velocityX < 0) {
          onDateSelected(_shiftDay(weekDays, selectedDate, 1));
        } else {
          onDateSelected(_shiftDay(weekDays, selectedDate, -1));
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatWeekLabel(weekRange),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final day in weekDays)
                    ChoiceChip(
                      selected: dateOnly(day) == dateOnly(selectedDate),
                      label: Text(_weekdayLabel(day)),
                      onSelected: (_) => onDateSelected(day),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _shiftDay(List<DateTime> weekDays, DateTime selectedDate, int deltaDays) {
    final normalized = dateOnly(selectedDate);
    final currentIndex = weekDays.indexWhere((day) => dateOnly(day) == normalized);
    if (currentIndex == -1) {
      return normalized;
    }

    final nextIndex = (currentIndex + deltaDays).clamp(0, weekDays.length - 1);
    return weekDays[nextIndex];
  }

  String _weekdayLabel(DateTime date) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return '${weekdays[date.weekday - 1]} ${date.month}/${date.day}';
  }
}