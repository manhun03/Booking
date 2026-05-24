import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class LegalPoliciesScreen extends StatefulWidget {
  const LegalPoliciesScreen({super.key});

  @override
  State<LegalPoliciesScreen> createState() => _LegalPoliciesScreenState();
}

class _LegalPoliciesScreenState extends State<LegalPoliciesScreen> {
  int _selectedIndex = 4;

  static const String _termsText =
      'Khi sử dụng ứng dụng StaySmart, bạn đồng ý tuân thủ các quy định và điều khoản do chúng tôi đưa ra. StaySmart là nền tảng giúp bạn tìm kiếm, đặt và quản lý phòng khách sạn một cách nhanh chóng, tiện lợi và an toàn.';

  static const String _usageText =
      'Người dùng cần cung cấp thông tin chính xác khi đăng ký tài khoản và đặt phòng. Việc sử dụng ứng dụng vào các mục đích gian lận, vi phạm pháp luật hoặc gây ảnh hưởng đến quyền lợi người khác đều bị nghiêm cấm.';

  static const String _privacyText =
      'Chúng tôi tôn trọng và cam kết bảo vệ quyền riêng tư của bạn. StaySmart chỉ thu thập các thông tin cần thiết như họ tên, email, số điện thoại và lịch sử đặt phòng nhằm phục vụ tốt hơn cho quá trình cung cấp dịch vụ.';

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
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(context),
                  const SizedBox(height: 32),
                  _buildPolicySection('Terms of Service', _termsText),
                  const SizedBox(height: 24),
                  const Text(_usageText, style: _bodyStyle),
                  const SizedBox(height: 34),
                  _buildPolicySection('Privacy Policy', _privacyText),
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
      title: 'Legal and Policies',
      subtitle:
          'Xem các điều khoản dịch vụ, quyền riêng tư và quy định sử dụng StaySmart.',
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final navPanel = _buildPolicyNavPanel();
          final contentPanel = _buildPolicyContentPanel();

          if (stackPanels) {
            return Column(
              children: [
                navPanel,
                const SizedBox(height: 18),
                contentPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: navPanel),
              const SizedBox(width: 24),
              Expanded(child: contentPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPolicyNavPanel() {
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
              Icons.policy_outlined,
              color: AppColors.colorPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tài liệu pháp lý',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Các nội dung dưới đây được trình bày theo từng nhóm để dễ đọc trên website.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _buildPolicyNavTile(Icons.description_outlined, 'Terms of Service'),
          const SizedBox(height: 10),
          _buildPolicyNavTile(Icons.lock_outline, 'Privacy Policy'),
          const SizedBox(height: 10),
          _buildPolicyNavTile(Icons.support_agent_outlined, 'Support'),
        ],
      ),
    );
  }

  Widget _buildPolicyContentPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPolicyContentCard(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            text: _termsText,
          ),
          const SizedBox(height: 16),
          _buildPolicyContentCard(
            icon: Icons.verified_user_outlined,
            title: 'User Responsibilities',
            text: _usageText,
          ),
          const SizedBox(height: 16),
          _buildPolicyContentCard(
            icon: Icons.lock_outline,
            title: 'Privacy Policy',
            text: _privacyText,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyNavTile(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.colorBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildPolicyContentCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.colorBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(text, style: _bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Text(text, style: _bodyStyle),
      ],
    );
  }

  static const TextStyle _bodyStyle = TextStyle(
    fontSize: 13,
    height: 1.45,
    color: AppColors.textPrimary,
  );

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
        const SizedBox(width: 24),
        const Expanded(
          child: Center(
            child: Text(
              'Legal and Policies',
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
}
