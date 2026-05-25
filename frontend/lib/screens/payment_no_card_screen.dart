import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class PaymentNoCardScreen extends StatelessWidget {
  const PaymentNoCardScreen({
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

  Future<void> _confirmBooking(BuildContext context) async {
    final roomId = _asInt(room?['id']);
    if (!ApiService().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long dang nhap de dat phong.')),
      );
      unawaited(Navigator.of(context).pushNamed('/login'));
      return;
    }
    if (roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong tim thay phong de dat.')),
      );
      return;
    }

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final booking = await ApiService().createBooking(
        roomId: roomId,
        guestCount: _guestCount,
        paidAmount: 0,
        checkInDate: _effectiveCheckInDate,
        checkOutDate: _effectiveCheckOutDate,
        paymentMethod: 'NO_CARD',
        note: _bookingNote,
      );
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _openSuccess(context, paymentMethod: 'no-card', booking: booking);
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _openSuccess(
    BuildContext context, {
    required String paymentMethod,
    Map<String, dynamic>? booking,
  }) {
    Navigator.pushNamed(
      context,
      '/booking-success',
      arguments: {
        'room': room,
        'hotel': hotel,
        'customer': customer,
        'paymentMethod': paymentMethod,
        'roomCount': roomCount,
        'checkInDate': checkInDate,
        'checkOutDate': checkOutDate,
        'booking': booking,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      backgroundColor: AppColors.colorBg,
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildNoCardNotice(),
                  const SizedBox(height: 12),
                  _buildHotelCard(),
                  const SizedBox(height: 12),
                  _buildPriceCard(),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/add-promotion'),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Them ma khuyen mai',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.colorPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),
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
        title: 'Pay At Property',
        subtitle:
            'Xac nhan thong tin dat phong khong can the tin dung va thanh toan tai cho nghi.',
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
          flex: 6,
          child: Column(
            children: [
              _buildNoCardNotice(),
              const SizedBox(height: 18),
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
              InkWell(
                onTap: () => Navigator.of(context).pushNamed('/add-promotion'),
                borderRadius: BorderRadius.circular(4),
                child: const WebPanel(
                  child: Row(
                    children: [
                      Icon(Icons.local_offer_outlined,
                          color: AppColors.colorPrimary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Them ma khuyen mai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.colorPrimary,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
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
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCardNotice() {
    return _buildSection(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.credit_card_off_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không cần thẻ tín dụng',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Bạn sẽ thanh toán khi đến chỗ nghỉ',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
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
                4,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Giá',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatPrice(_finalPrice)} VND',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Đã bao gồm thuế và phí',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
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
          _buildBenefit(Icons.local_taxi_outlined, 'Miễn phí taxi sân bay'),
        ],
      ),
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
        const Text(
          'Chính sách huỷ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildPolicyLine('Hủy miễn phí trước 18:00, 27 tháng 9 2025'),
        const SizedBox(height: 8),
        _buildPolicyLine(
            'Không cần thanh toán trước - thanh toán tại chỗ nghỉ'),
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
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatPrice(_finalPrice)} VND',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Đã bao gồm thuế và phí',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _confirmBooking(context),
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
        border: Border.all(color: const Color(0xFFBFC6D0)),
      ),
      padding: padding,
      child: child,
    );
  }

  String get _hotelName => _stringValue(hotel?['name'], 'Lucky Hotel');

  String get _hotelLocation {
    return _stringValue(
      hotel?['location'],
      '14/19 Đỗ Quang Đẩu, Quận 1, Thành phố Hồ Chí Minh, Việt Nam',
    );
  }

  String get _hotelRating {
    final rating = hotel?['rating'];
    if (rating is num) return rating.toStringAsFixed(1);
    if (rating is String && rating.trim().isNotEmpty) return rating.trim();
    return '3.5';
  }

  String get _hotelReviews {
    final reviews = hotel?['reviews'];
    if (reviews is int) return '$reviews lượt đánh giá';
    if (reviews is String && reviews.trim().isNotEmpty) return reviews.trim();
    return '10 lượt đánh giá';
  }

  DateTime get _effectiveCheckInDate {
    return checkInDate ?? DateTime.now().add(const Duration(days: 1));
  }

  DateTime get _effectiveCheckOutDate {
    final fallback = _effectiveCheckInDate.add(const Duration(days: 1));
    final selected = checkOutDate ?? fallback;
    return selected.isAfter(_effectiveCheckInDate) ? selected : fallback;
  }

  String get _checkInDate => _formatDate(_effectiveCheckInDate);

  String get _checkOutDate => _formatDate(_effectiveCheckOutDate);

  String get _guestText {
    final guests = room?['guests'];
    if (guests is String && guests.trim().isNotEmpty) return guests.trim();
    return '2 người lớn';
  }

  int get _guestCount {
    final capacity = _asInt(room?['capacity']);
    if (capacity != null && capacity > 0) return capacity;
    return 1;
  }

  String get _bookingNote {
    final email = customer?['email']?.toString().trim();
    final tripPurpose = customer?['tripPurpose']?.toString().trim();
    final parts = <String>[
      if (email != null && email.isNotEmpty) 'Customer email: $email',
      if (tripPurpose != null && tripPurpose.isNotEmpty)
        'Trip purpose: $tripPurpose',
      'Payment method: no-card',
    ];
    return parts.join(' | ');
  }

  int get _nightCount {
    final days =
        _effectiveCheckOutDate.difference(_effectiveCheckInDate).inDays;
    return days < 1 ? 1 : days;
  }

  int get _finalPrice {
    final price = _asInt(room?['price']) ?? 179000;
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
