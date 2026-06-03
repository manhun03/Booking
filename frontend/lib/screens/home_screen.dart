import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Map<String, dynamic>> destinations;
  List<Map<String, dynamic>> recommendations = const [];

  final List<Map<String, dynamic>> festivals = const [
    {
      'title': 'Festival Nghỉ Dưỡng Biển 2026',
      'date': '01-08 Tháng 7, 2026',
      'location': 'Nha Trang',
      'description':
          'Tận hưởng kỳ nghỉ hè tại các bãi biển đẹp, đi kèm tour, ẩm thực và dịch vụ cao cấp.',
      'image': '🏝️',
    },
    {
      'title': 'Hội Nghị & Triển Lãm Du Lịch 2026',
      'date': '03-15 Tháng 8, 2026',
      'location': 'Hà Nội',
      'description':
          'Khám phá các điểm đến mới, ưu đãi khách sạn và gói nghỉ dưỡng phù hợp cho gia đình.',
      'image': '🛏️',
    },
  ];

  @override
  void initState() {
    super.initState();
    destinations = [];
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      final hotels = await ApiService().fetchHotels(pageSize: 6);
      List<Map<String, dynamic>> suggested = const [];
      try {
        suggested = await ApiService().fetchSmartRecommendations(topK: 6);
      } catch (_) {
        suggested = const [];
      }
      if (!mounted) return;
      setState(() {
        destinations = hotels;
        recommendations = suggested;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        destinations = [];
        recommendations = const [];
      });
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.of(context).pushNamed('/message');
        break;
      case 2:
        Navigator.of(context).pushNamed('/booking');
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
          _buildMobileHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: _buildMobileContent(context),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: 'StaySmart',
        subtitle:
            'Tìm khách sạn phù hợp, theo dõi ưu đãi và mở nhanh các điểm đến đang được quan tâm.',
        selectedIndex: 0,
        child: _buildDesktopContent(context),
      ),
      mobileBottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const StaySmartBrandButton(
            showLogo: false,
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.colorPrimary,
            ),
          ),
          Row(
            children: [
              _buildHeaderIcon(
                icon: Icons.notifications_none,
                badge: true,
                onTap: () => Navigator.of(context).pushNamed('/notification'),
              ),
              const SizedBox(width: 12),
              _buildHeaderIcon(
                icon: Icons.mail_outline,
                onTap: () => Navigator.of(context).pushNamed('/message'),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/user-profile'),
                child: _buildAvatar(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
          child: _buildSearchPanel(compact: true),
        ),
        _buildMobileDestinations(context),
        _buildMobileRecommendations(context),
        _buildMobileFestivals(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(child: _buildSidebar('📢', 'Quảng cáo')),
              const SizedBox(width: 12),
              Expanded(child: _buildSidebar('🎁', 'Ưu đãi đặc biệt')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: WebPanel(
                padding: const EdgeInsets.all(26),
                child: _buildHeroSection(context),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildSearchPanel(),
                  const SizedBox(height: 18),
                  _buildDesktopStats(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  WebPanel(child: _buildDestinationGrid(context)),
                  if (recommendations.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    WebPanel(child: _buildRecommendationGrid(context)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 5,
              child: WebPanel(
                child: _buildFestivalList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đặt phòng dễ dàng cho chuyến đi tiếp theo',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'So sánh điểm đến, lưu ưu đãi và quản lý đặt phòng trong một giao diện thống nhất trên web và mobile.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Tìm khách sạn',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            color: AppColors.colorPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '🏨',
              style: TextStyle(fontSize: 86),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchPanel({bool compact = false}) {
    return WebPanel(
      padding: compact ? const EdgeInsets.all(0) : const EdgeInsets.all(22),
      child: compact
          ? _buildSearchField()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn muốn đi đâu?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSearchField(),
              ],
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm khách sạn...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.colorBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.tune,
            color: AppColors.colorPrimary,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.colorPrimary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onSubmitted: (_) => Navigator.of(context).pushNamed('/search'),
    );
  }

  Widget _buildDesktopStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.hotel_outlined,
            value: '${destinations.length}',
            label: 'điểm đến',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_offer_outlined,
            value: '${festivals.length}',
            label: 'ưu đãi',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return WebPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: AppColors.colorPrimary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDestinations(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          const Text(
            'Vòng quanh thế giới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các điểm đến du lịch hấp dẫn',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 8,
                      right: i == destinations.length - 1 ? 0 : 8,
                    ),
                    child: SizedBox(
                      width: 160,
                      child: _buildDestinationCard(context, destinations[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileRecommendations(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          const Text(
            'Goi y cho ban',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Khach san duoc de xuat tu lich su va do pho bien',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < recommendations.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 8,
                      right: i == recommendations.length - 1 ? 0 : 8,
                    ),
                    child: SizedBox(
                      width: 160,
                      child: _buildDestinationCard(
                        context,
                        recommendations[i],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điểm đến nổi bật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 32) / 3;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: destinations
                  .map(
                    (destination) => SizedBox(
                      width: itemWidth.clamp(150, 240).toDouble(),
                      child: _buildDestinationCard(context, destination),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendationGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goi y phu hop',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 32) / 3;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: recommendations
                  .map(
                    (hotel) => SizedBox(
                      width: itemWidth.clamp(150, 240).toDouble(),
                      child: _buildDestinationCard(context, hotel),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    Map<String, dynamic> destination,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/hotel-detail',
          arguments: destination,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.colorBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: Text(
                  _textValue(destination, 'image', '🏨'),
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _textValue(destination, 'name', 'Điểm đến'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _textValue(
                      destination,
                      'subtitle',
                      'Khách sạn và ưu đãi nổi bật',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _textValue(destination, 'price', '0 VND'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.colorPrimary,
                    ),
                  ),
                  Text(
                    _textValue(destination, 'nights', '1 đêm'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFestivals() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildFestivalList(),
    );
  }

  Widget _buildFestivalList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ưu đãi và sự kiện',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < festivals.length; i++)
          Padding(
            padding:
                EdgeInsets.only(bottom: i == festivals.length - 1 ? 0 : 14),
            child: _buildFestivalCard(festivals[i]),
          ),
      ],
    );
  }

  Widget _buildFestivalCard(Map<String, dynamic> festival) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 92,
            height: 118,
            decoration: const BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            child: Center(
              child: Text(
                _textValue(festival, 'image', '🏨'),
                style: const TextStyle(fontSize: 38),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _textValue(festival, 'date', 'Ngày linh hoạt'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _textValue(festival, 'title', 'Ưu đãi'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _textValue(festival, 'description', ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
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

  Widget _buildHeaderIcon({
    required IconData icon,
    bool badge = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.colorBg,
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            if (badge)
              Positioned(
                right: 7,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return const CurrentUserAvatar(size: 36);
  }

  Widget _buildSidebar(String icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.divider),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _textValue(
    Map<String, dynamic> data,
    String key,
    String fallback,
  ) {
    final value = data[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}
