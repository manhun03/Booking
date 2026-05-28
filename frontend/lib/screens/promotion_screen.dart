import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final ApiService _api = ApiService();
  int _selectedIndex = 4;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.restoreSession();
      final vouchers = await _api.fetchCoupons();
      if (!mounted) return;
      setState(() {
        _vouchers = vouchers;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openAddPromotion() async {
    final result = await Navigator.of(context).pushNamed('/add-promotion');
    if (!mounted) return;
    final code = result is Map<String, dynamic>
        ? result['code']?.toString()
        : result?.toString();
    if (code == null || code.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Da chon ma ${code.trim()}')),
    );
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
            child: RefreshIndicator(
              onRefresh: _loadVouchers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
                child: Column(
                  children: [
                    _buildTitleRow(context),
                    const SizedBox(height: 20),
                    _buildHero(),
                    const SizedBox(height: 22),
                    _buildVoucherActions(),
                    const SizedBox(height: 18),
                    _buildVoucherList(),
                  ],
                ),
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
          'Theo doi voucher dang co, them ma uu dai va chon khuyen mai phu hop cho lan dat phong tiep theo.',
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Voucher hien co',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tai lai',
                      onPressed: _loadVouchers,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildVoucherList(wide: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherList({bool wide = false}) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 34),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return _buildStateCard(
        icon: Icons.error_outline,
        title: 'Khong tai duoc voucher',
        message: _error!,
        actionLabel: 'Thu lai',
        onAction: _loadVouchers,
      );
    }

    if (_vouchers.isEmpty) {
      return _buildStateCard(
        icon: Icons.confirmation_number_outlined,
        title: 'Chua co voucher kha dung',
        message: 'Backend hien chua tra ve voucher dang hoat dong.',
        actionLabel: 'Tai lai',
        onAction: _loadVouchers,
      );
    }

    if (!wide) {
      return Column(
        children: [
          for (final voucher in _vouchers) ...[
            _buildVoucherCard(voucher),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 860 ? 2 : 1;
        final spacing = columns == 2 ? 14.0 : 0.0;
        final itemWidth = (constraints.maxWidth - spacing) / columns;

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
    );
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
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
                    'Uu dai dang hoat dong',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Danh sach voucher duoc lay truc tiep tu backend va cap nhat khi admin thay doi ma khuyen mai.',
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
          'Tac vu nhanh',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          Icons.confirmation_number_outlined,
          'Them ma voucher',
          'Nhap ma uu dai ban nhan duoc',
          onTap: _openAddPromotion,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          Icons.refresh,
          'Tai lai voucher',
          'Lay lai danh sach tu backend',
          onTap: _loadVouchers,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          Icons.history,
          'Lich su ap dung',
          'Se hien thi khi co API lich su voucher',
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
              'Promotion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.refresh,
            size: 18,
            color: AppColors.colorPrimary,
          ),
          onPressed: _loadVouchers,
        ),
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
        child: const Center(
          child: Icon(
            Icons.confirmation_number_outlined,
            color: AppColors.white,
            size: 34,
          ),
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
            onTap: _openAddPromotion,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            Icons.refresh,
            'Reload voucher',
            onTap: _loadVouchers,
          ),
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
    final code = _textValue(voucher, 'code');

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
                  const SizedBox(height: 8),
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.colorPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: wide ? 70 : 58,
            height: 30,
            child: ElevatedButton(
              onPressed: () => _claimVoucher(code),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Nhan',
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
    );
  }

  void _claimVoucher(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Da chon ma $code')),
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
      child: const Icon(
        Icons.notifications_none,
        size: 22,
        color: AppColors.textPrimary,
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
