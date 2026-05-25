import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class BillScreen extends StatelessWidget {
  const BillScreen({
    super.key,
    this.room,
    this.hotel,
    this.customer,
    this.paymentMethod,
    this.roomCount = 1,
    this.checkInDate,
    this.checkOutDate,
    this.booking,
    this.payment,
  });

  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;
  final Map<String, dynamic>? customer;
  final String? paymentMethod;
  final int roomCount;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final Map<String, dynamic>? booking;
  final Map<String, dynamic>? payment;

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      backgroundColor: AppColors.colorBg,
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildHotelCard(),
                  const SizedBox(height: 26),
                  _buildMessageCard(),
                  const SizedBox(height: 28),
                  _buildRatingCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: 'Booking Confirmed',
        subtitle:
            'Xem tom tat dat phong, thong bao xac nhan va danh gia trai nghiem sau khi hoan tat.',
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
          child: _buildHotelCard(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildMessageCard(),
              const SizedBox(height: 18),
              _buildRatingCard(),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/booking',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('Xem booking cua toi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
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
                Icons.close,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/booking',
                  (route) => false,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Xác nhận đặt phòng',
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

  Widget _buildHotelCard() {
    return _buildSection(
      padding: const EdgeInsets.all(10),
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
              color: AppColors.textPrimary,
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
                        fontWeight: FontWeight.w800,
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
      borderRadius: BorderRadius.circular(2),
      child: Container(
        width: 88,
        height: 76,
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
        style: const TextStyle(fontSize: 36),
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
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard() {
    final bookingId = booking?['id'];
    final bookingStatus = _stringValue(booking?['status'], 'Dang cho xac nhan');
    final paymentStatus = _stringValue(payment?['status'], '');
    final paymentText =
        paymentStatus.isEmpty ? '' : ' Trang thai thanh toan: $paymentStatus.';
    return _buildSection(
      child: Text(
        "Dat phong thanh cong${bookingId == null ? '' : ' #$bookingId'}. Trang thai booking: $bookingStatus.$paymentText",
        style: const TextStyle(
          fontSize: 12,
          height: 1.35,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    return _buildSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn thấy chất lượng dịch vụ của app như nào?',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bỏ ra 5s để vote cho đội ngũ phát triển nhé.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  Icons.star_border,
                  size: 32,
                  color: AppColors.textPrimary,
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
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(2),
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

  String get _checkInDate =>
      _formatDate(checkInDate ?? DateTime.now().add(const Duration(days: 1)));

  String get _checkOutDate =>
      _formatDate(checkOutDate ?? DateTime.now().add(const Duration(days: 2)));

  String get _guestText {
    final guests = room?['guests'];
    if (guests is String && guests.trim().isNotEmpty) return guests.trim();
    return '2 người lớn';
  }

  int get _nightCount {
    final start = checkInDate ?? DateTime.now().add(const Duration(days: 1));
    final end = checkOutDate ?? start.add(const Duration(days: 1));
    final days = end.difference(start).inDays;
    return days < 1 ? 1 : days;
  }

  String _stringValue(dynamic value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
