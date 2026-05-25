import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int _selectedIndex = 4;
  String _selectedLanguage = 'Vietnamese';

  static const List<String> _suggestedLanguages = [
    'Vietnamese',
    'English',
    'English (UK)',
  ];

  static const List<String> _otherLanguages = [
    'Chinese',
    'Croatian',
    'Czech',
    'Danish',
    'Filipino',
    'Finnish',
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
                  const SizedBox(height: 18),
                  _buildLanguageCard(),
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
      title: 'Language',
      subtitle:
          'Chọn ngôn ngữ hiển thị phù hợp cho ứng dụng và website StaySmart.',
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 900;
          final summaryPanel = _buildLanguageSummaryPanel();
          final listPanel = WebPanel(child: _buildLanguageCard(web: true));

          if (stackPanels) {
            return Column(
              children: [
                summaryPanel,
                const SizedBox(height: 18),
                listPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: summaryPanel),
              const SizedBox(width: 24),
              Expanded(child: listPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageSummaryPanel() {
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
              Icons.language_outlined,
              color: AppColors.colorPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Ngôn ngữ hiện tại',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedLanguage,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Thay đổi này sẽ áp dụng cho các màn hình trong ứng dụng sau khi bạn chọn ngôn ngữ mới.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
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
              'Language',
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

  Widget _buildLanguageCard({bool web = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(web ? 8 : 0),
        border: Border.all(
          color: web ? AppColors.divider : AppColors.colorPrimary,
          width: web ? 1 : 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Suggested Languages', web: web),
          for (final language in _suggestedLanguages)
            _buildLanguageRow(language, selectable: true, web: web),
          Container(height: web ? 12 : 20, color: AppColors.colorBg),
          _buildSectionLabel('Other Languages', web: web),
          for (final language in _otherLanguages)
            _buildLanguageRow(language, selectable: true, web: web),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool web = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, web ? 18 : 16, 18, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: web ? 12 : 9,
          fontWeight: web ? FontWeight.w700 : FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLanguageRow(
    String language, {
    bool selectable = false,
    bool web = false,
  }) {
    final selected = _selectedLanguage == language;

    return InkWell(
      onTap: selectable
          ? () {
              setState(() {
                _selectedLanguage = language;
              });
            }
          : null,
      child: Container(
        height: web ? 56 : 50,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontSize: web ? 14 : 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check,
                size: 18,
                color: AppColors.colorPrimary,
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
    return CurrentUserAvatar(size: size);
  }
}
