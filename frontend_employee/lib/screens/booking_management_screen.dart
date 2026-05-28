import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  List<Map<String, dynamic>> _bookings = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bookings = await _api.fetchBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _openDetail(Map<String, dynamic> booking) async {
    final changed = await Navigator.pushNamed(
      context,
      '/booking-detail',
      arguments: intValue(booking['id']),
    );
    if (changed == true) await _load();
  }

  List<Map<String, dynamic>> _matching(Set<String> statuses) => _bookings
      .where((booking) => statuses.contains(textValue(booking['status'])))
      .toList();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: const Text('Quan ly Booking'),
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: _primaryBlue,
            tabs: [
              Tab(text: 'Cho duyet'),
              Tab(text: 'Sap den'),
              Tab(text: 'Dang o'),
              Tab(text: 'Lich su'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            : TabBarView(
                children: [
                  _bookingList(_matching({'PENDING'})),
                  _bookingList(_matching({'CONFIRMED'})),
                  _bookingList(_matching({'CHECKED_IN'})),
                  _bookingList(
                    _matching({
                      'COMPLETED',
                      'CHECKED_OUT',
                      'CANCELLED',
                      'REJECTED',
                      'NO_SHOW',
                    }),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _bookingList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('Khong co booking trong nhom nay.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _bookingCard(bookings[index]),
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openDetail(booking),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${intValue(booking['id'])}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _statusBadge(textValue(booking['status'])),
                ],
              ),
              const Divider(height: 24),
              Text(
                textValue(
                  booking['customerName'],
                  'Khach hang #${intValue(booking['customerId'])}',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${intValue(booking['guestCount'])} khach | ${textValue(booking['hotelName'])} - P.${textValue(booking['roomNumber'])}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 9),
              Text(
                '${formatDate(booking['checkInDate'])} - ${formatDate(booking['checkOutDate'])} (${intValue(booking['nightCount'])} dem)',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                formatMoney(booking['totalAmount']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = switch (status) {
      'PENDING' => Colors.orange,
      'CONFIRMED' => _primaryBlue,
      'CHECKED_IN' => Colors.green,
      'CHECKED_OUT' || 'COMPLETED' => Colors.grey,
      _ => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
