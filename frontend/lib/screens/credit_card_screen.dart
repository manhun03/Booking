import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  int _selectedIndex = 4;

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
                  _buildTitleRow(context, 'Credit Card'),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildPurpleCard(),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1, color: AppColors.textSecondary),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildBlackCard(),
                  ),
                  const SizedBox(height: 68),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildAddButton(context),
                  ),
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
      title: 'Payment Cards',
      subtitle:
          'Quản lý thẻ thanh toán đã lưu, thêm thẻ mới và kiểm tra trạng thái bảo mật tài khoản.',
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final summaryPanel = _buildDesktopSummaryPanel(context);
          final cardsPanel = _buildDesktopCardsPanel(context);

          if (stackPanels) {
            return Column(
              children: [
                summaryPanel,
                const SizedBox(height: 18),
                cardsPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: summaryPanel),
              const SizedBox(width: 24),
              Expanded(child: cardsPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopSummaryPanel(BuildContext context) {
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
              Icons.credit_card,
              color: AppColors.colorPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Thẻ đã lưu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '2 thẻ đang khả dụng cho thanh toán đặt phòng.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _buildSummaryTile(
            icon: Icons.verified_user_outlined,
            label: 'Bảo mật',
            value: 'Đã xác minh',
          ),
          const SizedBox(height: 10),
          _buildSummaryTile(
            icon: Icons.payments_outlined,
            label: 'Mặc định',
            value: 'Bank Name',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/add-card'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm thẻ mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCardsPanel(BuildContext context) {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh sách thẻ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/add-card'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add card'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              _buildCardTile(
                card: _buildPurpleCard(width: 320, height: 198),
                bank: 'Bank Name',
                number: '**** 5432',
                primary: true,
              ),
              _buildCardTile(
                card: _buildBlackCard(width: 320, height: 198),
                bank: 'BANK',
                number: '**** 5463',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile({
    required Widget card,
    required String bank,
    required String number,
    bool primary = false,
  }) {
    return Container(
      width: 344,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.colorBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          card,
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  bank,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (primary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.colorPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
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

  Widget _buildTitleRow(BuildContext context, String title) {
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
        Expanded(
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
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

  Widget _buildPurpleCard({double width = 292, double height = 180}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF201A59),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Bank Name',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 16),
          Icon(Icons.credit_card, color: Color(0xFFD7D5FF), size: 40),
          SizedBox(height: 12),
          Text(
            '1234   5678   9976   5432',
            style: TextStyle(
              color: Color(0xFFD7D5FF),
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '1234          12/49',
            style: TextStyle(color: AppColors.white, fontSize: 9),
          ),
          Spacer(),
          Text(
            'CARDHOLDER',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlackCard({double width = 302, double height = 190}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'BANK',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 34,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 46,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '1234    4567    8921    5463',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '****',
            style: TextStyle(color: AppColors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator.of(context).pushNamed('/add-card'),
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: const BorderSide(color: AppColors.colorPrimary),
        padding: const EdgeInsets.all(10),
      ),
      child: const Icon(Icons.add, color: AppColors.colorPrimary, size: 28),
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
