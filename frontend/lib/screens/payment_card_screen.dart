import 'package:flutter/material.dart';

import '../utils/colors.dart';

class PaymentCardScreen extends StatelessWidget {
  const PaymentCardScreen({
    Key? key,
    this.room,
    this.hotel,
    this.customer,
    this.roomCount = 1,
  }) : super(key: key);

  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;
  final Map<String, dynamic>? customer;
  final int roomCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBg,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 2, 18, 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _buildPaymentMethod(context),
                        const SizedBox(height: 12),
                        _buildBookingConditions(),
                        const SizedBox(height: 18),
                        const Text(
                          'Thông tin đặt phòng của bạn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildHotelCard(),
                        const SizedBox(height: 12),
                        _buildPriceCard(),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _buildBottomBar(context),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
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
              'Hoàn tất đặt phòng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    return _buildSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn muốn thanh toán bằng thẻ nào ?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 42,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.textPrimary),
            ),
            child: const Icon(
              Icons.credit_card,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Thẻ mới',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/payment-no-card',
                arguments: {
                  'room': room,
                  'hotel': hotel,
                  'customer': customer,
                  'roomCount': roomCount,
                },
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.colorBg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.credit_card_off_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Không cần thẻ tín dụng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed('/add-promotion'),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Thêm mã khuyến mãi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.colorPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điều kiện đặt phòng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildSection(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _buildConditionLine(
                Icons.money_off_csred_outlined,
                'Không hoàn tiền',
                isBold: true,
              ),
              const SizedBox(height: 8),
              _buildConditionLine(
                Icons.schedule_outlined,
                'Thanh toán cho chỗ nghỉ trước khi đến',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionLine(
    IconData icon,
    String label, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textPrimary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
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
                      '1 đêm, $safeRoomCount phòng cho $_guestText',
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
          _buildPriceLine('Giá gốc', _basePrice),
          const SizedBox(height: 9),
          _buildPriceLine('Giảm giá VIP', _vipDiscount, isDiscount: true),
          const SizedBox(height: 9),
          _buildPriceLine(
            'Giá chỉ có trên điện thoại',
            _mobileDiscount,
            isDiscount: true,
          ),
          const SizedBox(height: 9),
          _buildPriceLine('Mã khuyến mãi', _promoDiscount, isDiscount: true),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${_formatPrice(_basePrice)} VND',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                '${_formatPrice(_basePrice)} VND',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
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
                  '/booking-success',
                  arguments: {
                    'room': room,
                    'hotel': hotel,
                    'customer': customer,
                    'paymentMethod': 'card',
                    'roomCount': roomCount,
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
                'Đặt ngay',
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

  Widget _buildSection({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      padding: padding,
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
      _stringValue(hotel?['checkIn'], 'Th 6, 10 Thg 10, 2025');

  String get _checkOutDate =>
      _stringValue(hotel?['checkOut'], 'Sun, 28 Sept 2025');

  String get _guestText {
    final guests = room?['guests'];
    if (guests is String && guests.trim().isNotEmpty) return guests.trim();
    return '1 người lớn';
  }

  int get safeRoomCount => roomCount < 1 ? 1 : roomCount;

  int get _basePrice {
    final price = _asInt(room?['price']) ?? 128000;
    return price * safeRoomCount;
  }

  int get _vipDiscount => _scaledFromDesign(20000);

  int get _mobileDiscount => _scaledFromDesign(10000);

  int get _promoDiscount {
    final discount = _basePrice - _vipDiscount - _mobileDiscount - _targetPrice;
    return discount > 0 ? discount : 0;
  }

  int get _targetPrice => _scaledFromDesign(36000);

  int get _finalPrice {
    final value = _basePrice - _vipDiscount - _mobileDiscount - _promoDiscount;
    return value > 0 ? value : _targetPrice;
  }

  int get _taxAndFee {
    return _asInt(room?['taxAndFee']) ?? ((_finalPrice * 7878) / 36000).round();
  }

  int _scaledFromDesign(int value) {
    return ((_basePrice * value) / 128000).round();
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
}
