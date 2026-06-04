import 'package:flutter/material.dart';

import '../../services/language_service.dart';
import '../../utils/colors.dart';
import 'current_user_avatar.dart';

class ResponsivePageScaffold extends StatelessWidget {
  const ResponsivePageScaffold({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
    this.mobileBottomNavigationBar,
    this.backgroundColor = AppColors.colorBg,
    this.desktopBreakpoint = 980,
  });

  final Widget mobileBody;
  final Widget desktopBody;
  final Widget? mobileBottomNavigationBar;
  final Color backgroundColor;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= desktopBreakpoint;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: isDesktop
                ? desktopBody
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: mobileBody,
                    ),
                  ),
          ),
          bottomNavigationBar: isDesktop || mobileBottomNavigationBar == null
              ? null
              : Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: mobileBottomNavigationBar,
                  ),
                ),
        );
      },
    );
  }
}

class WebAppShell extends StatelessWidget {
  const WebAppShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedIndex,
    required this.child,
    this.maxWidth = 1180,
  });

  final String title;
  final String subtitle;
  final int selectedIndex;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _WebBrandBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
        _WebBottomNav(selectedIndex: selectedIndex),
      ],
    );
  }
}

class WebPanel extends StatelessWidget {
  const WebPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class StaySmartBrandButton extends StatelessWidget {
  const StaySmartBrandButton({
    super.key,
    this.showLogo = true,
    this.icon = Icons.local_hotel,
    this.logoText,
    this.circleSize = 34,
    this.iconSize = 17,
    this.spacing = 6,
    this.circleColor = const Color(0xFF1D6C96),
    this.iconColor = AppColors.white,
    this.textStyle = const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w800,
    ),
  });

  final bool showLogo;
  final IconData icon;
  final String? logoText;
  final double circleSize;
  final double iconSize;
  final double spacing;
  final Color circleColor;
  final Color iconColor;
  final TextStyle textStyle;

  static void goHome(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name == '/home') {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: LanguageService().t('nav.home'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => goHome(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLogo) ...[
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: logoText == null
                          ? Icon(
                              icon,
                              color: iconColor,
                              size: iconSize,
                            )
                          : Text(
                              logoText!,
                              style: TextStyle(
                                color: iconColor,
                                fontSize: iconSize,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: spacing),
                ],
                Text('StaySmart', style: textStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebBrandBar extends StatelessWidget {
  const _WebBrandBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      color: AppColors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                const StaySmartBrandButton(
                  circleSize: 36,
                  iconSize: 18,
                  spacing: 8,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/notification'),
                  icon: const Icon(Icons.notifications_none),
                  color: AppColors.textPrimary,
                  tooltip: LanguageService().t('profile.notifications'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/user-profile'),
                  icon: const Icon(Icons.settings_outlined),
                  color: AppColors.textPrimary,
                  tooltip: LanguageService().t('profile.accountSettings'),
                ),
                const SizedBox(width: 8),
                CurrentUserAvatar(
                  size: 36,
                  onTap: () => Navigator.of(context).pushNamed('/user-profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebBottomNav extends StatelessWidget {
  const _WebBottomNav({required this.selectedIndex});

  final int selectedIndex;

  static const _items = [
    _WebNavItem('nav.home', Icons.home_outlined, '/home'),
    _WebNavItem('nav.message', Icons.group_outlined, '/message'),
    _WebNavItem('nav.booking', Icons.add_box_outlined, '/booking'),
    _WebNavItem('nav.search', Icons.search, '/search'),
    _WebNavItem('nav.menu', Icons.menu, '/more'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _buildNavButton(
                        context,
                        _items[i],
                        i == selectedIndex,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    _WebNavItem item,
    bool selected,
  ) {
    return InkWell(
      onTap: () {
        if (!selected) Navigator.of(context).pushNamed(item.route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 22,
            color: selected ? AppColors.colorPrimary : AppColors.textPrimary,
          ),
          const SizedBox(height: 4),
          Text(
            LanguageService().t(item.labelKey),
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? AppColors.colorPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebNavItem {
  const _WebNavItem(this.labelKey, this.icon, this.route);

  final String labelKey;
  final IconData icon;
  final String route;
}

List<BottomNavigationBarItem> customerBottomNavigationItems() {
  final language = LanguageService();
  return [
    BottomNavigationBarItem(
      icon: const Icon(Icons.home_outlined),
      activeIcon: const Icon(Icons.home),
      label: language.t('nav.home'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.group_outlined),
      activeIcon: const Icon(Icons.group),
      label: language.t('nav.message'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.add_box_outlined),
      activeIcon: const Icon(Icons.add_box),
      label: language.t('nav.booking'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.search),
      label: language.t('nav.search'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.menu),
      label: language.t('nav.menu'),
    ),
  ];
}
