import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedIndex = 0;

  static const List<Map<String, dynamic>> _deals = [
    {
      'title': 'Giảm giá tại Việt Nam trong thời gian giới hạn',
      'subtitle':
          'Giảm tới 40% khi đặt phòng tại Việt Nam, áp dụng cho các khách sạn tham gia chương trình.',
      'colors': [Color(0xFFE9C088), Color(0xFFB95D34)],
      'icon': Icons.apartment,
      'time': '10 phút',
    },
    {
      'title': 'Tiết kiệm đến 20% cho kỳ nghỉ cuối tuần',
      'subtitle': 'Tận hưởng kỳ nghỉ đáng cấp với mức giá ưu đãi đặc biệt.',
      'colors': [Color(0xFFFFB3C7), Color(0xFFE74C6A)],
      'icon': Icons.local_offer,
      'time': '1 giờ',
    },
    {
      'title': 'Ưu đãi nội địa - giảm đến 25%',
      'subtitle':
          'Tận hưởng giá đặc biệt tại các khách sạn và khu nghỉ dưỡng địa phương.',
      'colors': [Color(0xFF1FAA59), Color(0xFF74C67A)],
      'icon': Icons.location_on,
      'time': '3 giờ',
    },
  ];

  static const List<Map<String, String>> _messages = [
    {
      'name': 'Nguyễn Đoàn Quân',
      'message': 'Tôi muốn hỏi bạn về thông tin đặt phòng cuối tuần này.',
      'time': '2 giờ',
    },
    {
      'name': 'Satoshi',
      'message': 'Phòng 103 gặp sự cố, tôi cần hỗ trợ kiểm tra.',
      'time': '1 giờ',
    },
    {
      'name': 'Nguyễn Hoàng Hà',
      'message': 'Tôi muốn đặt trước phòng suite cho 2 người.',
      'time': '1 giờ',
    },
    {
      'name': 'Nguyễn Phúc Tài',
      'message': 'Tôi muốn hỏi cách thanh toán khi nhận phòng.',
      'time': '1 giờ',
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
              child: _buildMobileContent(context),
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
      title: 'Notification',
      subtitle:
          'Theo dõi ưu đãi mới, tin nhắn khách sạn và các cập nhật quan trọng từ EasyStay.',
      selectedIndex: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final summaryPanel = _buildDesktopSummaryPanel();
          final contentPanel = _buildDesktopContentPanel();

          if (stackPanels) {
            return Column(
              children: [
                summaryPanel,
                const SizedBox(height: 18),
                contentPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: summaryPanel),
              const SizedBox(width: 24),
              Expanded(child: contentPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context),
        const SizedBox(height: 18),
        const Text(
          'Ưu đãi',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        for (final deal in _deals) ...[
          _buildDealCard(deal),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 4),
        const Text(
          'Tin Nhắn',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildMessagesCard(),
      ],
    );
  }

  Widget _buildDesktopSummaryPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.colorPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Trung tâm thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tổng hợp ưu đãi và tin nhắn mới nhất để bạn không bỏ lỡ thông tin đặt phòng.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _buildSummaryTile(
            icon: Icons.local_offer_outlined,
            label: 'Ưu đãi',
            value: '${_deals.length}',
            color: AppColors.colorPrimary,
          ),
          const SizedBox(height: 10),
          _buildSummaryTile(
            icon: Icons.mail_outline,
            label: 'Tin nhắn',
            value: '${_messages.length}',
            color: const Color(0xFF22C55E),
          ),
          const SizedBox(height: 10),
          _buildSummaryTile(
            icon: Icons.mark_email_unread_outlined,
            label: 'Chưa đọc',
            value: '5',
            color: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContentPanel() {
    return Column(
      children: [
        WebPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ưu đãi mới',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Đánh dấu đã đọc'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 760 ? 2 : 1;
                  final spacing = columns == 2 ? 14.0 : 0.0;
                  final itemWidth =
                      (constraints.maxWidth - spacing) / columns.toDouble();

                  return Wrap(
                    spacing: spacing,
                    runSpacing: 14,
                    children: [
                      for (final deal in _deals)
                        SizedBox(
                          width: itemWidth,
                          child: _buildDealCard(deal, wide: true),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        WebPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tin nhắn gần đây',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildMessagesCard(wide: true),
            ],
          ),
        ),
      ],
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
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
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
            'EasyStay',
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
              'Notification',
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
    );
  }

  Widget _buildDealCard(
    Map<String, dynamic> deal, {
    bool wide = false,
  }) {
    final colors = _colorsValue(deal);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(wide ? 14 : 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Container(
              width: wide ? 84 : 72,
              height: wide ? 82 : 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                _iconValue(deal),
                size: wide ? 38 : 34,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _textValue(deal, 'title'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: wide ? 13 : 11,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (wide)
                      Text(
                        _textValue(deal, 'time'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _textValue(deal, 'subtitle'),
                  maxLines: wide ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: wide ? 11 : 10,
                    height: 1.25,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!wide) ...[
                  const SizedBox(height: 4),
                  Text(
                    _textValue(deal, 'time'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesCard({bool wide = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: wide ? Border.all(color: AppColors.divider) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (var index = 0; index < _messages.length; index++) ...[
            _buildMessageItem(_messages[index], wide: wide),
            if (index < _messages.length - 1)
              const Divider(
                height: 1,
                indent: 70,
                endIndent: 12,
                color: AppColors.divider,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    Map<String, String> message, {
    bool wide = false,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/message-chat'),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, wide ? 12 : 9, 12, wide ? 12 : 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: wide ? 50 : 46,
              height: wide ? 50 : 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F2F5),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.iconMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message['name'] ?? '',
                          style: TextStyle(
                            fontSize: wide ? 14 : 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        message['time'] ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message['message'] ?? '',
                    maxLines: wide ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6D4C41),
            Color(0xFFD7A86E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.58,
        color: AppColors.white,
      ),
    );
  }

  String _textValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString();
  }

  IconData _iconValue(Map<String, dynamic> data) {
    final value = data['icon'];
    if (value is IconData) return value;
    return Icons.notifications_none;
  }

  List<Color> _colorsValue(Map<String, dynamic> data) {
    final value = data['colors'];
    if (value is List<Color> && value.length >= 2) return value;
    return const [Color(0xFFE9C088), Color(0xFFB95D34)];
  }
}
