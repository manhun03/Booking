import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/colors.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({
    Key? key,
    this.room,
    this.hotel,
    this.customer,
    this.paymentMethod,
    this.roomCount = 1,
  }) : super(key: key);

  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;
  final Map<String, dynamic>? customer;
  final String? paymentMethod;
  final int roomCount;

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
    return Scaffold(
      backgroundColor: AppColors.colorBg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Center(
              child: Container(
                width: 186,
                height: 286,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ),
          ),
        ),
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
      },
    );
  }
}
