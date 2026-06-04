import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int _selectedIndex = 4;
  bool _showSaved = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchText = '';
  String? _selectedGroup;
  late List<Map<String, dynamic>> _savedHotels;

  @override
  void initState() {
    super.initState();
    _savedHotels = [];
    _loadFavoriteHotels();
  }

  List<Map<String, dynamic>> get _visibleSavedHotels {
    final query = _searchText.trim().toLowerCase();
    return _savedHotels.where((hotel) {
      final groupKey = _groupKeyForHotel(hotel);
      if (_selectedGroup != null && groupKey != _selectedGroup) {
        return false;
      }
      if (query.isEmpty) return true;
      return _textValue(hotel, 'name').toLowerCase().contains(query) ||
          _textValue(hotel, 'location').toLowerCase().contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _favoriteGroups {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final hotel in _savedHotels) {
      final key = _groupKeyForHotel(hotel);
      groups.putIfAbsent(key, () => []).add(hotel);
    }

    final colors = [
      AppColors.colorPrimary,
      const Color(0xFF0891B2),
      const Color(0xFFD97706),
      const Color(0xFF7C3AED),
      const Color(0xFF16A34A),
    ];

    var index = 0;
    return groups.entries.map((entry) {
      final latest = entry.value
          .map((hotel) => hotel['favoriteCreatedAt'])
          .whereType<DateTime>()
          .fold<DateTime?>(null, (current, value) {
        if (current == null || value.isAfter(current)) return value;
        return current;
      });
      final color = colors[index++ % colors.length];
      return {
        'title': entry.key,
        'date': latest == null
            ? 'Đã lưu trên StaySmart'
            : 'Lưu gần nhất ${_formatDate(latest)}',
        'saved': '${entry.value.length} khách sạn đã lưu',
        'color': color,
        'groupKey': entry.key,
      };
    }).toList()
      ..sort((left, right) =>
          _textValue(left, 'title').compareTo(_textValue(right, 'title')));
  }

  Future<void> _loadFavoriteHotels() async {
    if (!ApiService().isAuthenticated) {
      setState(() {
        _savedHotels = [];
        _errorMessage = 'Vui lòng đăng nhập để xem khách sạn yêu thích.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hotels = await ApiService().fetchFavoriteHotels();
      if (!mounted) return;
      setState(() {
        _savedHotels = hotels;
        if (_selectedGroup != null &&
            !_savedHotels
                .any((hotel) => _groupKeyForHotel(hotel) == _selectedGroup)) {
          _selectedGroup = null;
        }
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
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
        if (_showSaved) _buildSavedHotels() else _buildFavoriteGroups(),
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
            'Nhóm địa điểm',
            '${_favoriteGroups.length}',
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
                  _showSaved ? 'Khách sạn đã lưu' : 'Nhóm yêu thích',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _loadFavoriteHotels,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tải lại'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_showSaved)
            _buildSavedHotels(wide: true)
          else
            _buildFavoriteGroups(wide: true),
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
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Tìm khách sạn hoặc địa điểm...',
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
            label: 'Khách sạn',
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
            label: 'Nhóm địa điểm',
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

  Widget _buildSavedHotels({bool wide = false}) {
    final hotels = _visibleSavedHotels;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _buildStateMessage(_errorMessage!);
    }

    if (hotels.isEmpty) {
      if (_savedHotels.isEmpty) {
        return _buildStateMessage('Bạn chưa lưu khách sạn nào.');
      }
      return _buildStateMessage('Không tìm thấy khách sạn phù hợp.');
    }

    return Column(
      children: [
        if (_selectedGroup != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActiveGroupChip(),
          ),
        for (var index = 0; index < hotels.length; index++) ...[
          if (!wide || index > 0) const SizedBox(height: 14),
          _buildHotelCard(hotels[index], wide: wide),
        ],
      ],
    );
  }

  Widget _buildFavoriteGroups({bool wide = false}) {
    final groups = _favoriteGroups;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _buildStateMessage(_errorMessage!);
    }

    if (groups.isEmpty) {
      return _buildStateMessage(
          'Chưa có nhóm yêu thích. Hãy lưu khách sạn trước.');
    }

    if (!wide) {
      return Column(
        children: [
          for (final item in groups) _buildFavoriteListItem(item),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 2 : 1;
        final spacing = columns == 2 ? 14.0 : 0.0;
        final itemWidth = (constraints.maxWidth - spacing) / columns.toDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (final item in groups)
              SizedBox(
                width: itemWidth,
                child: _buildFavoriteListCard(item),
              ),
          ],
        );
      },
    );
  }

  Widget _buildActiveGroupChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InputChip(
        label: Text('Đang lọc: $_selectedGroup'),
        onDeleted: () {
          setState(() {
            _selectedGroup = null;
          });
        },
        deleteIcon: const Icon(Icons.close, size: 16),
        backgroundColor: AppColors.colorPrimary.withValues(alpha: 0.08),
        side: BorderSide(color: AppColors.colorPrimary.withValues(alpha: 0.18)),
      ),
    );
  }

  Widget _buildStateMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
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
            tooltip: 'Xem nhóm này',
            onPressed: () => _selectFavoriteGroup(item),
            icon: const Icon(
              Icons.chevron_right,
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
            tooltip: 'Xem nhóm này',
            onPressed: () => _selectFavoriteGroup(item),
            icon: const Icon(Icons.chevron_right, size: 20),
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

    return InkWell(
      onTap: () => _openHotelDetail(hotel),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            _buildHotelThumbnail(hotel, colors, wide: wide),
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
                      IconButton(
                        tooltip: 'Bỏ yêu thích',
                        onPressed: () => _removeFavorite(hotel),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 17,
                        ),
                      ),
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
                    Icons.bookmark_added_outlined,
                    _favoriteSavedText(hotel),
                  ),
                  const SizedBox(height: 5),
                  _buildHotelInfo(
                    Icons.info_outline,
                    _hotelSubtitle(hotel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelThumbnail(
    Map<String, dynamic> hotel,
    List<Color> colors, {
    required bool wide,
  }) {
    final imageUrl = _textValue(hotel, 'imageUrl');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: wide ? 132 : 100,
        height: wide ? 126 : 114,
        child: imageUrl.isEmpty
            ? DecoratedBox(
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
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return DecoratedBox(
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
                  );
                },
              ),
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
        items: customerBottomNavigationItems(),

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

  void _selectFavoriteGroup(Map<String, dynamic> item) {
    final groupKey = _textValue(item, 'groupKey');
    if (groupKey.isEmpty) return;
    setState(() {
      _selectedGroup = groupKey;
      _showSaved = true;
    });
  }

  Future<void> _openHotelDetail(Map<String, dynamic> hotel) async {
    final hotelId = _intValue(hotel['id'] ?? hotel['hotelId']);
    if (hotelId == null || hotelId <= 0) return;

    Map<String, dynamic> detail = hotel;
    try {
      detail = {
        ...await ApiService().fetchHotel(hotelId),
        'favoriteId': hotel['favoriteId'],
        'favoriteCreatedAt': hotel['favoriteCreatedAt'],
      };
    } on ApiException {
      // The favorite summary is enough to open the detail page shell.
    }

    if (!mounted) return;
    await Navigator.of(context).pushNamed('/hotel-detail', arguments: detail);
  }

  Future<void> _removeFavorite(Map<String, dynamic> hotel) async {
    final hotelId = _intValue(hotel['id'] ?? hotel['hotelId']);
    if (hotelId == null || hotelId <= 0) return;

    try {
      final stillFavorite = await ApiService().toggleFavorite(hotelId);
      if (!mounted) return;
      if (!stillFavorite) {
        setState(() {
          _savedHotels.removeWhere(
            (item) => _intValue(item['id'] ?? item['hotelId']) == hotelId,
          );
          if (_selectedGroup != null &&
              !_savedHotels
                  .any((item) => _groupKeyForHotel(item) == _selectedGroup)) {
            _selectedGroup = null;
          }
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  String _groupKeyForHotel(Map<String, dynamic> hotel) {
    final location = _textValue(hotel, 'location').trim();
    if (location.isEmpty || location == 'Dang cap nhat dia chi') {
      return 'Đang cập nhật địa điểm';
    }
    final parts = location
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? location : parts.last;
  }

  String _favoriteSavedText(Map<String, dynamic> hotel) {
    final createdAt = hotel['favoriteCreatedAt'];
    if (createdAt is DateTime) {
      return 'Đã lưu ${_formatDate(createdAt)}';
    }
    return 'Đã lưu trong danh sách yêu thích';
  }

  String _hotelSubtitle(Map<String, dynamic> hotel) {
    final status = _textValue(hotel, 'status');
    if (status.isNotEmpty) return 'Trạng thái: $status';
    final description = _textValue(hotel, 'description');
    if (description.isNotEmpty) return description;
    return 'Mở chi tiết để xem phòng và tiện nghi';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
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
