import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedIndex = 2;
  bool _showHistory = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchText = '';

  late List<Map<String, dynamic>> _currentBookings;
  late List<Map<String, dynamic>> _historyBookings;

  @override
  void initState() {
    super.initState();
    _currentBookings = [];
    _historyBookings = [];
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (!ApiService().isAuthenticated) {
      setState(() {
        _errorMessage = 'Vui long dang nhap de xem booking cua ban.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await ApiService().fetchMyBookings();
      if (!mounted) return;
      setState(() {
        _currentBookings =
            bookings.where((booking) => booking['isHistory'] != true).toList();
        _historyBookings =
            bookings.where((booking) => booking['isHistory'] == true).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _visibleBookings {
    final source = _showHistory ? _historyBookings : _currentBookings;
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((booking) {
      final name = (booking['name'] as String).toLowerCase();
      final location = (booking['location'] as String).toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushNamed('/message');
        break;
      case 2:
        break;
      case 3:
        Navigator.of(context).pushNamed('/search');
        break;
      case 4:
        Navigator.of(context).pushNamed('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTitleArea(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 22),
                  sliver: _buildBookingList(),
                ),
              ],
            ),
          ),
        ],
      ),
      desktopBody: _buildDesktopPage(context),
      mobileBottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDesktopPage(BuildContext context) {
    return WebAppShell(
      title: 'My Booking',
      subtitle:
          'Theo dõi các phòng đang đặt, kiểm tra lịch sử lưu trú và mở chi tiết đặt phòng nhanh hơn trên màn hình lớn.',
      selectedIndex: 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: _buildDesktopControlPanel(),
          ),
          const SizedBox(width: 24),
          Expanded(child: _buildDesktopBookingList()),
        ],
      ),
    );
  }

  Widget _buildDesktopControlPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bộ lọc đặt phòng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildSegmentedTabs(),
          const SizedBox(height: 22),
          _buildSummaryTile(
            icon: Icons.event_available_outlined,
            label: 'Đang đặt',
            value: '${_currentBookings.length}',
            color: AppColors.colorPrimary,
          ),
          const SizedBox(height: 12),
          _buildSummaryTile(
            icon: Icons.history,
            label: 'Lịch sử',
            value: '${_historyBookings.length}',
            color: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBookingList() {
    final bookings = _visibleBookings;

    if (_isLoading) {
      return const WebPanel(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 34),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return WebPanel(child: _buildStateMessage(_errorMessage!));
    }

    if (bookings.isEmpty) {
      return const WebPanel(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 34),
            child: Text(
              'Không tìm thấy booking',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < bookings.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == bookings.length - 1 ? 0 : 16,
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/booking-detail',
                  arguments: bookings[index],
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: _buildDesktopBookingCard(bookings[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildStateMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDesktopBookingCard(Map<String, dynamic> booking) {
    final palette = booking['palette'] as List<Color>;
    final statusColor = booking['statusColor'] as Color;

    return WebPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HotelThumbnail(
            palette: palette,
            variant: booking['variant'] as int,
            width: 150,
            height: 132,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        booking['name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        booking['status'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF6B800), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      booking['rating'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _buildInfoLine(
                        icon: Icons.location_on_outlined,
                        text: booking['location'] as String,
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  booking['price'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoLine(
                        icon: Icons.calendar_today_outlined,
                        text: booking['date'] as String,
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoLine(
                        icon: Icons.person_outline,
                        text: booking['guests'] as String,
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const StaySmartBrandButton(),
          const Spacer(),
          _buildBellButton(context),
          const SizedBox(width: 18),
          const Icon(
            Icons.settings_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/user-profile'),
            child: _buildAvatar(size: 34),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleArea(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
      child: Column(
        children: [
          Row(
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
              const SizedBox(width: 40),
              const Expanded(
                child: Center(
                  child: Text(
                    'My Booking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.filter_list,
                    size: 18,
                    color: AppColors.colorPrimary,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSearchField(),
          const SizedBox(height: 18),
          _buildSegmentedTabs(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 42,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search...',
          hintStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 17,
            color: AppColors.iconMuted,
          ),
          suffixIcon: const Icon(
            Icons.tune,
            size: 16,
            color: AppColors.textPrimary,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: AppColors.colorPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              label: 'Booking',
              selected: !_showHistory,
              onTap: () {
                setState(() {
                  _showHistory = false;
                });
              },
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: 'History',
              selected: _showHistory,
              onTap: () {
                setState(() {
                  _showHistory = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: selected
              ? Border.all(color: const Color(0xFFE5E7EB), width: 1)
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    final bookings = _visibleBookings;

    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: _buildStateMessage(_errorMessage!),
        ),
      );
    }

    if (bookings.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 24),
          child: Center(
            child: Text(
              'Không tìm thấy booking',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding:
                EdgeInsets.only(bottom: index == bookings.length - 1 ? 0 : 22),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/booking-detail',
                  arguments: bookings[index],
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: _buildBookingCard(bookings[index]),
            ),
          );
        },
        childCount: bookings.length,
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final palette = booking['palette'] as List<Color>;
    final statusAlignment = booking['statusAlignment'] as String;
    final statusColor = booking['statusColor'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HotelThumbnail(
            palette: palette,
            variant: booking['variant'] as int,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking['name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.star, color: Color(0xFFF6B800), size: 13),
                    const SizedBox(width: 3),
                    Text(
                      booking['rating'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _buildInfoLine(
                  icon: Icons.location_on_outlined,
                  text: booking['location'] as String,
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
                const SizedBox(height: 4),
                Text(
                  booking['price'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInfoLine(
                  icon: Icons.calendar_today_outlined,
                  text: booking['date'] as String,
                  color: AppColors.textPrimary,
                  fontSize: 10,
                ),
                const SizedBox(height: 5),
                _buildStatusArea(
                  guests: booking['guests'] as String,
                  status: booking['status'] as String,
                  statusColor: statusColor,
                  alignEnd: statusAlignment == 'end',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine({
    required IconData icon,
    required String text,
    required Color color,
    required double fontSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusArea({
    required String guests,
    required String status,
    required Color statusColor,
    required bool alignEnd,
  }) {
    final statusText = Text(
      status,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10,
        color: statusColor,
        fontWeight: FontWeight.w600,
      ),
    );

    if (alignEnd) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildInfoLine(
              icon: Icons.person_outline,
              text: guests,
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 8),
          statusText,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoLine(
          icon: Icons.person_outline,
          text: guests,
          color: AppColors.textPrimary,
          fontSize: 10,
        ),
        const SizedBox(height: 3),
        statusText,
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.colorPrimary,
        unselectedItemColor: AppColors.textPrimary,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  Widget _buildBellButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/notification'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 22,
            color: AppColors.textPrimary,
          ),
          Positioned(
            right: -3,
            top: -5,
            child: Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '9',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAvatar({required double size}) {
    return CurrentUserAvatar(size: size);
  }
}

class _HotelThumbnail extends StatelessWidget {
  const _HotelThumbnail({
    required this.palette,
    required this.variant,
    this.width = 86,
    this.height = 92,
  });

  final List<Color> palette;
  final int variant;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _HotelThumbnailPainter(
            palette: palette,
            variant: variant,
          ),
        ),
      ),
    );
  }
}

class _HotelThumbnailPainter extends CustomPainter {
  _HotelThumbnailPainter({
    required this.palette,
    required this.variant,
  });

  final List<Color> palette;
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final wallPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          palette[1],
          Color.lerp(palette[1], AppColors.white, 0.35)!,
          palette[0],
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, wallPaint);

    final lightPaint = Paint()..color = Colors.white.withValues(alpha: 0.58);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.08, 0, size.width * 0.26, size.height),
      lightPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.65, 0, size.width * 0.2, size.height),
      lightPaint..color = Colors.white.withValues(alpha: 0.26),
    );

    final floorPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          palette[2].withValues(alpha: 0.72),
          Color.lerp(palette[2], Colors.black, 0.18)!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
      );
    final floorPath = Path()
      ..moveTo(0, size.height * 0.68)
      ..lineTo(size.width, size.height * 0.57)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(floorPath, floorPaint);

    _paintWindow(canvas, size);
    if (variant.isEven) {
      _paintBed(canvas, size);
      _paintLamp(canvas, size);
    } else {
      _paintChairAndDoor(canvas, size);
    }
  }

  void _paintWindow(Canvas canvas, Size size) {
    final framePaint = Paint()..color = palette[2].withValues(alpha: 0.42);
    final glassPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB8D5EA), Color(0xFFF8FBFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromLTWH(size.width * 0.5, size.height * 0.1, size.width * 0.36,
            size.height * 0.36),
      );
    final window = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.52,
        size.height * 0.1,
        size.width * 0.34,
        size.height * 0.36,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(window, glassPaint);
    canvas.drawLine(
      Offset(size.width * 0.69, size.height * 0.1),
      Offset(size.width * 0.69, size.height * 0.46),
      framePaint..strokeWidth = 1.4,
    );
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.28),
      Offset(size.width * 0.86, size.height * 0.28),
      framePaint,
    );
  }

  void _paintBed(Canvas canvas, Size size) {
    final headboard = Paint()..color = palette[2].withValues(alpha: 0.74);
    final sheet = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final blanket = Paint()..color = palette[0].withValues(alpha: 0.85);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.43,
          size.width * 0.58,
          size.height * 0.16,
        ),
        const Radius.circular(4),
      ),
      headboard,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.54,
          size.width * 0.72,
          size.height * 0.29,
        ),
        const Radius.circular(6),
      ),
      sheet,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.68,
          size.width * 0.72,
          size.height * 0.17,
        ),
        const Radius.circular(5),
      ),
      blanket,
    );
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.6),
      math.min(size.width, size.height) * 0.08,
      Paint()..color = const Color(0xFFFFF4E6),
    );
  }

  void _paintLamp(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFD66E);
    final stand = Paint()
      ..color = palette[2].withValues(alpha: 0.72)
      ..strokeWidth = 2;
    final shade = Path()
      ..moveTo(size.width * 0.18, size.height * 0.33)
      ..lineTo(size.width * 0.32, size.height * 0.33)
      ..lineTo(size.width * 0.29, size.height * 0.45)
      ..lineTo(size.width * 0.21, size.height * 0.45)
      ..close();
    canvas.drawPath(shade, paint);
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.45),
      Offset(size.width * 0.25, size.height * 0.56),
      stand,
    );
  }

  void _paintChairAndDoor(Canvas canvas, Size size) {
    final doorPaint = Paint()..color = palette[2].withValues(alpha: 0.72);
    final bedPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    final chairPaint = Paint()..color = palette[0].withValues(alpha: 0.86);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.12,
          size.width * 0.26,
          size.height * 0.52,
        ),
        const Radius.circular(3),
      ),
      doorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.46,
          size.height * 0.44,
          size.width * 0.38,
          size.height * 0.25,
        ),
        const Radius.circular(5),
      ),
      bedPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.66,
        size.width * 0.28,
        size.height * 0.18,
      ),
      chairPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.78),
      Offset(size.width * 0.15, size.height * 0.94),
      Paint()
        ..color = palette[2]
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(size.width * 0.31, size.height * 0.78),
      Offset(size.width * 0.39, size.height * 0.94),
      Paint()
        ..color = palette[2]
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _HotelThumbnailPainter oldDelegate) {
    return oldDelegate.palette != palette || oldDelegate.variant != variant;
  }
}
