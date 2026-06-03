import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class AvailabilityDatePickerDialog extends StatefulWidget {
  const AvailabilityDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.availabilityByDate,
    this.isSelectableDate,
    this.title = 'Chon ngay',
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Map<String, bool> availabilityByDate;
  final bool Function(DateTime date)? isSelectableDate;
  final String title;

  @override
  State<AvailabilityDatePickerDialog> createState() =>
      _AvailabilityDatePickerDialogState();
}

class _AvailabilityDatePickerDialogState
    extends State<AvailabilityDatePickerDialog> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(widget.initialDate);
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dong',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMonthHeader(),
              const SizedBox(height: 10),
              _buildWeekdays(),
              const SizedBox(height: 6),
              _buildCalendarGrid(),
              const SizedBox(height: 12),
              const _AvailabilityLegend(),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Huy'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isSelectable(_selectedDate)
                        ? () => Navigator.of(context).pop(_selectedDate)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                    ),
                    child: const Text('Chon ngay'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    final canGoPrevious = DateTime(_visibleMonth.year, _visibleMonth.month - 1)
        .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month - 1));
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    final canGoNext = !nextMonth
        .isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));

    return Row(
      children: [
        IconButton(
          onPressed: canGoPrevious
              ? () => setState(() {
                    _visibleMonth =
                        DateTime(_visibleMonth.year, _visibleMonth.month - 1);
                  })
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Thang ${_visibleMonth.month}/${_visibleMonth.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: canGoNext
              ? () => setState(() {
                    _visibleMonth =
                        DateTime(_visibleMonth.year, _visibleMonth.month + 1);
                  })
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdays() {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    final leadingDays = firstOfMonth.weekday - 1;
    final firstCell = firstOfMonth.subtract(Duration(days: leadingDays));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final date = firstCell.add(Duration(days: index));
        return _buildDayCell(date);
      },
    );
  }

  Widget _buildDayCell(DateTime date) {
    final day = _dateOnly(date);
    final isCurrentMonth = day.month == _visibleMonth.month;
    final outOfRange = day.isBefore(_dateOnly(widget.firstDate)) ||
        day.isAfter(_dateOnly(widget.lastDate));
    final available = _availabilityFor(day);
    final selectable = _isSelectable(day);
    final selected = _sameDay(day, _selectedDate);

    final Color background;
    final Color borderColor;
    final Color textColor;
    if (!isCurrentMonth || outOfRange) {
      background = const Color(0xFFF1F5F9);
      borderColor = AppColors.divider;
      textColor = AppColors.textSecondary.withValues(alpha: 0.45);
    } else if (!available) {
      background = const Color(0xFFFFE2E2);
      borderColor = const Color(0xFFEF4444);
      textColor = const Color(0xFFB91C1C);
    } else {
      background = const Color(0xFFE2F8EA);
      borderColor = const Color(0xFF22C55E);
      textColor = const Color(0xFF15803D);
    }

    return InkWell(
      onTap: selectable
          ? () {
              setState(() {
                _selectedDate = day;
              });
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.colorPrimary : background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.colorPrimary : borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }

  bool _isSelectable(DateTime date) {
    final day = _dateOnly(date);
    if (day.isBefore(_dateOnly(widget.firstDate)) ||
        day.isAfter(_dateOnly(widget.lastDate))) {
      return false;
    }
    if (!_availabilityFor(day)) return false;
    return widget.isSelectableDate?.call(day) ?? true;
  }

  bool _availabilityFor(DateTime date) {
    return widget.availabilityByDate[_dateKey(date)] ?? true;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _sameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _AvailabilityLegend extends StatelessWidget {
  const _AvailabilityLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendItem(
          color: Color(0xFFE2F8EA),
          borderColor: Color(0xFF22C55E),
          label: 'Con phong',
        ),
        _LegendItem(
          color: Color(0xFFFFE2E2),
          borderColor: Color(0xFFEF4444),
          label: 'Het phong',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
