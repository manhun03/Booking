import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  int _selectedIndex = 4;

  static const List<Map<String, dynamic>> _vouchers = [
    {
      'title': 'Giảm giá tại Việt Nam trong thời gian giới hạn',
      'description':
          'Giảm tới 40% khi đặt phòng tại Việt Nam, áp dụng cho các khách sạn tham gia chương trình.',
      'colors': [Color(0xFFE9C088), Color(0xFFB95D34)],
      'icon': Icons.apartment,
      'code': 'VNSTAY40',
    },
    {
      'title': 'Tiết kiệm đến 20% cho kỳ nghỉ cuối tuần',
      'description':
          'Tận hưởng kỳ nghỉ ngắn ngày với mức giá ưu đãi đặc biệt vào thứ Sáu, thứ Bảy và Chủ nhật.',
      'colors': [Color(0xFFFFB3C7), Color(0xFFE74C6A)],
      'icon': Icons.local_offer,
      'code': 'WEEKEND20',
    },
    {
      'title': 'Ưu đãi nội địa - giảm đến 25%',
      'description':
          'Giá đặc biệt tại các khách sạn và khu nghỉ dưỡng địa phương cho chuyến đi trong nước.',
      'colors': [Color(0xFF1FAA59), Color(0xFF74C67A)],
      'icon': Icons.location_on,
      'code': 'LOCAL25',
    },
    {
      'title': 'Đặt phòng khách sạn siêu tiết kiệm',
      'description':
          'Voucher độc quyền cho chỗ nghỉ trong tháng này, áp dụng khi thanh toán qua StaySmart.',
      'colors': [Color(0xFF0B5574), Color(0xFF8AC6D8)],
      'icon': Icons.hotel,
      'code': 'SMARTSTAY',
    },
    {
      'title': 'Tiết kiệm đến 50% cho chuyến du lịch xanh',
      'description':
          'Tận hưởng kỳ nghỉ gần thiên nhiên, nhận thêm ưu đãi từ các điểm đến xanh.',
      'colors': [Color(0xFF80C565), Color(0xFF2D8CCB)],
      'icon': Icons.beach_access,
      'code': 'GREEN50',
    },
  ];

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
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
              child: Column(
                children: [
                  _buildTitleRow(context),
                  const SizedBox(height: 20),
                  _buildHero(),
                  const SizedBox(height: 22),
                  _buildVoucherActions(),
                  const SizedBox(height: 14),
                  for (final voucher in _vouchers) ...[
                    _buildVoucherCard(voucher),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
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
      title: 'Promotions',
      subtitle:
          'Theo dõi voucher đang có, thêm mã ưu đãi và chọn khuyến mãi phù hợp cho lần đặt phòng tiếp theo.',
      selectedIndex: 4,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: WebPanel(
                  padding: const EdgeInsets.all(0),
                  child: _buildDesktopHeroContent(),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: WebPanel(child: _buildDesktopActionPanel(context)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          WebPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voucher hiện có',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 860 ? 2 : 1;
                    final spacing = columns == 2 ? 14.0 : 0.0;
                    final itemWidth =
                        (constraints.maxWidth - spacing) / columns.toDouble();

                    return Wrap(
                      spacing: spacing,
                      runSpacing: 14,
                      children: [
                        for (final voucher in _vouchers)
                          SizedBox(
                            width: itemWidth,
                            child: _buildVoucherCard(voucher, wide: true),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeroContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 236),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF67B8C7),
              Color(0xFFB9D7C7),
              Color(0xFFEBC28B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(28),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ưu đãi mùa du lịch',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nhận voucher khách sạn, resort và chuyến đi cuối tuần với mức giảm tốt hơn khi đặt sớm.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.white,
                size: 58,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActionPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tác vụ nhanh',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          Icons.confirmation_number_outlined,
          'Thêm mã voucher',
          'Nhập mã ưu đãi bạn nhận được',
          onTap: () => Navigator.of(context).pushNamed('/add-promotion'),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          Icons.image_outlined,
          'Tìm thêm voucher',
          'Khám phá các ưu đãi mới',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          Icons.history,
          'Lịch sử áp dụng',
          'Xem các voucher đã dùng',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF1D6C96),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_hotel,
              color: AppColors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'StaySmart',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
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

  Widget _buildTitleRow(BuildContext context) {
    return Row(
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
              'Promotion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
      ],
    );
  }

  Widget _buildHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 76,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF67B8C7),
              Color(0xFFB9D7C7),
              Color(0xFFEBC28B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 26,
                color: AppColors.white.withValues(alpha: 0.35),
              ),
            ),
            const Positioned(
              right: 30,
              top: 18,
              child: Icon(Icons.flight_takeoff, size: 20, color: Colors.red),
            ),
            const Positioned(
              left: 28,
              bottom: 16,
              child: Icon(
                Icons.beach_access,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            Icons.confirmation_number_outlined,
            'Extra voucher code',
            onTap: () => Navigator.of(context).pushNamed('/add-promotion'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(Icons.image_outlined, 'Find more voucher'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.colorBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.colorPrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard(
    Map<String, dynamic> voucher, {
    bool wide = false,
  }) {
    final colors = _colorsValue(voucher);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.delete_outline,
                size: 14,
                color: Colors.red,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    width: wide ? 90 : 70,
                    height: wide ? 90 : 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      _iconValue(voucher),
                      color: AppColors.white,
                      size: wide ? 38 : 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: wide ? 70 : 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _textValue(voucher, 'title'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: wide ? 13 : 11,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _textValue(voucher, 'description'),
                          maxLines: wide ? 3 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: wide ? 11 : 9,
                            height: 1.25,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (wide) ...[
                          const SizedBox(height: 8),
                          Text(
                            _textValue(voucher, 'code'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.colorPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: wide ? 70 : 58,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Nhận',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
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
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
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
            right: -2,
            top: -4,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '1',
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

  String _textValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString();
  }

  IconData _iconValue(Map<String, dynamic> data) {
    final value = data['icon'];
    if (value is IconData) return value;
    return Icons.local_offer_outlined;
  }

  List<Color> _colorsValue(Map<String, dynamic> data) {
    final value = data['colors'];
    if (value is List<Color> && value.length >= 2) return value;
    return const [Color(0xFFE9C088), Color(0xFFB95D34)];
  }
}
