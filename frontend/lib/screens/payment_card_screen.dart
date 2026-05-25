import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class PaymentCardScreen extends StatelessWidget {
  const PaymentCardScreen({
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

    Map<String, dynamic>? createdBooking;
    try {
      var booking = await ApiService().createBooking(
        roomId: roomId,
        guestCount: _guestCount,
        paidAmount: 0,
        checkInDate: _effectiveCheckInDate,
        checkOutDate: _effectiveCheckOutDate,
        paymentMethod: 'CARD',
        note: _bookingNote,
      );
      createdBooking = booking;
      final bookingId = _asInt(booking['id']);
      Map<String, dynamic>? payment;
      if (bookingId != null) {
        payment = await ApiService().initiatePayment(
          bookingId: bookingId,
          provider: 'MOCK',
          method: 'CARD',
        );
        final transactionCode = payment['transactionCode']?.toString();
        if (transactionCode != null && transactionCode.isNotEmpty) {
          payment = await ApiService().completePayment(
            transactionCode: transactionCode,
            gatewayTransactionId: 'MOCK-$transactionCode',
          );
          booking = {
            ...booking,
            'status': 'Da xac nhan',
            'statusCode': 'CONFIRMED',
          };
        }
      }
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _openSuccess(
        context,
        paymentMethod: 'card',
        booking: booking,
        payment: payment,
      );
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (createdBooking != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking da duoc luu nhung thanh toan chua hoan tat: $error',
            ),
          ),
        );
        _openSuccess(
          context,
          paymentMethod: 'card-pending',
          booking: createdBooking,
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _openSuccess(
    BuildContext context, {
    required String paymentMethod,
    Map<String, dynamic>? booking,
    Map<String, dynamic>? payment,
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
        'payment': payment,
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
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildPaymentMethod(context),
                  const SizedBox(height: 12),
                  _buildBookingConditions(),
                  const SizedBox(height: 18),
                  const Text(
                    'Thong tin dat phong cua ban',
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
      mobileBottomNavigationBar: _buildBottomBar(context),
      desktopBody: WebAppShell(
        title: 'Payment',
        subtitle:
            'Chon phuong thuc thanh toan, kiem tra dieu kien dat phong va xac nhan booking.',
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
              _buildPaymentMethod(context),
              const SizedBox(height: 18),
              _buildBookingConditions(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thong tin dat phong cua ban',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              _buildHotelCard(),
              const SizedBox(height: 14),
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
                  'checkInDate': checkInDate,
                  'checkOutDate': checkOutDate,
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
    return '1 người lớn';
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
      'Payment method: card',
    ];
    return parts.join(' | ');
  }

  int get _nightCount {
    final days =
        _effectiveCheckOutDate.difference(_effectiveCheckInDate).inDays;
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
