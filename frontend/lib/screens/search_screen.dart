import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late TextEditingController _locationController;
  late TextEditingController _minBudgetController;
  late TextEditingController _maxBudgetController;
  String _sortBy = 'Default';
  int _guestCount = 1;
  bool _hasSearched = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 3;

  late List<Map<String, dynamic>> _suggestedHotels;
  late List<Map<String, dynamic>> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _locationController = TextEditingController();
    _minBudgetController = TextEditingController();
    _maxBudgetController = TextEditingController();
    _suggestedHotels = [];
    _searchResults = const [];
    _loadSuggestedHotels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestedHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hotels = await ApiService().fetchHotels(pageSize: 10);
      if (!mounted) return;
      setState(() {
        _suggestedHotels = hotels;
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

  Future<void> _performSearch(String query) async {
    final keyword = query.trim();
    if (keyword.isEmpty && !_hasActiveFilters) {
      _clearSearch();
      await _loadSuggestedHotels();
      return;
    }

    setState(() {
      _hasSearched = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hotels = await ApiService().fetchHotels(
        keyword: keyword.isEmpty ? null : keyword,
        pageSize: 100,
      );
      final filteredHotels = await _applyFilters(hotels);
      if (!mounted) return;
      setState(() {
        _searchResults = _sortHotels(filteredHotels);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _hasSearched = false;
      _errorMessage = null;
      _searchController.clear();
      _locationController.clear();
      _minBudgetController.clear();
      _maxBudgetController.clear();
      _guestCount = 1;
      _sortBy = 'Default';
      _searchResults = const [];
    });
  }

  void _removeTag(String tag) {
    setState(() {
      if (tag.startsWith('Dia diem:')) {
        _locationController.clear();
      } else if (tag.startsWith('Khach:')) {
        _guestCount = 1;
      } else if (tag.startsWith('Ngan sach:')) {
        _minBudgetController.clear();
        _maxBudgetController.clear();
      }
    });
    _performSearch(_searchController.text);
  }

  Future<List<Map<String, dynamic>>> _applyFilters(
    List<Map<String, dynamic>> hotels,
  ) async {
    final locationKeyword = _locationController.text.trim().toLowerCase();
    final minBudget = _budgetValue(_minBudgetController.text);
    final maxBudget = _budgetValue(_maxBudgetController.text);
    final needsRoomFilter = _guestCount > 1 ||
        minBudget != null ||
        maxBudget != null ||
        _sortBy.startsWith('Gia ');
    final results = <Map<String, dynamic>>[];

    for (final hotel in hotels) {
      if (locationKeyword.isNotEmpty) {
        final haystack = [
          hotel['name'],
          hotel['location'],
          hotel['street'],
        ].whereType<Object>().join(' ').toLowerCase();
        if (!haystack.contains(locationKeyword)) continue;
      }

      if (!needsRoomFilter) {
        results.add(hotel);
        continue;
      }

      final hotelId = _intValue(hotel['id']);
      if (hotelId == null || hotelId <= 0) continue;

      try {
        final rooms = await ApiService().fetchRoomsByHotel(hotelId);
        final matchingRooms = rooms.where((room) {
          final capacity = _intValue(room['capacity']) ?? 1;
          final price = _numValue(room['price']) ?? 0;
          if (capacity < _guestCount) return false;
          if (minBudget != null && price < minBudget) return false;
          if (maxBudget != null && price > maxBudget) return false;
          return true;
        }).toList();
        if (matchingRooms.isEmpty) continue;

        matchingRooms.sort((left, right) {
          final leftPrice = _numValue(left['price']) ?? 0;
          final rightPrice = _numValue(right['price']) ?? 0;
          return leftPrice.compareTo(rightPrice);
        });
        final bestPrice = _numValue(matchingRooms.first['price']);
        results.add({
          ...hotel,
          if (bestPrice != null) 'price': 'Tu ${_formatMoney(bestPrice)} VND',
          'rooms': '${matchingRooms.length} phong phu hop',
          'matchingRoomPrice': bestPrice,
        });
      } catch (_) {
        continue;
      }
    }

    return results;
  }

  List<Map<String, dynamic>> _sortHotels(List<Map<String, dynamic>> hotels) {
    final items = List<Map<String, dynamic>>.from(hotels);
    switch (_sortBy) {
      case 'Gia thap nhat':
        items.sort((left, right) {
          final leftPrice = _numValue(left['matchingRoomPrice']) ?? 0;
          final rightPrice = _numValue(right['matchingRoomPrice']) ?? 0;
          return leftPrice.compareTo(rightPrice);
        });
        break;
      case 'Gia cao nhat':
        items.sort((left, right) {
          final leftPrice = _numValue(left['matchingRoomPrice']) ?? 0;
          final rightPrice = _numValue(right['matchingRoomPrice']) ?? 0;
          return rightPrice.compareTo(leftPrice);
        });
        break;
      case 'Danh gia cao':
        items.sort((left, right) {
          final leftRating = _numValue(left['rating']) ?? 0;
          final rightRating = _numValue(right['rating']) ?? 0;
          return rightRating.compareTo(leftRating);
        });
        break;
    }
    return items;
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
        break;
      case 4:
        Navigator.of(context).pushNamed('/more');
        break;
    }
  }

  Future<void> _showMobileFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void updateGuests(int value) {
              setState(() => _guestCount = value);
              setSheetState(() {});
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                16,
                18,
                18 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Bo loc tim kiem',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFilterTextField(
                      controller: _locationController,
                      icon: Icons.location_on_outlined,
                      label: 'Dia diem',
                      hint: 'Thanh pho, quan hoac dia chi',
                    ),
                    const SizedBox(height: 12),
                    _buildGuestStepperForSheet(updateGuests),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterTextField(
                            controller: _minBudgetController,
                            icon: Icons.payments_outlined,
                            label: 'Gia tu',
                            hint: '500000',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFilterTextField(
                            controller: _maxBudgetController,
                            icon: Icons.payments_outlined,
                            label: 'Den',
                            hint: '2000000',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _clearSearch();
                              Navigator.of(context).pop();
                              _loadSuggestedHotels();
                            },
                            child: const Text('Xoa loc'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _performSearch(_searchController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.colorPrimary,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Ap dung'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: Column(
        children: [
          _buildMobileHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildMobileContent(),
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
      title: 'Search',
      subtitle:
          'Tìm khách sạn theo điểm đến, lọc nhanh theo nhu cầu và xem kết quả phù hợp trên màn hình rộng.',
      selectedIndex: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final filterPanel = _buildDesktopFilterPanel();
          final resultPanel = _buildDesktopResultPanel();

          if (stackPanels) {
            return Column(
              children: [
                filterPanel,
                const SizedBox(height: 18),
                resultPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 340, child: filterPanel),
              const SizedBox(width: 24),
              Expanded(child: resultPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopFilterPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bộ lọc tìm kiếm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchField(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => _performSearch(_searchController.text),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Tìm kiếm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSortRow(),
          const SizedBox(height: 18),
          _buildFilterControls(),
          const SizedBox(height: 18),
          _buildTagWrap(),
          const SizedBox(height: 22),
          _buildFilterTile(
            icon: Icons.calendar_month_outlined,
            label: 'Ngày lưu trú',
            value: '12 - 14 Tháng 11',
          ),
          const SizedBox(height: 10),
          _buildFilterTile(
            icon: Icons.people_outline,
            label: 'Số khách',
            value: '2 người lớn',
          ),
          const SizedBox(height: 10),
          _buildFilterTile(
            icon: Icons.payments_outlined,
            label: 'Ngân sách',
            value: '1.8M - 2.5M VND',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopResultPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _hasSearched ? 'Kết quả phù hợp' : 'Gợi ý phổ biến',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: _clearSearch,
                child: const Text('Xóa tìm kiếm'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _hasSearched
                ? 'Showing ${_searchResults.length} of 100'
                : 'Showing ${_suggestedHotels.length} suggested hotels',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            _buildStateMessage(_errorMessage!)
          else if (_hasSearched && _searchResults.isEmpty)
            _buildStateMessage('Khong tim thay khach san phu hop')
          else if (_hasSearched)
            Column(
              children: [
                for (var index = 0; index < _searchResults.length; index++) ...[
                  _buildResultCard(_searchResults[index], wide: true),
                  if (index < _searchResults.length - 1)
                    const SizedBox(height: 14),
                ],
              ],
            )
          else
            _buildSuggestedList(wide: true),
        ],
      ),
    );
  }

  Widget _buildMobileContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSearchField(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSearchButton(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _buildSortRow(),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: CircularProgressIndicator(),
          )
        else if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStateMessage(_errorMessage!),
          )
        else if (!_hasSearched) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTagWrap(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildShowingRow(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSuggestedList(),
          ),
        ] else if (_searchResults.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStateMessage('Khong tim thay khach san phu hop'),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var index = 0; index < _searchResults.length; index++) ...[
                  _buildResultCard(_searchResults[index]),
                  if (index < _searchResults.length - 1)
                    const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const Text(
            'Search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            onPressed: _showMobileFilters,
            icon: const Icon(
              Icons.tune,
              color: AppColors.colorPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm khách sạn...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.colorPrimary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
      onSubmitted: _performSearch,
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () => _performSearch(_searchController.text),
        icon: const Icon(Icons.tune, size: 18),
        label: const Text('Search'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.colorPrimary,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSortRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Sort by',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        PopupMenuButton<String>(
          initialValue: _sortBy,
          onSelected: (value) {
            setState(() => _sortBy = value);
            if (_hasSearched) {
              setState(() => _searchResults = _sortHotels(_searchResults));
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'Default', child: Text('Mac dinh')),
            PopupMenuItem(value: 'Danh gia cao', child: Text('Danh gia cao')),
            PopupMenuItem(value: 'Gia thap nhat', child: Text('Gia thap nhat')),
            PopupMenuItem(value: 'Gia cao nhat', child: Text('Gia cao nhat')),
          ],
          child: Row(
            children: [
              Text(
                _sortBy,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagWrap() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final tag in _activeTags)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(6),
                color: AppColors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _removeTag(tag),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShowingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Showing 0 of 100',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: _clearSearch,
          child: const Text(
            'Xóa tìm kiếm',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedList({bool wide = false}) {
    return Column(
      children: [
        for (var index = 0; index < _suggestedHotels.length; index++) ...[
          _buildSuggestedHotel(_suggestedHotels[index], wide: wide),
          if (index < _suggestedHotels.length - 1)
            SizedBox(height: wide ? 12 : 14),
        ],
      ],
    );
  }

  Widget _buildStateMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.colorBg,
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

  Widget _buildSuggestedHotel(
    Map<String, dynamic> hotel, {
    bool wide = false,
  }) {
    final color = _colorValue(hotel, 'color');

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/hotel-detail', arguments: hotel);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(wide ? 14 : 0),
        decoration: wide
            ? BoxDecoration(
                color: AppColors.colorBg,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: wide ? 48 : 40,
              height: wide ? 48 : 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconValue(hotel, 'icon'),
                color: color,
                size: wide ? 24 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _textValue(hotel, 'name'),
                    style: TextStyle(
                      fontSize: wide ? 15 : 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _textValue(hotel, 'location'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (wide)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    Map<String, dynamic> hotel, {
    bool wide = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/hotel-detail', arguments: hotel);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: wide
            ? _buildWideResultContent(hotel)
            : _buildMobileResultContent(hotel),
      ),
    );
  }

  Widget _buildMobileResultContent(Map<String, dynamic> hotel) {
    return Row(
      children: [
        _buildHotelImage(hotel, width: 100, height: 116),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildResultDetails(hotel),
          ),
        ),
      ],
    );
  }

  Widget _buildWideResultContent(Map<String, dynamic> hotel) {
    return Row(
      children: [
        _buildHotelImage(hotel, width: 168, height: 150),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: _buildResultDetails(hotel, wide: true),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed('/hotel-detail', arguments: hotel);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.colorPrimary,
                side: const BorderSide(color: AppColors.colorPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xem chi tiết'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDetails(
    Map<String, dynamic> hotel, {
    bool wide = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _textValue(hotel, 'name'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: wide ? 16 : 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 14, color: Colors.orange),
            const SizedBox(width: 2),
            Text(
              _textValue(hotel, 'rating'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          _textValue(hotel, 'location'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _textValue(hotel, 'price'),
          style: TextStyle(
            fontSize: wide ? 14 : 12,
            fontWeight: FontWeight.w800,
            color: AppColors.colorPrimary,
          ),
        ),
        const SizedBox(height: 6),
        _buildMetaLine(Icons.calendar_today, _textValue(hotel, 'date')),
        const SizedBox(height: 4),
        _buildMetaLine(Icons.hotel, _textValue(hotel, 'rooms')),
        const SizedBox(height: 4),
        Text(
          _textValue(hotel, 'reviews'),
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHotelImage(
    Map<String, dynamic> hotel, {
    required double width,
    required double height,
  }) {
    final palette = _paletteValue(hotel);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: palette,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.apartment,
          size: 36,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildMetaLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterTextField(
          controller: _locationController,
          icon: Icons.location_on_outlined,
          label: 'Dia diem',
          hint: 'Thanh pho, quan hoac dia chi',
        ),
        const SizedBox(height: 12),
        _buildGuestStepper(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFilterTextField(
                controller: _minBudgetController,
                icon: Icons.payments_outlined,
                label: 'Gia tu',
                hint: 'VD: 500000',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFilterTextField(
                controller: _maxBudgetController,
                icon: Icons.payments_outlined,
                label: 'Den',
                hint: 'VD: 2000000',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _performSearch(_searchController.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.colorPrimary),
        ),
      ),
    );
  }

  Widget _buildGuestStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'So khach',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed:
                _guestCount <= 1 ? null : () => setState(() => _guestCount--),
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.colorPrimary,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$_guestCount',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _guestCount++),
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.colorPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestStepperForSheet(void Function(int value) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'So khach',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed:
                _guestCount <= 1 ? null : () => onChanged(_guestCount - 1),
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.colorPrimary,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$_guestCount',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: () => onChanged(_guestCount + 1),
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.colorPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return const SizedBox.shrink();
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

  bool get _hasActiveFilters {
    return _locationController.text.trim().isNotEmpty ||
        _guestCount > 1 ||
        _budgetValue(_minBudgetController.text) != null ||
        _budgetValue(_maxBudgetController.text) != null;
  }

  List<String> get _activeTags {
    final tags = <String>[];
    final location = _locationController.text.trim();
    final minBudget = _budgetValue(_minBudgetController.text);
    final maxBudget = _budgetValue(_maxBudgetController.text);
    if (location.isNotEmpty) tags.add('Dia diem: $location');
    if (_guestCount > 1) tags.add('Khach: $_guestCount nguoi');
    if (minBudget != null || maxBudget != null) {
      final minText = minBudget == null ? '0' : _formatMoney(minBudget);
      final maxText =
          maxBudget == null ? 'khong gioi han' : _formatMoney(maxBudget);
      tags.add('Ngan sach: $minText - $maxText');
    }
    return tags;
  }

  int? _budgetValue(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  num? _numValue(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      final normalized = value.replaceAll(RegExp(r'[^0-9.]'), '');
      if (normalized.isEmpty) return null;
      return num.tryParse(normalized);
    }
    return null;
  }

  String _formatMoney(num value) {
    return value.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
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
    return Icons.apartment_outlined;
  }

  Color _colorValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is Color) return value;
    return AppColors.colorPrimary;
  }

  List<Color> _paletteValue(Map<String, dynamic> data) {
    final value = data['palette'];
    if (value is List<Color> && value.length >= 2) return value;
    return const [Color(0xFF9FB5C8), Color(0xFFECE6DD)];
  }
}
