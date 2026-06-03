import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class ChangeBookingTimeScreen extends StatefulWidget {
  const ChangeBookingTimeScreen({
    super.key,
    this.booking,
  });

  final Map<String, dynamic>? booking;

  @override
  State<ChangeBookingTimeScreen> createState() =>
      _ChangeBookingTimeScreenState();
}

class _ChangeBookingTimeScreenState extends State<ChangeBookingTimeScreen> {
  String? _checkInTime;
  String? _checkOutTime;

  static const List<String> _times = [
    '8:00',
    '9:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(40, 12, 40, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(_buildFormContent()),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: 'Thay đổi thời gian',
        subtitle:
            'Chọn lại giờ check-in và check-out cho đơn đặt phòng trên giao diện form rộng, dễ thao tác hơn.',
        selectedIndex: 2,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: WebPanel(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFormContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormContent() {
    return [
      _buildTimeRow(
        label: 'Check in',
        value: _checkInTime,
        onChanged: (value) {
          setState(() {
            _checkInTime = value;
          });
        },
      ),
      const SizedBox(height: 20),
      _buildTimeRow(
        label: 'Check out',
        value: _checkOutTime,
        onChanged: (value) {
          setState(() {
            _checkOutTime = value;
          });
        },
      ),
      const SizedBox(height: 28),
      _buildSubmitButton(),
    ];
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
              'Thay đổi thời gian',
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

  Widget _buildTimeRow({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 36,
            child: DropdownButtonFormField<String>(
              initialValue: value,
              onChanged: onChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 21,
                color: AppColors.textPrimary,
              ),
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(color: Color(0xFFB8C0CC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(color: Color(0xFFB8C0CC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: const BorderSide(color: AppColors.colorPrimary),
                ),
              ),
              dropdownColor: AppColors.white,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              items: _times
                  .map(
                    (time) => DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
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
    );
  }
}
