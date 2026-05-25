import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class PaymentInformationScreen extends StatelessWidget {
  const PaymentInformationScreen({
    super.key,
    this.room,
    this.hotel,
    this.customer,
    this.roomCount = 1,
    this.checkInDate,
    this.checkOutDate,
  });

  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;
  final Map<String, dynamic>? customer;
  final int roomCount;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      backgroundColor: AppColors.colorBg,
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildHotelCard(),
                  const SizedBox(height: 12),
                  _buildPriceCard(),
                  const SizedBox(height: 14),
                  _buildCancellationPolicy(),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
      mobileBottomNavigationBar: _buildBottomBar(context),
      desktopBody: WebAppShell(
        title: 'Booking Details',
        subtitle:
            'Kiem tra phong, gia, chinh sach huy va hoan tat buoc cuoi cung tren man hinh rong.',
        selectedIndex: 2,
        child: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildHotelCard(),
              const SizedBox(height: 18),
              _buildCancellationPolicy(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 380,
          child: Column(
            children: [
              _buildPriceCard(),
              const SizedBox(height: 16),
              _buildBottomBar(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back,
                size: 21,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Chi tiết đặt phòng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard() {
    return _buildSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHotelImage(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _hotelName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _hotelLocation,
            style: const TextStyle(
              fontSize: 11,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => const Icon(
                  Icons.star,
                  size: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '($_hotelRating stars) • $_hotelReviews',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStayDate(
                    label: 'Nhận phòng',
                    value: _checkInDate,
                  ),
                ),
                const VerticalDivider(
                  width: 24,
                  color: Color(0xFFBFC6D0),
                  thickness: 1,
                ),
                Expanded(
                  child: _buildStayDate(
                    label: 'Trả phòng',
                    value: _checkOutDate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bạn đã chọn',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$_nightCount dem, 1 phong cho $_guestText',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotelImage() {
    final image = _stringValue(hotel?['image'] ?? room?['image'], '🏨');
    final isUrl = image.startsWith('http://') || image.startsWith('https://');

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: 84,
        height: 74,
        color: const Color(0xFFE8EDF3),
        child: isUrl
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildHotelImageFallback();
                },
              )
            : _buildHotelImageFallback(icon: image),
      ),
    );
  }

  Widget _buildHotelImageFallback({String icon = '🏨'}) {
    return Center(
      child: Text(
        icon,
        style: const TextStyle(fontSize: 34),
      ),
    );
  }

  Widget _buildStayDate({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard() {
    return _buildSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceLine('Gia phong x $_nightCount dem', _finalPrice),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Giá',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatPrice(_finalPrice)} VND',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Đã bao gồm thuế và phí',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary.withValues(alpha: 0.72),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 13),
          const Text(
            'Thông tin giá',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 18,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã bao gồm ${_formatPrice(_taxAndFee)} VND thuế và phí',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Xem chi tiết',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.colorPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          const Text(
            'Bao gồm các quyền lợi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBenefit(Icons.room_service_outlined, 'Bữa sáng miễn phí'),
          const SizedBox(height: 8),
          _buildBenefit(
            Icons.airport_shuttle_outlined,
            'Miễn phí taxi sân bay',
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(
    String label,
    int value, {
    bool isDiscount = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '${isDiscount ? '- ' : ''}${_formatPrice(value)} VND',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefit(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'Chính sách huỷ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _buildSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPolicyLine(
                'Hủy miễn phí trước 18:00, 27 tháng 9 2025',
              ),
              const SizedBox(height: 10),
              _buildPolicyLine(
                'Không cần thanh toán trước - thanh toán tại chỗ nghỉ',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyLine(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check,
          size: 16,
          color: Color(0xFF26B6A5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: Color(0xFF26B6A5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatPrice(_finalPrice)} VND',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Đã bao gồm thuế và phí',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/payment-card',
                  arguments: {
                    'room': room,
                    'hotel': hotel,
                    'customer': customer,
                    'roomCount': roomCount,
                    'checkInDate': checkInDate,
                    'checkOutDate': checkOutDate,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Bước cuối cùng',
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildSection({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }

  String get _hotelName => _stringValue(hotel?['name'], 'Fortune Hotel');

  String get _hotelLocation {
    return _stringValue(
      hotel?['location'],
      '33 Nguyễn Trung Trực 33/1, Quận 1, Thành phố Hồ Chí Minh, Việt Nam',
    );
  }

  String get _hotelRating {
    final rating = hotel?['rating'];
    if (rating is num) return rating.toStringAsFixed(1);
    if (rating is String && rating.trim().isNotEmpty) return rating.trim();
    return '4.5';
  }

  String get _hotelReviews {
    final reviews = hotel?['reviews'];
    if (reviews is int) return '$reviews reviews';
    if (reviews is String && reviews.trim().isNotEmpty) return reviews.trim();
    return '30 reviews';
  }

  String get _checkInDate =>
      _formatDate(checkInDate ?? DateTime.now().add(const Duration(days: 1)));

  String get _checkOutDate =>
      _formatDate(checkOutDate ?? DateTime.now().add(const Duration(days: 2)));

  String get _guestText {
    final guests = room?['guests'];
    if (guests is String && guests.trim().isNotEmpty) return guests.trim();
    return '1 người lớn';
  }

  int get _nightCount {
    final days = (checkOutDate ?? DateTime.now().add(const Duration(days: 2)))
        .difference(checkInDate ?? DateTime.now().add(const Duration(days: 1)))
        .inDays;
    return days < 1 ? 1 : days;
  }

  int get _finalPrice {
    final price = _asInt(room?['price']) ?? 128000;
    return price * _nightCount;
  }

  int get _taxAndFee {
    return (_asInt(room?['taxAndFee']) ?? 0) * _nightCount;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    return null;
  }

  String _stringValue(dynamic value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
