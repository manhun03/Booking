import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({
    super.key,
    this.room,
    this.hotel,
    this.customer,
    this.paymentMethod,
    this.roomCount = 1,
    this.checkInDate,
    this.checkOutDate,
    this.booking,
    this.payment,
  });

  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;
  final Map<String, dynamic>? customer;
  final String? paymentMethod;
  final int roomCount;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final Map<String, dynamic>? booking;
  final Map<String, dynamic>? payment;

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), _goToBill);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      backgroundColor: AppColors.colorBg,
      mobileBody: Center(child: _buildSuccessCard()),
      desktopBody: WebAppShell(
        title: 'Booking Complete',
        subtitle:
            'Booking da duoc ghi nhan. He thong se chuyen sang trang xac nhan trong giay lat.',
        selectedIndex: 2,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: WebPanel(child: _buildSuccessCard(compact: false)),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard({bool compact = true}) {
    return Container(
      width: compact ? 186 : double.infinity,
      height: compact ? 286 : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 28,
        vertical: compact ? 0 : 34,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 88,
            color: AppColors.colorPrimary,
          ),
          SizedBox(height: 18),
          Text(
            'Booking',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.colorPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'complete',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _goToBill() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/bill',
      arguments: {
        'room': widget.room,
        'hotel': widget.hotel,
        'customer': widget.customer,
        'paymentMethod': widget.paymentMethod,
        'roomCount': widget.roomCount,
        'checkInDate': widget.checkInDate,
        'checkOutDate': widget.checkOutDate,
        'booking': widget.booking,
        'payment': widget.payment,
      },
    );
  }
}
