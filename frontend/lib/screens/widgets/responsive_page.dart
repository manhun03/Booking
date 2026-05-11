import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class ResponsivePageScaffold extends StatelessWidget {
  const ResponsivePageScaffold({
    Key? key,
    required this.mobileBody,
    required this.desktopBody,
    this.mobileBottomNavigationBar,
    this.backgroundColor = AppColors.colorBg,
    this.desktopBreakpoint = 980,
  }) : super(key: key);

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
    Key? key,
    required this.title,
    required this.subtitle,
    required this.selectedIndex,
    required this.child,
    this.maxWidth = 1180,
  }) : super(key: key);

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
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  }) : super(key: key);

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
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D6C96),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_hotel,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'EasyStay',
                  style: TextStyle(
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
                  tooltip: 'Thông báo',
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined),
                  color: AppColors.textPrimary,
                  tooltip: 'Cài đặt',
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/user-profile'),
                  child: Container(
                    width: 36,
                    height: 36,
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
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.white,
                    ),
                  ),
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
    _WebNavItem('Home', Icons.home_outlined, '/home'),
    _WebNavItem('Message', Icons.group_outlined, '/message'),
    _WebNavItem('Booking', Icons.add_box_outlined, '/booking'),
    _WebNavItem('Search', Icons.search, '/search'),
    _WebNavItem('Menu', Icons.menu, '/more'),
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
            item.label,
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
  const _WebNavItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
