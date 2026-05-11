import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class MessageChatScreen extends StatefulWidget {
  const MessageChatScreen({
    Key? key,
    this.contact,
  }) : super(key: key);

  final Map<String, dynamic>? contact;

  @override
  State<MessageChatScreen> createState() => _MessageChatScreenState();
}

class _MessageChatScreenState extends State<MessageChatScreen> {
  int _selectedIndex = 1;

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
          Expanded(child: _buildMobileConversation(context)),
        ],
      ),
      desktopBody: _buildDesktopPage(context),
      mobileBottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDesktopPage(BuildContext context) {
    return WebAppShell(
      title: 'Message',
      subtitle:
          'Trao đổi chi tiết với khách sạn, xem nhanh thông tin phòng và giữ thao tác liên hệ ở cùng một màn hình.',
      selectedIndex: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final contactPanel = _buildDesktopContactPanel(context);
          final chatPanel = _buildDesktopConversationPanel(context);

          if (stackPanels) {
            return Column(
              children: [
                contactPanel,
                const SizedBox(height: 18),
                chatPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: contactPanel),
              const SizedBox(width: 24),
              Expanded(child: chatPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopContactPanel(BuildContext context) {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildContactAvatar(size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildHotelPreviewCard(expanded: true),
          const SizedBox(height: 22),
          _buildContactAction(
            icon: Icons.call_outlined,
            label: 'Gọi khách sạn',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildContactAction(
            icon: Icons.videocam_outlined,
            label: 'Gọi video',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildContactAction(
            icon: Icons.arrow_back,
            label: 'Quay lại hộp thư',
            onTap: () => Navigator.of(context).pushNamed('/message'),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopConversationPanel(BuildContext context) {
    return WebPanel(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 680,
        child: Column(
          children: [
            _buildDesktopChatHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFEFF4FA),
                      Color(0xFFF7F8FA),
                      Color(0xFFE9EDF4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildChatMessages(web: true),
                ),
              ),
            ),
            _buildComposer(web: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopChatHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Quay lại',
          ),
          const SizedBox(width: 8),
          _buildContactAvatar(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _contactName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Đang hoạt động',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
            tooltip: 'Gọi video',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined),
            tooltip: 'Gọi',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileConversation(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildRoomBackground()),
        Column(
          children: [
            _buildChatHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                child: _buildChatMessages(),
              ),
            ),
            _buildComposer(),
          ],
        ),
      ],
    );
  }

  Widget _buildChatMessages({bool web = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: _buildHotelPreviewCard(expanded: web),
        ),
        const SizedBox(height: 12),
        _buildIncomingBubble(
          'Chào bạn, cho tôi hỏi còn phòng trống từ 12-14/11 không?',
          '10:17 AM',
          web: web,
        ),
        _buildOutgoingBubble(
          'Dạ còn ạ. Giá 2.400.000 VND/đêm, đã bao gồm bữa sáng và hồ bơi miễn phí.',
          '10:20 AM',
          web: web,
        ),
        _buildIncomingBubble(
          'Tốt quá, tôi muốn đặt phòng cho 2 người lớn nhé.',
          '10:30 AM',
          web: web,
        ),
        _buildOutgoingBubble(
          'Vâng ạ, phòng đã được đặt. Anh/chị có thể thanh toán tại khách sạn khi nhận phòng.',
          '10:32 AM',
          web: web,
        ),
      ],
    );
  }

  Widget _buildContactAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.colorBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.colorPrimary),
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
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
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

  Widget _buildChatHeader(BuildContext context) {
    return Container(
      color: AppColors.white.withValues(alpha: 0.78),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
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
                    'Message',
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
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildContactAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.videocam_outlined, size: 22),
              const SizedBox(width: 16),
              const Icon(Icons.call_outlined, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE9EDF4),
            Color(0xFFD6C1A8),
            Color(0xFFF0F3F9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 70,
            child: Container(
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFC19C74).withValues(alpha: 0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            bottom: 82,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 128,
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFF9FAEC3).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelPreviewCard({bool expanded = false}) {
    return Container(
      width: expanded ? double.infinity : 258,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: expanded ? 96 : 86,
              height: expanded ? 106 : 94,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9FB5C8),
                    Color(0xFFECE6DD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.king_bed_outlined,
                size: 42,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'The Aston Vill Hotel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.orange, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      '4.7',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _buildHotelMeta(
                  Icons.location_on_outlined,
                  '128 Võ Văn Kiệt, Sơn Trà, Đà Nẵng',
                ),
                const SizedBox(height: 4),
                const Text(
                  '2.400.000 VND / đêm',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                _buildHotelMeta(
                  Icons.calendar_today_outlined,
                  'Ngày 12 - 14, Thg 11, 2024',
                ),
                const SizedBox(height: 4),
                _buildHotelMeta(
                  Icons.person_outline,
                  'Khách 2 Người (1 phòng)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelMeta(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingBubble(
    String text,
    String time, {
    bool web = false,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: web ? 420 : 222),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2B2A).withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: web ? 13 : 11,
                  height: 1.35,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingBubble(
    String text,
    String time, {
    bool web = false,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: web ? 420 : 218),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1588F2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: web ? 13 : 11,
                  height: 1.35,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer({bool web = false}) {
    return Container(
      color: web ? AppColors.white : Colors.transparent,
      padding: EdgeInsets.fromLTRB(22, 6, 22, web ? 16 : 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: web ? AppColors.colorBg : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: web ? Border.all(color: AppColors.divider) : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(
              Icons.edit_outlined,
              size: 17,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Write a text',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 5),
              decoration: const BoxDecoration(
                color: Color(0xFF1588F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                size: 18,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAvatar({double size = 46}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF0F2F5),
      ),
      child: Icon(
        Icons.person_outline,
        color: AppColors.iconMuted,
        size: size * 0.48,
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

  String get _contactName {
    final name = widget.contact?['name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString().trim();
    }
    return 'Nguyễn Đoàn Quân';
  }
}
