import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final int? bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  Map<String, dynamic>? _booking;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.bookingId == null) {
      setState(() {
        _error = 'Khong tim thay ma booking.';
        _loading = false;
      });
      return;
    }
    try {
      final booking = await _api.fetchBooking(widget.bookingId!);
      if (!mounted) return;
      setState(() {
        _booking = booking;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _action(
    Future<Map<String, dynamic>> Function(int id) call,
  ) async {
    final id = widget.bookingId;
    if (id == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final updated = await call(id);
      if (!mounted) return;
      setState(() => _booking = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Da cap nhat booking.')));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openCustomerChat() {
    final booking = _booking;
    if (booking == null) return;

    final customerId = intValue(booking['customerId']);
    if (customerId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong tim thay tai khoan khach hang.')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/chat-detail',
      arguments: {
        'userId': customerId,
        'displayName': textValue(booking['customerName'], 'Khach hang'),
        'email': textValue(booking['customerEmail'], ''),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Chi tiet Booking'),
        leading: BackButton(onPressed: () => Navigator.pop(context, true)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : _body(),
      bottomNavigationBar: _booking == null ? null : _actions(),
    );
  }

  Widget _body() {
    final booking = _booking!;
    final status = textValue(booking['status']);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text(
              'Booking #${intValue(booking['id'])}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            _badge(status),
          ],
        ),
        const SizedBox(height: 20),
        _section('THONG TIN KHACH HANG', [
          _row(
            Icons.person_outline,
            'Ho ten',
            textValue(booking['customerName'], 'Khach hang'),
          ),
          _row(
            Icons.phone_outlined,
            'Dien thoai',
            textValue(booking['customerPhone']),
          ),
          _row(
            Icons.email_outlined,
            'Email',
            textValue(booking['customerEmail']),
          ),
          _row(
            Icons.location_on_outlined,
            'Dia chi',
            textValue(booking['customerAddress']),
          ),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _openCustomerChat,
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Nhan tin voi khach hang'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryBlue,
              side: const BorderSide(color: _primaryBlue),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _section('CHI TIET DAT PHONG', [
          _row(
            Icons.domain_outlined,
            'Khach san',
            textValue(booking['hotelName']),
          ),
          _row(Icons.bed_outlined, 'Phong', textValue(booking['roomNumber'])),
          _row(
            Icons.people_outline,
            'So khach',
            '${intValue(booking['guestCount'])}',
          ),
          _row(
            Icons.login,
            'Nhan phong',
            formatDate(booking['checkInDate'], withTime: true),
          ),
          _row(
            Icons.logout,
            'Tra phong',
            formatDate(booking['checkOutDate'], withTime: true),
          ),
        ]),
        const SizedBox(height: 18),
        _section('THANH TOAN', [
          _row(
            Icons.receipt_long_outlined,
            'Don gia',
            formatMoney(booking['roomUnitPrice']),
          ),
          _row(
            Icons.nightlight_outlined,
            'So dem',
            '${intValue(booking['nightCount'])}',
          ),
          _row(
            Icons.payments_outlined,
            'Da thanh toan',
            formatMoney(booking['paidAmount']),
          ),
          _row(
            Icons.calculate_outlined,
            'Tong cong',
            formatMoney(booking['totalAmount']),
            strong: true,
          ),
        ]),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) const Divider(height: 22),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value, {
    bool strong = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 19, color: Colors.black45),
        const SizedBox(width: 9),
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: strong ? _primaryBlue : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String status) {
    final color = switch (status) {
      'PENDING' => Colors.orange,
      'CONFIRMED' => _primaryBlue,
      'CHECKED_IN' => Colors.green,
      'COMPLETED' || 'CHECKED_OUT' => Colors.grey,
      _ => Colors.red,
    };
    return Chip(
      label: Text(status),
      side: BorderSide.none,
      labelStyle: TextStyle(color: color, fontSize: 11),
      backgroundColor: color.withValues(alpha: 0.12),
    );
  }

  Widget? _actions() {
    final status = textValue(_booking!['status']);
    if (status == 'PENDING') {
      return _buttonBar([
        OutlinedButton(
          onPressed: _submitting ? null : () => _action(_api.rejectBooking),
          child: const Text('Tu choi'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : () => _action(_api.confirmBooking),
          child: const Text('Xac nhan'),
        ),
      ]);
    }
    if (status == 'CONFIRMED') {
      return _buttonBar([
        ElevatedButton(
          onPressed: _submitting ? null : () => _action(_api.checkInBooking),
          child: const Text('Check-in'),
        ),
      ]);
    }
    if (status == 'CHECKED_IN') {
      return _buttonBar([
        ElevatedButton(
          onPressed: _submitting ? null : () => _action(_api.checkOutBooking),
          child: const Text('Check-out'),
        ),
      ]);
    }
    return null;
  }

  Widget _buttonBar(List<Widget> buttons) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              Expanded(child: buttons[i]),
              if (i != buttons.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }
}
