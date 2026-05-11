import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int _selectedIndex = 4;
  bool _showSaved = false;

  static const List<Map<String, dynamic>> _favoriteLists = [
    {
      'title': 'TP. Hồ Chí Minh',
      'date': '27 - 30 tháng 9 2025',
      'saved': '3 mục đã lưu',
      'color': AppColors.colorPrimary,
    },
    {
      'title': 'Hà Nội',
      'date': '10 - 28 tháng 10 2025',
      'saved': '1 mục đã lưu',
      'color': Color(0xFF0891B2),
    },
    {
      'title': 'Nhật Bản',
      'date': '2 - 10 tháng 11 2025',
      'saved': '5 mục đã lưu',
      'color': Color(0xFFD97706),
    },
    {
      'title': 'Mỹ',
      'date': '23 - 25 tháng 12 2025',
      'saved': '4 mục đã lưu',
      'color': Color(0xFF7C3AED),
    },
  ];

  static const List<Map<String, dynamic>> _savedHotels = [
    {
      'name': 'Ocean Breeze Hotel',
      'location': '36 Lý Thường Kiệt, Hoàn Kiếm',
      'price': '2.400.000 VND / đêm',
      'rating': '4.7',
      'date': 'Ngày 12 - 14, Thg 11, 2024',
      'guests': 'Khách 2 người lớn (1 phòng)',
      'colors': [Color(0xFF7A9A74), Color(0xFFE4C7A1)],
    },
    {
      'name': 'Horizon Sky Hotel',
      'location': '45 Bà Triệu, Hoàn Kiếm, Hà Nội',
      'price': '2.700.000 VND / đêm',
      'rating': '4.7',
      'date': 'Ngày 08 - 10, Thg 09, 2024',
      'guests': 'Khách 2 người lớn (1 phòng)',
      'colors': [Color(0xFFA65F45), Color(0xFFE0B79A)],
    },
    {
      'name': 'Velora Boutique Hotel',
      'location': '52 Kim Mã, Ba Đình, Hà Nội',
      'price': '3.600.000 VND / đêm',
      'rating': '4.8',
      'date': 'Ngày 15 - 17, Thg 05, 2025',
      'guests': 'Khách 3 người lớn (1 phòng)',
      'colors': [Color(0xFF9B927C), Color(0xFFE4DED1)],
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
      title: 'Favorites',
      subtitle:
          'Quản lý danh sách điểm đến đã lưu và mở nhanh các khách sạn yêu thích cho lần đặt tiếp theo.',
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final controlPanel = _buildDesktopControlPanel();
          final contentPanel = _buildDesktopContentPanel();

          if (stackPanels) {
            return Column(
              children: [
                controlPanel,
                const SizedBox(height: 18),
                contentPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: controlPanel),
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
      children: [
        _buildTitleRow(context),
        const SizedBox(height: 18),
        _buildSearchField(),
        const SizedBox(height: 18),
        _buildSegmentedTabs(),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 4),
        if (_showSaved)
          for (var index = 0; index < _savedHotels.length; index++) ...[
            const SizedBox(height: 14),
            _buildHotelCard(_savedHotels[index]),
          ]
        else
          for (final item in _favoriteLists) _buildFavoriteListItem(item),
      ],
    );
  }

  Widget _buildDesktopControlPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bộ sưu tập',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chuyển nhanh giữa danh sách đã lưu và khách sạn yêu thích.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildSegmentedTabs(),
          const SizedBox(height: 22),
          _buildSummaryTile(
            Icons.folder_copy_outlined,
            'Danh sách',
            '${_favoriteLists.length}',
          ),
          const SizedBox(height: 10),
          _buildSummaryTile(
            Icons.favorite_border,
            'Mục lưu',
            '${_savedHotels.length}',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContentPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _showSaved ? 'Khách sạn đã lưu' : 'Danh sách yêu thích',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo danh sách'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_showSaved)
            Column(
              children: [
                for (var index = 0; index < _savedHotels.length; index++) ...[
                  _buildHotelCard(_savedHotels[index], wide: true),
                  if (index < _savedHotels.length - 1)
                    const SizedBox(height: 14),
                ],
              ],
            )
          else
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
                    for (final item in _favoriteLists)
                      SizedBox(
                        width: itemWidth,
                        child: _buildFavoriteListCard(item),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(
    IconData icon,
    String label,
    String value, {
    Color color = AppColors.colorPrimary,
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
              'Favorite',
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

  Widget _buildSearchField() {
    return SizedBox(
      height: 42,
      child: TextField(
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search...',
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.iconMuted,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFFBFC6D0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFFBFC6D0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: AppColors.colorPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Row(
      children: [
        Expanded(
          child: _buildSegmentButton(
            label: 'Mục lưu',
            selected: _showSaved,
            onTap: () {
              setState(() {
                _showSaved = true;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSegmentButton(
            label: 'Danh sách',
            selected: !_showSaved,
            onTap: () {
              setState(() {
                _showSaved = false;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? AppColors.colorPrimary : AppColors.white,
          foregroundColor: selected ? AppColors.white : AppColors.textPrimary,
          side: BorderSide(
            color: selected ? AppColors.colorPrimary : const Color(0xFFBFC6D0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteListItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFBFC6D0)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildFavoriteText(item)),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteListCard(Map<String, dynamic> item) {
    final color = _colorValue(item, 'color');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildFavoriteText(item)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteText(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _textValue(item, 'title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _textValue(item, 'date'),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _textValue(item, 'saved'),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHotelCard(
    Map<String, dynamic> hotel, {
    bool wide = false,
  }) {
    final colors = _colorsValue(hotel);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: wide ? 132 : 100,
              height: wide ? 126 : 114,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.hotel,
                  size: 42,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _textValue(hotel, 'name'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: wide ? 16 : 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: Colors.orange),
                    const SizedBox(width: 3),
                    Text(
                      _textValue(hotel, 'rating'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildHotelInfo(
                  Icons.location_on_outlined,
                  _textValue(hotel, 'location'),
                ),
                const SizedBox(height: 4),
                Text(
                  _textValue(hotel, 'price'),
                  style: TextStyle(
                    fontSize: wide ? 13 : 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                _buildHotelInfo(
                  Icons.calendar_today_outlined,
                  _textValue(hotel, 'date'),
                ),
                const SizedBox(height: 5),
                _buildHotelInfo(
                  Icons.person_outline,
                  _textValue(hotel, 'guests'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelInfo(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textPrimary,
            ),
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

  Color _colorValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is Color) return value;
    return AppColors.colorPrimary;
  }

  List<Color> _colorsValue(Map<String, dynamic> data) {
    final value = data['colors'];
    if (value is List<Color> && value.length >= 2) return value;
    return const [Color(0xFF7A9A74), Color(0xFFE4C7A1)];
  }
}
