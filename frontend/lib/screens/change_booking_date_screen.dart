import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class ChangeBookingDateScreen extends StatefulWidget {
  const ChangeBookingDateScreen({
    Key? key,
    this.booking,
  }) : super(key: key);

  final Map<String, dynamic>? booking;

  @override
  State<ChangeBookingDateScreen> createState() =>
      _ChangeBookingDateScreenState();
}

class _ChangeBookingDateScreenState extends State<ChangeBookingDateScreen> {
  bool _showCalendar = false;

  static const List<_CalendarDay> _calendarDays = [
    _CalendarDay('31', muted: true),
    _CalendarDay('1'),
    _CalendarDay('2'),
    _CalendarDay('3'),
    _CalendarDay('4'),
    _CalendarDay('5'),
    _CalendarDay('6'),
    _CalendarDay('7'),
    _CalendarDay('8'),
    _CalendarDay('9'),
    _CalendarDay('10'),
    _CalendarDay('11'),
    _CalendarDay('12'),
    _CalendarDay('13'),
    _CalendarDay('14'),
    _CalendarDay('15'),
    _CalendarDay('16'),
    _CalendarDay('17'),
    _CalendarDay('18'),
    _CalendarDay('19'),
    _CalendarDay('20'),
    _CalendarDay('21'),
    _CalendarDay('22'),
    _CalendarDay('23'),
    _CalendarDay('24'),
    _CalendarDay('25'),
    _CalendarDay('26'),
    _CalendarDay('27'),
    _CalendarDay('28', selectedStart: true),
    _CalendarDay('29', inRange: true),
    _CalendarDay('30', selectedEnd: true),
    _CalendarDay('1', muted: true, inRange: true),
    _CalendarDay('2', muted: true, inRange: true),
    _CalendarDay('3', muted: true, inRange: true),
    _CalendarDay('4', muted: true, inRange: true),
    _CalendarDay('5', muted: true),
    _CalendarDay('6', muted: true),
    _CalendarDay('7', muted: true),
    _CalendarDay('8', muted: true),
    _CalendarDay('9', muted: true),
    _CalendarDay('10', muted: true),
    _CalendarDay('11', muted: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: Stack(
        children: [
          _buildMobilePageContent(context),
          if (_showCalendar) _buildCalendarOverlay(),
        ],
      ),
      desktopBody: Stack(
        children: [
          _buildDesktopPage(),
          if (_showCalendar) _buildCalendarOverlay(topPadding: 190),
        ],
      ),
    );
  }

  Widget _buildDesktopPage() {
    final page = WebAppShell(
      title: 'Thay đổi ngày đặt',
      subtitle:
          'Cập nhật ngày nhận phòng, ngày trả phòng hoặc chuyển sang thay đổi thời gian check-in/check-out.',
      selectedIndex: 2,
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: WebPanel(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSummary(),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: _buildPrimaryButton()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSecondaryButton()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!_showCalendar) return page;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
      child: page,
    );
  }

  Widget _buildMobilePageContent(BuildContext context) {
    final page = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildDateSummary(),
                const SizedBox(height: 26),
                _buildPrimaryButton(),
                const SizedBox(height: 18),
                _buildSecondaryButton(),
              ],
            ),
          ),
        ),
      ],
    );

    if (!_showCalendar) return page;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
      child: page,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Thay đổi ngày đặt',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSummary() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildDateBlock(
              label: 'Nhận phòng',
              date: '28 thg 10 2025',
              time: 'từ 8:00',
            ),
          ),
          const VerticalDivider(
            width: 26,
            thickness: 1,
            color: Color(0xFFD8DDE6),
          ),
          Expanded(
            child: _buildDateBlock(
              label: 'Trả phòng',
              date: '30 thg 10 2025',
              time: 'từ 8:00',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBlock({
    required String label,
    required String date,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          date,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          time,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _showCalendar = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Thay đổi ngày',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/change-booking-time',
            arguments: widget.booking,
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0D87FF),
          side: const BorderSide(color: Color(0xFF0D87FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Thay đổi thời gian',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D87FF),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarOverlay({double topPadding = 154}) {
    return Positioned.fill(
      child: Container(
        color: AppColors.colorBg.withValues(alpha: 0.34),
        padding: EdgeInsets.fromLTRB(48, topPadding, 48, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: _buildCalendarCard(),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Chọn ngày',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'October 2025',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildCalendarIconButton(Icons.arrow_upward),
              const SizedBox(width: 10),
              _buildCalendarIconButton(Icons.arrow_downward),
            ],
          ),
          const SizedBox(height: 11),
          _buildWeekdays(),
          const SizedBox(height: 6),
          _buildCalendarGrid(),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showCalendar = false;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF2D55),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(52, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 95,
                height: 34,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showCalendar = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Thay đổi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarIconButton(IconData icon) {
    return SizedBox(
      width: 18,
      height: 18,
      child: IconButton(
        onPressed: () {},
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 17,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildWeekdays() {
    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        for (var row = 0; row < 6; row++) ...[
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: _buildDayCell(_calendarDays[row * 7 + col]),
                ),
            ],
          ),
          if (row < 5) const SizedBox(height: 9),
        ],
      ],
    );
  }

  Widget _buildDayCell(_CalendarDay day) {
    final selected = day.selectedStart || day.selectedEnd;
    final textColor = selected
        ? AppColors.white
        : day.muted
            ? const Color(0xFF9BA6B5)
            : AppColors.textPrimary;

    Widget child = Center(
      child: Text(
        day.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: textColor,
        ),
      ),
    );

    if (day.inRange && !selected) {
      child = Container(
        width: double.infinity,
        height: 28,
        alignment: Alignment.center,
        color: const Color(0xFFE6F4FF),
        child: child,
      );
    }

    if (selected) {
      child = Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: Color(0xFF0D87FF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      );
    }

    return SizedBox(
      height: 19,
      child: Center(child: child),
    );
  }
}

class _CalendarDay {
  const _CalendarDay(
    this.label, {
    this.muted = false,
    this.inRange = false,
    this.selectedStart = false,
    this.selectedEnd = false,
  });

  final String label;
  final bool muted;
  final bool inRange;
  final bool selectedStart;
  final bool selectedEnd;
}
