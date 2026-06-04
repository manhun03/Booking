import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class RevenueDetailScreen extends StatefulWidget {
  const RevenueDetailScreen({super.key});

  @override
  State<RevenueDetailScreen> createState() => _RevenueDetailScreenState();
}

class _RevenueDetailScreenState extends State<RevenueDetailScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  Map<String, dynamic> _comparison = const {};
  List<Map<String, dynamic>> _chart = const [];
  List<Map<String, dynamic>> _topRooms = const [];
  List<Map<String, dynamic>> _peakHours = const [];
  List<Map<String, dynamic>> _upcomingBookings = const [];
  List<Map<String, dynamic>> _revenueSummary = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 29));
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await Future.wait([
        _api.fetchRevenueComparison(startDate: start, endDate: end),
        _api.fetchRevenueChart(startDate: start, endDate: end),
        _api.fetchTopRooms(),
        _api.fetchPeakHours(),
        _api.fetchUpcomingBookings(hoursAhead: 24),
        _api.fetchRevenueSummary(startDate: start, endDate: end),
      ]);
      if (!mounted) return;
      setState(() {
        _comparison = data[0] as Map<String, dynamic>;
        _chart = data[1] as List<Map<String, dynamic>>;
        _topRooms = data[2] as List<Map<String, dynamic>>;
        _peakHours = data[3] as List<Map<String, dynamic>>;
        _upcomingBookings = data[4] as List<Map<String, dynamic>>;
        _revenueSummary = data[5] as List<Map<String, dynamic>>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Bao cao doanh thu'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _overview(),
                  const SizedBox(height: 24),
                  const Text(
                    'DOANH THU 30 NGAY GAN NHAT',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _chartCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'TOM TAT DOANH THU',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _summaryCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'GIO DAT PHONG CAO DIEM',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _peakHoursCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'BOOKING SAP TOI TRONG 24 GIO',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _upcomingCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'TOP PHONG THEO DOANH THU',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_topRooms.isEmpty)
                    const Card(
                      elevation: 0,
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text('Chua co du lieu doanh thu.'),
                      ),
                    )
                  else
                    ..._topRooms.indexed.map(
                      (entry) => _roomCard(entry.$2, entry.$1 + 1),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _overview() {
    final percent = doubleValue(_comparison['changePercentage']);
    final increased = percent >= 0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryBlue, Color(0xFF2A4B9B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu 30 ngay gan nhat',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 9),
          Text(
            formatMoney(_comparison['currentRevenue']),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${increased ? '+' : ''}${percent.toStringAsFixed(2)}% so voi ky truoc'
            ' | ${intValue(_comparison['currentBookings'])} booking',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _chartCard() {
    final recent = _chart.length > 10
        ? _chart.sublist(_chart.length - 10)
        : _chart;
    final highest = recent.fold<double>(
      0,
      (max, item) => doubleValue(item['revenue']) > max
          ? doubleValue(item['revenue'])
          : max,
    );
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          height: 180,
          child: recent.isEmpty
              ? const Center(child: Text('Chua co du lieu.'))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: recent.map((entry) {
                    final revenue = doubleValue(entry['revenue']);
                    final ratio = highest == 0 ? 0.02 : revenue / highest;
                    final date = formatDate(
                      entry['date'],
                    ).split('/').take(2).join('/');
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: formatMoney(entry['revenue']),
                          child: Container(
                            height: 120 * ratio.clamp(0.02, 1.0),
                            width: 19,
                            decoration: BoxDecoration(
                              color: _primaryBlue.withValues(
                                alpha: revenue == highest ? 1 : 0.35,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(date, style: const TextStyle(fontSize: 10)),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  Widget _summaryCard() {
    if (_revenueSummary.isEmpty) {
      return const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('Chua co du lieu tong hop doanh thu.'),
        ),
      );
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: _revenueSummary.take(5).map((item) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                textValue(item['period'], 'Khoang thoi gian'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${formatDate(item['startDate'])} - ${formatDate(item['endDate'])}'
                ' | ${intValue(item['totalBookings'])} booking',
              ),
              trailing: Text(
                formatMoney(item['totalRevenue']),
                style: const TextStyle(
                  color: _primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _peakHoursCard() {
    final highest = _peakHours.fold<int>(
      0,
      (max, item) => intValue(item['bookingCount']) > max
          ? intValue(item['bookingCount'])
          : max,
    );
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: _peakHours.isEmpty
            ? const Text('Chua co du lieu gio cao diem.')
            : Column(
                children: _peakHours.take(8).map((item) {
                  final count = intValue(item['bookingCount']);
                  final ratio = highest == 0 ? 0.02 : count / highest;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 54,
                          child: Text(textValue(item['hour'], '--:--')),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 9,
                              value: ratio.clamp(0.02, 1.0),
                              backgroundColor: const Color(0xFFE7ECF5),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('$count booking'),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _upcomingCard() {
    if (_upcomingBookings.isEmpty) {
      return const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('Khong co booking sap toi trong 24 gio.'),
        ),
      );
    }

    return Card(
      elevation: 0,
      child: Column(
        children: _upcomingBookings.map((booking) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.event_available)),
            title: Text(
              textValue(booking['customerName'], 'Khach hang'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${textValue(booking['hotelName'])} - ${textValue(booking['roomName'])}'
              '\nNhan phong: ${formatDate(booking['checkInDate'], withTime: true)}',
            ),
            trailing: Text(formatMoney(booking['totalAmount'])),
          );
        }).toList(),
      ),
    );
  }

  Widget _roomCard(Map<String, dynamic> room, int rank) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Text('#$rank')),
        title: Text(
          'Phong ${textValue(room['roomName'])}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${intValue(room['bookingCount'])} booking'),
        trailing: Text(
          formatMoney(room['revenue']),
          style: const TextStyle(
            color: _primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
