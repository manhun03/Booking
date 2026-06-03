import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  static const Color _ink = Color(0xFF15233D);
  static const Color _muted = Color(0xFF718096);
  static const Color _surface = Color(0xFFF5F7FB);

  final OwnerApiService _api = OwnerApiService();

  Map<String, dynamic> _stats = const {};
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
      final data = await Future.wait([
        _api.fetchDashboard(),
        _api.fetchBookings(),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = data[0] as Map<String, dynamic>;
        _bookings = (data[1] as List<Map<String, dynamic>>).take(4).toList();
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
    final name =
        AuthService().currentSession?.fullName ??
        AuthService().currentSession?.email ??
        'Owner';
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 20,
        title: const Text(
          'StaySmart Owner',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          _topAction(Icons.notifications_none, '/notifications'),
          _topAction(Icons.chat_bubble_outline, '/chats'),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _topAction(Icons.account_circle_outlined, '/settings'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorBody()
          : LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final maxWidth = constraints.maxWidth >= 1220
                    ? 1160.0
                    : constraints.maxWidth;
                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 28 : 16,
                      vertical: wide ? 28 : 18,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _hero(name, wide),
                              const SizedBox(height: 22),
                              _metricGrid(wide),
                              const SizedBox(height: 22),
                              wide ? _wideBody() : _mobileBody(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _topAction(IconData icon, String route) {
    return IconButton(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon),
      tooltip: route,
    );
  }

  Widget _hero(String name, bool wide) {
    final occupancy = doubleValue(_stats['occupancyRate']);
    final todayBookings = intValue(_stats['todayBookings']);
    final activeRooms = intValue(_stats['activeRooms']);
    final totalRooms = intValue(_stats['totalRooms']);
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'BANG DIEU KHIEN OWNER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Xin chao, $name',
          style: TextStyle(
            color: Colors.white,
            fontSize: wide ? 34 : 27,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Theo doi doanh thu, booking va phong trong mot man hinh.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 14,
          ),
        ),
      ],
    );
    final revenue = _heroRevenueCard(
      avgValue: formatMoney(_stats['avgBookingValue']),
      todayBookings: todayBookings,
      occupancy: occupancy,
      rooms: '$activeRooms/$totalRooms',
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 30 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2948A3), Color(0xFF4F7DF3)],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: intro),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: revenue),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [intro, const SizedBox(height: 18), revenue],
            ),
    );
  }

  Widget _heroRevenueCard({
    required String avgValue,
    required int todayBookings,
    required double occupancy,
    required String rooms,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Gia tri dat phong TB',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            avgValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: occupancy.clamp(0, 100) / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _heroMiniMetric('$todayBookings', 'Nhan phong hom nay'),
              ),
              Expanded(
                child: _heroMiniMetric(
                  '${occupancy.toStringAsFixed(1)}%',
                  'Ty le lap day',
                ),
              ),
              Expanded(child: _heroMiniMetric(rooms, 'Phong san sang')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMiniMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _metricGrid(bool wide) {
    final cards = [
      _DashboardMetric(
        'Khach san',
        '${intValue(_stats['totalHotels'])}',
        'Dang quan ly',
        Icons.domain_outlined,
        const Color(0xFF3F63B5),
      ),
      _DashboardMetric(
        'Phong',
        '${intValue(_stats['totalRooms'])}',
        '${intValue(_stats['activeRooms'])} phong san sang',
        Icons.bed_outlined,
        const Color(0xFF08A66A),
      ),
      _DashboardMetric(
        'Cho duyet',
        '${intValue(_stats['pendingBookings'])}',
        'Booking can xu ly',
        Icons.pending_actions_outlined,
        const Color(0xFFFFA629),
      ),
      _DashboardMetric(
        'Hoan tat',
        '${intValue(_stats['completedBookings'])}',
        '${intValue(_stats['cancelledBookings'])} booking da huy',
        Icons.verified_outlined,
        const Color(0xFF7C3AED),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 640
            ? 2
            : 1;
        const gap = 14.0;
        final width = (constraints.maxWidth - gap * (count - 1)) / count;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((metric) => SizedBox(width: width, child: _metric(metric)))
              .toList(),
        );
      },
    );
  }

  Widget _wideBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _quickActions(),
              const SizedBox(height: 22),
              _ownerHealth(),
            ],
          ),
        ),
        const SizedBox(width: 22),
        Expanded(flex: 5, child: _recentBookings()),
      ],
    );
  }

  Widget _mobileBody() {
    return Column(
      children: [
        _quickActions(),
        const SizedBox(height: 22),
        _recentBookings(),
        const SizedBox(height: 22),
        _ownerHealth(),
      ],
    );
  }

  Widget _quickActions() {
    final actions = [
      _DashboardAction(
        Icons.domain_outlined,
        'Khach san',
        'Quan ly noi luu tru',
        '/hotel-list',
      ),
      _DashboardAction(
        Icons.meeting_room_outlined,
        'Phong',
        'Gia, trang thai, loai phong',
        '/room-list',
      ),
      _DashboardAction(
        Icons.event_available_outlined,
        'Loai phong',
        'Loai phong va lich gia',
        '/room-tools',
      ),
      _DashboardAction(
        Icons.book_online_outlined,
        'Booking',
        'Xac nhan va check-in',
        '/booking',
      ),
      _DashboardAction(
        Icons.bar_chart_outlined,
        'Doanh thu',
        'Bieu do va phong ban chay',
        '/revenue-detail',
      ),
      _DashboardAction(
        Icons.reviews_outlined,
        'Danh gia',
        'Phan hoi khach hang',
        '/reviews',
      ),
      _DashboardAction(
        Icons.settings_outlined,
        'Cai dat',
        'Chinh sach va ngan hang',
        '/settings',
      ),
    ];

    return _sectionCard(
      title: 'Quan ly nhanh',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = constraints.maxWidth >= 720
              ? 3
              : constraints.maxWidth >= 430
              ? 2
              : 1;
          const gap = 12.0;
          final width = (constraints.maxWidth - gap * (count - 1)) / count;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: actions
                .map((action) => SizedBox(width: width, child: _action(action)))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _ownerHealth() {
    final total = intValue(_stats['totalBookings']);
    final pending = intValue(_stats['pendingBookings']);
    final completed = intValue(_stats['completedBookings']);
    final cancelled = intValue(_stats['cancelledBookings']);
    final donePercent = total == 0 ? 0.0 : completed / total;
    return _sectionCard(
      title: 'Tinh hinh van hanh',
      child: Column(
        children: [
          Row(
            children: [
              _healthItem('Tong booking', '$total', _primaryBlue),
              const SizedBox(width: 10),
              _healthItem('Dang cho', '$pending', const Color(0xFFFFA629)),
              const SizedBox(width: 10),
              _healthItem('Da huy', '$cancelled', Colors.redAccent),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: donePercent.clamp(0, 1),
                    backgroundColor: const Color(0xFFE7ECF5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF08A66A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(donePercent * 100).toStringAsFixed(0)}% hoan tat',
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentBookings() {
    return _sectionCard(
      title: 'Booking gan day',
      action: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/booking'),
        child: const Text('Xem tat ca'),
      ),
      child: _bookings.isEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: const Text(
                'Chua co booking nao.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted),
              ),
            )
          : Column(
              children: _bookings
                  .map(
                    (booking) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _bookingCard(booking),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _metric(_DashboardMetric metric) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(metric.icon, color: metric.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.title, style: const TextStyle(color: _muted)),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  metric.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: metric.color, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(_DashboardAction action) {
    return Material(
      color: const Color(0xFFF7F9FD),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(context, action.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(action.icon, color: _primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _healthItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking) {
    final status = textValue(booking['status']);
    final statusColor = _statusColor(status);
    return Material(
      color: const Color(0xFFF7F9FD),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(
          context,
          '/booking-detail',
          arguments: intValue(booking['id']),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      textValue(booking['customerName'], 'Khach hang'),
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _statusPill(status, statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${textValue(booking['hotelName'])} - P.${textValue(booking['roomNumber'])}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: _muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${formatDate(booking['checkInDate'])} - ${formatDate(booking['checkOutDate'])}',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ),
                  Text(
                    formatMoney(booking['totalAmount']),
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final value = status.toUpperCase();
    if (value.contains('CONFIRMED') || value.contains('COMPLETED')) {
      return const Color(0xFF08A66A);
    }
    if (value.contains('PENDING')) return const Color(0xFFFFA629);
    if (value.contains('CANCEL') || value.contains('REJECT')) {
      return Colors.redAccent;
    }
    return _primaryBlue;
  }

  Widget _errorBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: Colors.red, size: 38),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Thu lai')),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardMetric {
  const _DashboardMetric(
    this.title,
    this.value,
    this.detail,
    this.icon,
    this.color,
  );

  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
}

class _DashboardAction {
  const _DashboardAction(this.icon, this.title, this.subtitle, this.route);

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}
