import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class HotelDetailScreen extends StatefulWidget {
  const HotelDetailScreen({Key? key, this.hotel}) : super(key: key);

  final Map<String, dynamic>? hotel;

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  static const Map<String, dynamic> _fallbackHotel = {
    'name': 'Grand Palais Hotel',
    'location': 'Rond-Point Carpe d\'As, 34300 LE CAP D\'AGDE, Pháp',
    'rating': 4.5,
    'reviews': 10,
    'price': 734235,
    'description':
        'Tọa lạc tại trung tâm Hà Nội, Grand Palais là khách sạn mang phong cách kiến trúc thanh lịch và chiều sâu cổ điển. Đây là điểm đến lý tưởng cho du khách đang tìm kiếm không gian nghỉ dưỡng sang trọng nhưng vẫn giữ được sự riêng tư và yên bình giữa lòng thành phố.',
  };

  static const List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.king_bed_outlined, 'label': '2 giường đôi'},
    {'icon': Icons.ac_unit, 'label': 'Điều hòa 2 chiều'},
    {'icon': Icons.bathtub_outlined, 'label': 'Phòng tắm riêng'},
    {'icon': Icons.window_outlined, 'label': 'Nhìn xuống phố'},
    {'icon': Icons.kitchen_outlined, 'label': 'Nhà bếp nhỏ'},
    {'icon': Icons.tv_outlined, 'label': 'TV 4k sắc nét'},
    {'icon': Icons.volume_off_outlined, 'label': 'Hệ thống cách âm'},
  ];

  int _selectedDetailTab = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.hotel ?? const <String, dynamic>{};
    final hotelName = _hotelName(data);
    final address = _stringValue(data, 'location', _fallbackHotel['location']);
    final rating = _doubleValue(data, 'rating', _fallbackHotel['rating']);
    final reviews = _reviewCount(data['reviews']);
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
                const WebPanel(
                  padding: EdgeInsets.all(14),
                  child: _HotelRoomPreview(),
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
          const _HotelRoomPreview(),
          const SizedBox(height: 14),
        ],
        Text(
          hotelName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
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
        _buildSelectedTabContent(rating, reviews),
        const SizedBox(height: 16),
        Text(
          '${_formatPrice(price)} VND',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
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
      ],
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    return Container(
      height: 54,
      color: AppColors.colorSurface,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF0B6AA8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.apartment,
              color: AppColors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'EasyStay',
            style: TextStyle(
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

  Widget _buildSelectedTabContent(double rating, int reviews) {
    switch (_selectedDetailTab) {
      case 1:
        return _buildReviewsContent(rating, reviews);
      case 2:
        return _buildRefundPolicyContent();
      case 0:
      default:
        return const Text(
          'Các phòng nghỉ tại Grand Palais được thiết kế với nội thất cao cấp, giường ngủ êm ái chuẩn quốc tế, phòng tắm lát đá cẩm thạch và trang thiết bị hiện đại như TV thông minh, minibar và Wi-Fi tốc độ cao. Khách sạn còn cung cấp đầy đủ tiện ích như nhà hàng ẩm thực quốc tế, spa thư giãn, phòng gym hiện đại và dịch vụ đưa đón sân bay. Đội ngũ nhân viên chuyên nghiệp, tận tâm luôn sẵn sàng phục vụ 24/7, mang đến cho bạn trải nghiệm lưu trú hoàn hảo.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            height: 1.42,
          ),
        );
    }
  }

  Widget _buildReviewsContent(double rating, int reviews) {
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
                const Text(
                  'Khách đánh giá cao vị trí, phòng sạch và nhân viên hỗ trợ tốt.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReviewItem(
          'Nguyễn Minh Anh',
          'Phòng rộng, sạch và yên tĩnh. Vị trí rất tiện để di chuyển vào trung tâm.',
          5,
        ),
        const SizedBox(height: 10),
        _buildReviewItem(
          'Trần Quốc Bảo',
          'Nhân viên thân thiện, thủ tục nhận phòng nhanh. Bữa sáng ổn và đầy đủ.',
          4,
        ),
      ],
    );
  }

  Widget _buildReviewItem(String name, String comment, int stars) {
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
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
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
                    index < stars ? Icons.star : Icons.star_border,
                    size: 13,
                    color: const Color(0xFFFFC247),
                  ),
                ),
              ),
            ],
          ),
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
      ),
    );
  }

  Widget _buildRefundPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPolicyLine(
          'Miễn phí hủy trước 18:00, 27 tháng 9 2025',
          'Bạn có thể hủy phòng trong thời hạn miễn phí và không bị tính phí.',
          true,
        ),
        const SizedBox(height: 10),
        _buildPolicyLine(
          'Không cần thanh toán trước',
          'Bạn sẽ thanh toán trực tiếp khi đến chỗ nghỉ theo chính sách đặt phòng.',
          true,
        ),
        const SizedBox(height: 10),
        _buildPolicyLine(
          'Sau thời hạn miễn phí',
          'Nếu hủy muộn hoặc không đến nhận phòng, chỗ nghỉ có thể tính phí theo giá phòng đã đặt.',
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
            Icons.credit_card_off_outlined,
            color: AppColors.textPrimary,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không cần thẻ tín dụng',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Bạn sẽ thanh toán khi đến chỗ nghỉ',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - 18) / 2;
        return Wrap(
          spacing: 18,
          runSpacing: 10,
          children: _amenities.map((amenity) {
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
    return const Row(
      children: [
        Icon(
          Icons.restaurant_outlined,
          size: 17,
          color: AppColors.textPrimary,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Có bữa sáng (đã bao gồm trong tiền phòng)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _hotelName(Map<String, dynamic> data) {
    final name = _stringValue(data, 'name', _fallbackHotel['name']);
    final normalized = name.toLowerCase();
    if (!normalized.contains('hotel') && !normalized.contains('palais')) {
      return _fallbackHotel['name'] as String;
    }
    return name;
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

  int _priceValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(digits) ?? (_fallbackHotel['price'] as int);
    }
    return _fallbackHotel['price'] as int;
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
