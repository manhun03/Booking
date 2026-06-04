import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class HotelDetailScreen extends StatefulWidget {
  const HotelDetailScreen({super.key, this.hotel});

  final Map<String, dynamic>? hotel;

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  static const Map<String, dynamic> _fallbackHotel = {
    'name': 'Khách sạn StaySmart',
    'location': 'Đang cập nhật địa chỉ',
    'rating': 4.7,
    'reviews': 0,
    'price': 0,
    'description': 'Khách sạn đang cập nhật mô tả chi tiết.',
  };

  static const List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.info_outline, 'label': 'Tiện nghi đang cập nhật'},
    {'icon': Icons.support_agent_outlined, 'label': 'Liên hệ để biết chi tiết'},
  ];

  int _selectedDetailTab = 0;
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _similarHotels = [];
  bool _loadingRelatedData = false;
  bool _reviewsLoaded = false;
  bool _isFavorite = false;
  bool _favoriteHovered = false;
  bool _savingFavorite = false;

  @override
  void initState() {
    super.initState();
    _selectedDetailTab = _initialDetailTab();
    _isFavorite = widget.hotel?['favoriteId'] != null ||
        widget.hotel?['favorite'] == true ||
        widget.hotel?['isFavorite'] == true;
    _loadRelatedData();
  }

  int _initialDetailTab() {
    final value = widget.hotel?['initialTab'];
    if (value == 'reviews' || value == 1) return 1;
    if (value == 'policy' || value == 2) return 2;
    return 0;
  }

  Future<void> _loadRelatedData() async {
    final hotelId = _hotelId(widget.hotel ?? const <String, dynamic>{});
    if (hotelId == null) return;

    setState(() {
      _loadingRelatedData = true;
    });

    try {
      final rooms = await ApiService().fetchRoomsByHotel(hotelId);
      if (mounted) setState(() => _rooms = rooms);
    } catch (_) {
      // The hotel summary can still render when room data is unavailable.
    }

    try {
      final images = await ApiService().fetchHotelImages(hotelId);
      if (mounted) setState(() => _images = images);
    } catch (_) {
      // Keep the generated preview when the hotel has no accessible image.
    }

    try {
      final reviews = await ApiService().fetchReviewsByHotel(hotelId);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _reviewsLoaded = true;
        });
      }
    } catch (_) {
      // Reviews are optional supporting content for the detail page.
    }

    try {
      final similar = await ApiService().fetchSimilarHotels(hotelId: hotelId);
      if (mounted) setState(() => _similarHotels = similar);
    } catch (_) {
      // Similar hotels are optional supporting content for the detail page.
    }

    await _loadFavoriteState(hotelId);

    if (!mounted) return;
    setState(() {
      _loadingRelatedData = false;
    });
  }

  Future<void> _loadFavoriteState(int hotelId) async {
    if (!ApiService().isAuthenticated) return;

    try {
      final isFavorite = await ApiService().isFavoriteHotel(hotelId);
      if (!mounted) return;
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (_) {
      // Favorite state is optional; the detail page can still render.
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.hotel ?? const <String, dynamic>{};
    final hotelName = _hotelName(data);
    final address = _stringValue(data, 'location', _fallbackHotel['location']);
    final rating = _reviewsLoaded
        ? _averageRating
        : _doubleValue(data, 'rating', _fallbackHotel['rating']);
    final reviews =
        _reviewsLoaded ? _reviews.length : _reviewCount(data['reviews']);
    final price = _priceValue(data['price']);

    final mergedHotel = {
      ..._fallbackHotel,
      ...data,
      'name': hotelName,
      'location': address,
      'rating': rating,
      'reviews': reviews,
      'price': price,
    };

    return ResponsivePageScaffold(
      mobileBody: Column(
        children: [
          _buildBrandHeader(context),
          _buildTitleBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: _buildHotelContent(
                context: context,
                data: data,
                mergedHotel: mergedHotel,
                hotelName: hotelName,
                address: address,
                rating: rating,
                reviews: reviews,
                price: price,
              ),
            ),
          ),
        ],
      ),
      desktopBody: _buildDesktopPage(
        context: context,
        data: data,
        mergedHotel: mergedHotel,
        hotelName: hotelName,
        address: address,
        rating: rating,
        reviews: reviews,
        price: price,
      ),
    );
  }

  Widget _buildDesktopPage({
    required BuildContext context,
    required Map<String, dynamic> data,
    required Map<String, dynamic> mergedHotel,
    required String hotelName,
    required String address,
    required double rating,
    required int reviews,
    required int price,
  }) {
    return WebAppShell(
      title: hotelName,
      subtitle: address,
      selectedIndex: 3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                WebPanel(
                  padding: const EdgeInsets.all(14),
                  child: _buildHotelMedia(),
                ),
                const SizedBox(height: 20),
                WebPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Vị trí chỗ nghỉ'),
                      const SizedBox(height: 10),
                      _buildMap(address),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Tiện ích phù hợp với bạn'),
                      const SizedBox(height: 10),
                      _buildAmenitiesGrid(),
                      const SizedBox(height: 18),
                      _buildSectionTitle('Đồ ăn & thức uống'),
                      const SizedBox(height: 10),
                      _buildFoodInfo(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: WebPanel(
              padding: const EdgeInsets.all(24),
              child: _buildHotelContent(
                context: context,
                data: data,
                mergedHotel: mergedHotel,
                hotelName: hotelName,
                address: address,
                rating: rating,
                reviews: reviews,
                price: price,
                compactMedia: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelContent({
    required BuildContext context,
    required Map<String, dynamic> data,
    required Map<String, dynamic> mergedHotel,
    required String hotelName,
    required String address,
    required double rating,
    required int reviews,
    required int price,
    bool compactMedia = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compactMedia) ...[
          _buildHotelMedia(),
          const SizedBox(height: 14),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                hotelName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildFavoriteButton(data),
          ],
        ),
        const SizedBox(height: 8),
        _buildRatingRow(rating, reviews),
        const SizedBox(height: 10),
        Text(
          _stringValue(data, 'description', _fallbackHotel['description']),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            height: 1.42,
          ),
        ),
        const SizedBox(height: 18),
        _buildLinkTabs(),
        const SizedBox(height: 12),
        _buildSelectedTabContent(mergedHotel, rating, reviews),
        const SizedBox(height: 16),
        _buildPriceText(price),
        const SizedBox(height: 3),
        const Text(
          'Đã bao gồm thuế và phí',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 16),
        _buildNoCardNotice(),
        if (!compactMedia) ...[
          const SizedBox(height: 20),
          _buildSectionTitle('Vị trí chỗ nghỉ'),
          const SizedBox(height: 10),
          _buildMap(address),
          const SizedBox(height: 20),
          _buildSectionTitle('Tiện ích phù hợp với bạn'),
          const SizedBox(height: 10),
          _buildAmenitiesGrid(),
          const SizedBox(height: 18),
          _buildSectionTitle('Đồ ăn & thức uống'),
          const SizedBox(height: 10),
          _buildFoodInfo(),
        ],
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/room-list',
                arguments: mergedHotel,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorPrimary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Xem phòng trống',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 16),
        _buildContactSection(mergedHotel, hotelName),
        if (_similarHotels.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSimilarHotels(),
        ],
      ],
    );
  }

  Widget _buildSimilarHotels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Khach san tuong tu'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _similarHotels.map((hotel) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _similarHotelCard(hotel),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _similarHotelCard(Map<String, dynamic> hotel) {
    final imageUrl = hotel['imageUrl']?.toString().trim() ?? '';
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacementNamed(
          '/hotel-detail',
          arguments: hotel,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 180,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 92,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: imageUrl.isEmpty
                      ? const ColoredBox(
                          color: AppColors.colorBg,
                          child: Center(child: Text('🏨')),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: AppColors.colorBg,
                            child: Center(child: Text('🏨')),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel['name']?.toString() ?? 'Hotel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hotel['location']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hotel['price']?.toString() ?? 'Xem gia phong',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(Map<String, dynamic> data) {
    final activeColor = (_isFavorite || _favoriteHovered)
        ? Colors.red
        : AppColors.textSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _favoriteHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _favoriteHovered = false;
        });
      },
      child: Tooltip(
        message: _isFavorite ? 'Bỏ yêu thích' : 'Lưu vào yêu thích',
        child: InkWell(
          onTap: _savingFavorite ? null : () => _toggleFavorite(data),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (_isFavorite || _favoriteHovered)
                  ? Colors.red.withValues(alpha: 0.08)
                  : AppColors.colorBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: (_isFavorite || _favoriteHovered)
                    ? Colors.red.withValues(alpha: 0.35)
                    : AppColors.divider,
              ),
            ),
            child: Center(
              child: _savingFavorite
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: activeColor,
                      ),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: activeColor,
                      size: 20,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(Map<String, dynamic> data) async {
    final hotelId = _hotelId(data);
    if (hotelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy khách sạn để lưu.')),
      );
      return;
    }
    if (!ApiService().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để lưu yêu thích.')),
      );
      return;
    }

    setState(() {
      _savingFavorite = true;
    });

    try {
      final isFavorite = await ApiService().toggleFavorite(hotelId);
      if (!mounted) return;
      setState(() {
        _isFavorite = isFavorite;
        _savingFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Đã lưu khách sạn vào mục yêu thích.'
                : 'Đã bỏ khách sạn khỏi mục yêu thích.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _savingFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Widget _buildBrandHeader(BuildContext context) {
    return Container(
      height: 54,
      color: AppColors.colorSurface,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const StaySmartBrandButton(
            icon: Icons.apartment,
            circleSize: 28,
            iconSize: 15,
            spacing: 4,
            circleColor: Color(0xFF0B6AA8),
            textStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          _headerIcon(
            icon: Icons.notifications_none,
            badge: true,
            onTap: () => Navigator.of(context).pushNamed('/notification'),
          ),
          const SizedBox(width: 10),
          _headerIcon(icon: Icons.settings_outlined),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/user-profile'),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6B4C35), Color(0xFFD6A66E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon({
    required IconData icon,
    bool badge = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 19, color: AppColors.textPrimary),
            if (badge)
              Positioned(
                right: 0,
                top: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.colorBg,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Hotel Detail',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.tune,
              color: AppColors.colorPrimary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(double rating, int reviews) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final star = rating >= index + 1
                ? Icons.star
                : rating > index
                    ? Icons.star_half
                    : Icons.star_border;
            return Icon(star, size: 15, color: const Color(0xFFFFC247));
          }),
        ),
        const SizedBox(width: 4),
        Text(
          '($rating stars) • $reviews reviews',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkTabs() {
    return Row(
      children: [
        _buildTabButton(0, 'Chi tiết'),
        const SizedBox(width: 18),
        _buildTabButton(1, 'Đánh giá'),
        const SizedBox(width: 18),
        _buildTabButton(2, 'Chính sách hoàn trả'),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedDetailTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDetailTab = index;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.colorPrimary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppColors.colorPrimary : AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(
    Map<String, dynamic> hotel,
    double rating,
    int reviews,
  ) {
    switch (_selectedDetailTab) {
      case 1:
        return _buildReviewsContent(rating, reviews);
      case 2:
        return _buildRefundPolicyContent();
      case 0:
      default:
        return Text(
          _detailDescription(hotel),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            height: 1.42,
          ),
        );
    }
  }

  Widget _buildReviewsContent(double rating, int reviews) {
    if (!_reviewsLoaded) {
      return const Text(
        'Đang tải đánh giá...',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      );
    }

    if (reviews == 0) {
      return const Text(
        'Khách sạn này chưa có đánh giá từ người dùng.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.42,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingRow(rating, reviews),
                const SizedBox(height: 3),
                Text(
                  '$reviews đánh giá từ khách hàng đã lưu trú.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < _reviews.length; index++) ...[
          _buildReviewItem(_reviews[index]),
          if (index < _reviews.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final rating = _intValue(review['rating'], 0);
    final comment = review['comment']?.toString().trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Khách hàng StaySmart',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 13,
                    color: const Color(0xFFFFC247),
                  ),
                ),
              ),
            ],
          ),
          if (comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              comment,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _reportReview(review),
              icon: const Icon(Icons.flag_outlined, size: 15),
              label: const Text('Bao cao'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reportReview(Map<String, dynamic> review) async {
    final reviewId = _intValue(review['id'], 0);
    if (reviewId <= 0) return;
    final reason = await _showReportReviewDialog();
    if (reason == null || reason.trim().isEmpty) return;
    try {
      await ApiService().reportReview(reviewId: reviewId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da bao cao danh gia.')),
      );
      final hotelId = _hotelId(widget.hotel ?? const <String, dynamic>{});
      if (hotelId != null) {
        final reviews = await ApiService().fetchReviewsByHotel(hotelId);
        if (mounted) setState(() => _reviews = reviews);
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<String?> _showReportReviewDialog() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bao cao danh gia'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Ly do bao cao',
            hintText: 'Vi du: noi dung khong phu hop, spam...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Bao cao'),
          ),
        ],
      ),
    );
    controller.dispose();
    return reason;
  }

  Widget _buildRefundPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPolicyLine(
          'Chính sách hủy theo từng phòng',
          'Vui lòng xem điều kiện hủy ở danh sách phòng trước khi đặt.',
          true,
        ),
        const SizedBox(height: 10),
        _buildPolicyLine(
          'Thanh toán linh hoạt',
          'Một số phòng cho phép thanh toán sau hoặc thanh toán theo yêu cầu của khách sạn.',
          true,
        ),
        const SizedBox(height: 10),
        _buildPolicyLine(
          'Cập nhật theo dữ liệu phòng',
          'Giá và chính sách có thể thay đổi theo phòng, ngày lưu trú và trạng thái còn trống.',
          false,
        ),
      ],
    );
  }

  Widget _buildPolicyLine(String title, String description, bool positive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          positive ? Icons.check : Icons.info_outline,
          color: positive ? AppColors.colorSecondary : AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: positive
                      ? AppColors.colorSecondary
                      : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoCardNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: AppColors.colorBg,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.iconMuted),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.payments_outlined,
            color: AppColors.textPrimary,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin thanh toán',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Điều kiện thanh toán được xác nhận theo phòng đã chọn',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
    Map<String, dynamic> hotel,
    String hotelName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Liên hệ khách sạn',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 32,
          child: OutlinedButton(
            onPressed: () => _openHotelOwnerChat(hotel, hotelName),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.colorPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.zero,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Liên hệ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.call_outlined,
                  size: 13,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotelMedia() {
    final imageUrl = _primaryImageUrl;
    if (imageUrl != null) {
      return AspectRatio(
        aspectRatio: 1.24,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _HotelRoomPreview(),
          ),
        ),
      );
    }

    return const _HotelRoomPreview();
  }

  Widget _buildPriceText(int price) {
    if (_loadingRelatedData && price <= 0) {
      return const Text(
        'Đang tải giá phòng...',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    if (price <= 0) {
      return const Text(
        'Xem giá phòng',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return Text(
      'Từ ${_formatPrice(price)} VND',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildMap(String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 96,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0F5),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.divider),
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            child: CustomPaint(painter: _MapPainter()),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          address,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid() {
    final amenities = _dynamicAmenities;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - 18) / 2;
        return Wrap(
          spacing: 18,
          runSpacing: 10,
          children: amenities.map((amenity) {
            return SizedBox(
              width: columnWidth,
              child: Row(
                children: [
                  Icon(
                    amenity['icon'] as IconData,
                    size: 17,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      amenity['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFoodInfo() {
    return Row(
      children: [
        const Icon(
          Icons.restaurant_outlined,
          size: 17,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _rooms.isEmpty
                ? 'Thông tin ăn uống đang được khách sạn cập nhật'
                : 'Kiểm tra bữa sáng và phụ phí trong từng loại phòng',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String? get _primaryImageUrl {
    for (final image in _images) {
      final value = image['imageUrl'];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    final value = widget.hotel?['imageUrl'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  List<Map<String, dynamic>> get _dynamicAmenities {
    if (_rooms.isEmpty) return _amenities;

    final maxCapacity = _rooms
        .map((room) => _intValue(room['capacity'], 0))
        .fold<int>(0, (max, capacity) => capacity > max ? capacity : max);
    final availableRooms = _rooms
        .where((room) => '${room['status'] ?? ''}'.toUpperCase() == 'AVAILABLE')
        .length;

    return [
      {'icon': Icons.king_bed_outlined, 'label': '${_rooms.length} loại phòng'},
      {
        'icon': Icons.groups_outlined,
        'label': maxCapacity > 0
            ? 'Tối đa $maxCapacity khách/phòng'
            : 'Sức chứa linh hoạt'
      },
      {
        'icon': Icons.event_available_outlined,
        'label': '$availableRooms phòng đang sẵn sàng'
      },
      {'icon': Icons.payments_outlined, 'label': 'Thanh toán theo đặt phòng'},
      {'icon': Icons.wifi_outlined, 'label': 'Thông tin tiện nghi theo phòng'},
      {'icon': Icons.support_agent_outlined, 'label': 'Hỗ trợ từ khách sạn'},
    ];
  }

  String _detailDescription(Map<String, dynamic> hotel) {
    final description = _stringValue(
      hotel,
      'description',
      _fallbackHotel['description'],
    );
    final roomText = _rooms.isEmpty
        ? ''
        : ' Khách sạn hiện có ${_rooms.length} loại phòng đang được hiển thị trên StaySmart.';
    return '$description$roomText';
  }

  int? _hotelId(Map<String, dynamic> data) {
    return _intValue(data['id'], 0) == 0 ? null : _intValue(data['id'], 0);
  }

  String _hotelName(Map<String, dynamic> data) {
    return _stringValue(data, 'name', _fallbackHotel['name']);
  }

  String _stringValue(Map<String, dynamic> data, String key, dynamic fallback) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback as String;
  }

  double _doubleValue(Map<String, dynamic> data, String key, dynamic fallback) {
    final value = data[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ??
          (fallback as num).toDouble();
    }
    return (fallback as num).toDouble();
  }

  int _intValue(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  int _reviewCount(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      final match = RegExp(r'\d+').firstMatch(value);
      if (match != null) {
        return int.tryParse(match.group(0) ?? '') ??
            (_fallbackHotel['reviews'] as int);
      }
    }
    return _fallbackHotel['reviews'] as int;
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<int>(
      0,
      (sum, review) => sum + _intValue(review['rating'], 0),
    );
    return double.parse((total / _reviews.length).toStringAsFixed(1));
  }

  int _priceValue(dynamic value) {
    final roomPrices = _rooms
        .map((room) => _intValue(room['price'], 0))
        .where((price) => price > 0)
        .toList();
    if (roomPrices.isNotEmpty) {
      roomPrices.sort();
      return roomPrices.first;
    }

    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(digits) ?? 0;
    }
    return _fallbackHotel['price'] as int;
  }

  void _openHotelOwnerChat(Map<String, dynamic> hotel, String hotelName) {
    final backend = hotel['backend'];
    final ownerId = _intValue(
      hotel['ownerId'] ?? (backend is Map ? backend['ownerId'] : null),
      0,
    );
    if (ownerId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy chủ khách sạn.')),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      '/message-chat',
      arguments: {
        'userId': ownerId,
        'name': hotelName,
      },
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }
}

class _HotelRoomPreview extends StatelessWidget {
  const _HotelRoomPreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: CustomPaint(
          painter: const _HotelRoomPainter(),
          child: Container(),
        ),
      ),
    );
  }
}

class _HotelRoomPainter extends CustomPainter {
  const _HotelRoomPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEFE7D8), Color(0xFFCBB89D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wallPaint);

    final floorPaint = Paint()..color = const Color(0xFF5A3D2A);
    final floor = Path()
      ..moveTo(0, size.height * .72)
      ..lineTo(size.width, size.height * .61)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(floor, floorPaint);

    final windowPaint = Paint()..color = const Color(0xFF5A6672);
    final glowPaint = Paint()..color = const Color(0xFFF5D285);
    final windowRect = Rect.fromLTWH(
      size.width * .58,
      size.height * .12,
      size.width * .32,
      size.height * .43,
    );
    canvas.drawRect(windowRect, windowPaint);
    canvas.drawRect(windowRect.deflate(6), glowPaint);
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top),
      Offset(windowRect.center.dx, windowRect.bottom),
      Paint()
        ..color = const Color(0xFF6E6252)
        ..strokeWidth = 3,
    );

    final curtainPaint = Paint()..color = const Color(0xFF806B54);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .54,
        size.height * .09,
        size.width * .045,
        size.height * .48,
      ),
      curtainPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .9,
        size.height * .09,
        size.width * .045,
        size.height * .48,
      ),
      curtainPaint,
    );

    final lampPaint = Paint()..color = const Color(0xFFF4C86A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .22, size.height * .28),
        width: size.width * .12,
        height: size.height * .08,
      ),
      lampPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .42, size.height * .22),
        width: size.width * .12,
        height: size.height * .08,
      ),
      lampPaint,
    );

    final headboardPaint = Paint()..color = const Color(0xFF4E4037);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .06,
          size.height * .43,
          size.width * .47,
          size.height * .2,
        ),
        const Radius.circular(4),
      ),
      headboardPaint,
    );

    final bedBasePaint = Paint()..color = const Color(0xFF2D2B2C);
    final bed = Path()
      ..moveTo(size.width * .03, size.height * .67)
      ..lineTo(size.width * .55, size.height * .57)
      ..lineTo(size.width * .83, size.height * .88)
      ..lineTo(size.width * .24, size.height * .98)
      ..close();
    canvas.drawPath(bed, bedBasePaint);

    final sheetPaint = Paint()..color = const Color(0xFFEAE6DD);
    final sheet = Path()
      ..moveTo(size.width * .07, size.height * .62)
      ..lineTo(size.width * .5, size.height * .55)
      ..lineTo(size.width * .74, size.height * .82)
      ..lineTo(size.width * .25, size.height * .9)
      ..close();
    canvas.drawPath(sheet, sheetPaint);

    final runnerPaint = Paint()..color = const Color(0xFF5F473C);
    final runner = Path()
      ..moveTo(size.width * .42, size.height * .58)
      ..lineTo(size.width * .51, size.height * .57)
      ..lineTo(size.width * .76, size.height * .84)
      ..lineTo(size.width * .63, size.height * .87)
      ..close();
    canvas.drawPath(runner, runnerPaint);

    final pillowPaint = Paint()..color = const Color(0xFFF8F6F0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .12,
          size.height * .49,
          size.width * .17,
          size.height * .1,
        ),
        const Radius.circular(5),
      ),
      pillowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .31,
          size.height * .47,
          size.width * .17,
          size.height * .1,
        ),
        const Radius.circular(5),
      ),
      pillowPaint,
    );

    final tablePaint = Paint()..color = const Color(0xFF332C27);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .82,
        size.height * .59,
        size.width * .13,
        size.height * .05,
      ),
      tablePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .86,
        size.height * .64,
        size.width * .025,
        size.height * .19,
      ),
      tablePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFEAF0F5);
    canvas.drawRect(Offset.zero & size, background);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadShadowPaint = Paint()
      ..color = const Color(0xFFD7DFE7)
      ..strokeWidth = 11
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mainRoad = Path()
      ..moveTo(-10, size.height * .74)
      ..cubicTo(
        size.width * .24,
        size.height * .58,
        size.width * .38,
        size.height * .85,
        size.width * .62,
        size.height * .54,
      )
      ..cubicTo(
        size.width * .76,
        size.height * .36,
        size.width * .9,
        size.height * .45,
        size.width + 10,
        size.height * .28,
      );
    canvas.drawPath(mainRoad, roadShadowPaint);
    canvas.drawPath(mainRoad, roadPaint);

    final secondaryRoad = Path()
      ..moveTo(size.width * .1, -8)
      ..cubicTo(
        size.width * .18,
        size.height * .2,
        size.width * .08,
        size.height * .46,
        size.width * .32,
        size.height * .62,
      )
      ..cubicTo(
        size.width * .44,
        size.height * .7,
        size.width * .48,
        size.height * .86,
        size.width * .42,
        size.height + 8,
      );
    canvas.drawPath(secondaryRoad, roadShadowPaint);
    canvas.drawPath(secondaryRoad, roadPaint);

    final waterPaint = Paint()..color = const Color(0xFFCAE7F2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .68,
          size.height * .68,
          size.width * .22,
          size.height * .18,
        ),
        const Radius.circular(18),
      ),
      waterPaint,
    );

    final parkPaint = Paint()..color = const Color(0xFFD9EFD5);
    canvas.drawCircle(
        Offset(size.width * .18, size.height * .24), 18, parkPaint);
    canvas.drawCircle(
        Offset(size.width * .82, size.height * .22), 20, parkPaint);

    final markerPaint = Paint()..color = const Color(0xFFE94343);
    final markerCenter = Offset(size.width * .52, size.height * .47);
    final marker = Path()
      ..addOval(Rect.fromCircle(center: markerCenter, radius: 9))
      ..moveTo(markerCenter.dx - 6, markerCenter.dy + 6)
      ..lineTo(markerCenter.dx, markerCenter.dy + 20)
      ..lineTo(markerCenter.dx + 6, markerCenter.dy + 6)
      ..close();
    canvas.drawPath(marker, markerPaint);
    canvas.drawCircle(markerCenter, 3, Paint()..color = Colors.white);

    final hotelPaint = Paint()..color = const Color(0xFF2E6FAF);
    canvas.drawCircle(
        Offset(size.width * .34, size.height * .48), 4, hotelPaint);
    canvas.drawCircle(
        Offset(size.width * .72, size.height * .36), 4, hotelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
