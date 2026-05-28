import 'package:flutter/material.dart';

import '../services/language_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final LanguageService _language = LanguageService();
  int _selectedIndex = 4;

  List<Map<String, dynamic>> get _menuItems => [
        {
          'icon': Icons.person_outline,
          'title': _language.t('more.accountSettings'),
          'subtitle': _language.t('more.accountSettingsSubtitle'),
          'route': '/user-profile',
          'color': AppColors.colorPrimary,
        },
        {
          'icon': Icons.favorite_border,
          'title': _language.t('profile.favorites'),
          'subtitle': _language.t('more.favoritesSubtitle'),
          'route': '/favorite',
          'color': const Color(0xFFE11D48),
        },
        {
          'icon': Icons.card_giftcard_outlined,
          'title': _language.t('profile.promotions'),
          'subtitle': _language.t('more.promotionsSubtitle'),
          'route': '/promotion',
          'color': const Color(0xFFD97706),
        },
        {
          'icon': Icons.language_outlined,
          'title': _language.t('profile.language'),
          'subtitle': _language.t('more.languageSubtitle'),
          'route': '/language',
          'color': const Color(0xFF0891B2),
        },
        {
          'icon': Icons.privacy_tip_outlined,
          'title': _language.t('more.privacyPolicy'),
          'subtitle': _language.t('more.privacyPolicySubtitle'),
          'route': '/legal-policies',
          'color': const Color(0xFF7C3AED),
        },
        {
          'icon': Icons.logout,
          'title': _language.t('profile.logout'),
          'subtitle': _language.t('more.logoutSubtitle'),
          'route': '',
          'color': const Color(0xFFDC2626),
        },
      ];

  @override
  void initState() {
    super.initState();
    _language.addListener(_refreshLanguage);
  }

  @override
  void dispose() {
    _language.removeListener(_refreshLanguage);
    super.dispose();
  }

  void _refreshLanguage() {
    if (mounted) setState(() {});
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
        Navigator.of(context).pushNamed('/booking');
        break;
      case 3:
        Navigator.of(context).pushNamed('/search');
        break;
      case 4:
        break;
    }
  }

  void _handleMenuTap(Map<String, dynamic> item) {
    final route = _textValue(item, 'route');
    final title = _textValue(item, 'title');

    if (route.isNotEmpty) {
      Navigator.of(context).pushNamed(route);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title clicked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: Column(
        children: [
          _buildMobileHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              itemBuilder: (context, index) {
                return _buildMobileMenuItem(_menuItems[index]);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _menuItems.length,
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
      title: _language.t('more.title'),
      subtitle: _language.t('more.subtitle'),
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final profilePanel = _buildProfilePanel(context);
          final menuPanel = _buildDesktopMenuPanel();

          if (stackPanels) {
            return Column(
              children: [
                profilePanel,
                const SizedBox(height: 18),
                menuPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 340, child: profilePanel),
              const SizedBox(width: 24),
              Expanded(child: menuPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfilePanel(BuildContext context) {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CurrentUserAvatar(
                size: 64,
                borderWidth: 3,
                onTap: () => Navigator.of(context).pushNamed('/user-profile'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _language.t('more.user'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _language.t('more.memberAccount'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildProfileStat(
            icon: Icons.bookmark_added_outlined,
            label: _language.t('profile.bookings'),
            value: '12',
          ),
          const SizedBox(height: 10),
          _buildProfileStat(
            icon: Icons.favorite_border,
            label: _language.t('profile.savedHotels'),
            value: '8',
          ),
          const SizedBox(height: 10),
          _buildProfileStat(
            icon: Icons.card_giftcard_outlined,
            label: _language.t('profile.promotions'),
            value: '3',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/edit-profile'),
              icon: const Icon(Icons.manage_accounts_outlined, size: 18),
              label: Text(_language.t('profile.edit')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
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

  Widget _buildDesktopMenuPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _language.t('more.quickActions'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _language.t('more.quickActionsSubtitle'),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 2 : 1;
              final spacing = columns == 2 ? 14.0 : 0.0;
              final itemWidth =
                  (constraints.maxWidth - spacing) / columns.toDouble();

              return Wrap(
                spacing: spacing,
                runSpacing: 14,
                children: [
                  for (final item in _menuItems)
                    SizedBox(
                      width: itemWidth,
                      child: _buildDesktopMenuItem(item),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: Text(
          _language.t('more.title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMenuItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _handleMenuTap(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: _buildMenuItemContent(item, compact: true),
      ),
    );
  }

  Widget _buildDesktopMenuItem(Map<String, dynamic> item) {
    final color = _colorValue(item, 'color');

    return InkWell(
      onTap: () => _handleMenuTap(item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 104),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: _buildMenuItemContent(item),
      ),
    );
  }

  Widget _buildMenuItemContent(
    Map<String, dynamic> item, {
    bool compact = false,
  }) {
    final color = _colorValue(item, 'color');
    final icon = _iconValue(item, 'icon');

    return Row(
      children: [
        Container(
          width: compact ? 40 : 46,
          height: compact ? 40 : 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: compact ? 20 : 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _textValue(item, 'title'),
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _textValue(item, 'subtitle'),
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildProfileStat({
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.colorPrimary,
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: _language.t('nav.home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mail_outline),
            activeIcon: const Icon(Icons.mail),
            label: _language.t('nav.message'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            activeIcon: const Icon(Icons.book),
            label: _language.t('nav.booking'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: _language.t('nav.search'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: _language.t('nav.menu'),
          ),
        ],
      ),
    );
  }

  String _textValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString();
  }

  IconData _iconValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is IconData) return value;
    return Icons.circle_outlined;
  }

  Color _colorValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is Color) return value;
    return AppColors.colorPrimary;
  }
}
