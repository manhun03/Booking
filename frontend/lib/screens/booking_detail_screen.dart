import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/payment_redirect.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({
    super.key,
    this.booking,
  });

  final Map<String, dynamic>? booking;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  int _selectedIndex = 2;
  late Map<String, dynamic>? _booking;
  bool _isLoadingPayments = false;
  String? _paymentError;
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _loadPayments();
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

  Future<void> _loadPayments() async {
    final bookingId = _bookingId;
    if (bookingId == null || !ApiService().isAuthenticated) return;

    setState(() {
      _isLoadingPayments = true;
      _paymentError = null;
    });

    try {
      final payments = await ApiService().fetchPaymentsForBooking(bookingId);
      if (!mounted) return;
      setState(() {
        _payments = payments;
        _isLoadingPayments = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _paymentError = error.toString();
        _isLoadingPayments = false;
      });
    }
  }

  Future<void> _openVnpayPayment() async {
    final bookingId = _bookingId;
    if (bookingId == null || _remainingAmount <= 0) return;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      ),
    );

    var loadingOpen = true;
    try {
      final payment = await ApiService().initiatePayment(
        bookingId: bookingId,
        provider: 'VNPAY',
        method: 'VNPAY',
      );
      final checkoutUrl = payment['checkoutUrl']?.toString().trim();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      loadingOpen = false;
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Khong tim thay link thanh toan.')),
        );
        await _loadPayments();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dang chuyen sang VNPay...')),
      );
      redirectToPaymentUrl(checkoutUrl);
    } catch (error) {
      if (!mounted) return;
      if (loadingOpen) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 360 ? 32.0 : 42.0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  18,
                  horizontalPadding,
                  22,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(_buildDetailContent()),
                ),
              ),
            ],
          );
        },
      ),
      desktopBody: _buildDesktopPage(context),
      mobileBottomNavigationBar: SafeArea(
        top: false,
        child: _buildBottomNav(),
      ),
    );
  }

  Widget _buildDesktopPage(BuildContext context) {
    return WebAppShell(
      title: 'Chi tiết phòng đặt',
      subtitle:
          'Xem thông tin phòng, ngày lưu trú, trạng thái đặt phòng và thao tác với đơn trên giao diện web rộng rãi hơn.',
      selectedIndex: 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 5,
            child: WebPanel(
              padding: EdgeInsets.all(18),
              child: _RoomHeroImage(),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: WebPanel(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildDesktopDetailContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailContent() {
    return [
      const _RoomHeroImage(),
      const SizedBox(height: 8),
      _buildRoomTitle(),
      const SizedBox(height: 4),
      _buildRating(),
      const SizedBox(height: 12),
      _buildDetailLine(
        icon: Icons.calendar_month_outlined,
        label: 'Ngày',
        value: _dateText,
      ),
      const SizedBox(height: 8),
      _buildDetailLine(
        icon: Icons.person_outline,
        label: 'Khách',
        value: _guestText,
      ),
      const SizedBox(height: 8),
      _buildStatusLine(),
      const SizedBox(height: 14),
      _buildPaymentSection(),
      const SizedBox(height: 17),
      const Divider(height: 1, color: AppColors.divider),
      const SizedBox(height: 16),
      _buildActionsSection(),
      const SizedBox(height: 16),
      const Divider(height: 1, color: AppColors.divider),
      const SizedBox(height: 16),
      _buildContactSection(
        title: 'Liên hệ khách sạn',
        onPressed: () {},
      ),
      const SizedBox(height: 16),
      const Divider(height: 1, color: AppColors.divider),
      const SizedBox(height: 16),
      _buildContactSection(
        title: 'Liên hệ dịch vụ',
        onPressed: () {},
      ),
    ];
  }

  List<Widget> _buildDesktopDetailContent() {
    return [
      _buildRoomTitle(),
      const SizedBox(height: 6),
      _buildRating(),
      const SizedBox(height: 22),
      _buildDetailLine(
        icon: Icons.calendar_month_outlined,
        label: 'Ngày',
        value: _dateText,
      ),
      const SizedBox(height: 12),
      _buildDetailLine(
        icon: Icons.person_outline,
        label: 'Khách',
        value: _guestText,
      ),
      const SizedBox(height: 12),
      _buildStatusLine(),
      const SizedBox(height: 16),
      _buildPaymentSection(),
      const SizedBox(height: 22),
      const Divider(height: 1, color: AppColors.divider),
      const SizedBox(height: 18),
      _buildActionsSection(),
      const SizedBox(height: 18),
      const Divider(height: 1, color: AppColors.divider),
      const SizedBox(height: 18),
      _buildContactSection(
        title: 'Liên hệ khách sạn',
        onPressed: () {},
      ),
      const SizedBox(height: 18),
      _buildContactSection(
        title: 'Liên hệ dịch vụ',
        onPressed: () {},
      ),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 18, 10),
      child: Row(
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
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chi tiết phòng đặt',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildRoomTitle() {
    return Text(
      _titleText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0D87FF),
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => const Icon(
            Icons.star,
            size: 14,
            color: Color(0xFFFFB703),
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          '(4.5 stars)',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailLine({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 19,
          child: Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine() {
    return Row(
      children: [
        const Text(
          'Trạng thái:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            _statusText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D87FF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    final canPay = _remainingAmount > 0 &&
        _canModifyBooking &&
        _latestPaymentStatusCode != 'PENDING';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Thanh toan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _paymentStatusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _paymentStatusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _paymentStatusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPaymentRow('Tong tien', _formatMoney(_totalAmount)),
          const SizedBox(height: 7),
          _buildPaymentRow('Da thanh toan', _formatMoney(_paidAmount)),
          const SizedBox(height: 7),
          _buildPaymentRow('Con lai', _formatMoney(_remainingAmount)),
          if (_isLoadingPayments) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ] else if (_paymentError != null) ...[
            const SizedBox(height: 12),
            Text(
              _paymentError!,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (_payments.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            ..._payments.take(3).map(_buildPaymentHistoryItem),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'Chua co giao dich thanh toan.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (canPay) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: _openVnpayPayment,
                icon: const Icon(Icons.payment_outlined, size: 16),
                label: const Text('Thanh toan VNPay'),
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
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryItem(Map<String, dynamic> payment) {
    final amount = _numValue(payment['amount']) ?? 0;
    final status = payment['status']?.toString() ?? 'Dang cho thanh toan';
    final provider = payment['provider']?.toString() ?? 'VNPAY';
    final transactionCode = payment['transactionCode']?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 15,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$provider - $status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (transactionCode.isNotEmpty)
                  Text(
                    transactionCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatMoney(amount),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    final canModify = _canModifyBooking;
    final canReview = _canReviewBooking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Các thao tác khác',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (canReview) ...[
          _buildActionLink(
            _hasReviewed ? 'Đã đánh giá' : 'Đánh giá',
            enabled: !_hasReviewed,
            onTap: _openReviewBooking,
          ),
          const SizedBox(height: 9),
        ],
        _buildActionLink(
          'Thay đổi ngày đặt phòng',
          enabled: canModify,
          onTap: _openChangeBookingDate,
        ),
        const SizedBox(height: 9),
        _buildActionLink(
          'Hủy đặt phòng',
          enabled: canModify,
          onTap: _openCancelBooking,
        ),
        if (!canModify) ...[
          const SizedBox(height: 10),
          const Text(
            'Booking này không thể hủy hoặc đổi ngày.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionLink(
    String label, {
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: enabled ? const Color(0xFF0D87FF) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection({
    required String title,
    required VoidCallback onPressed,
  }) {
    final isHotelContact = title.toLowerCase().contains('kh');
    if (!isHotelContact) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
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
            onPressed: _openHotelOwnerChat,
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
        unselectedItemColor: AppColors.textPrimary,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  String get _dateText {
    final date = _booking?['detailDate'];
    if (date is String && date.trim().isNotEmpty) return date.trim();
    return '28 - 30 Thg 10 2025';
  }

  String get _guestText {
    final guests = _booking?['detailGuests'] ?? _booking?['guests'];
    if (guests is String && guests.trim().isNotEmpty) return guests.trim();
    return '2 Người (1 Phòng)';
  }

  String get _statusText {
    final status = _booking?['status'];
    if (status is String && status.trim().isNotEmpty) return status.trim();
    return 'Đang đặt phòng';
  }

  num get _totalAmount {
    return _numValue(
            _booking?['totalAmount'] ?? _backendField('totalAmount')) ??
        0;
  }

  num get _paidAmount {
    return _numValue(_booking?['paidAmount'] ?? _backendField('paidAmount')) ??
        0;
  }

  num get _remainingAmount {
    final explicit = _numValue(
        _booking?['remainingAmount'] ?? _backendField('remainingAmount'));
    if (explicit != null) return explicit < 0 ? 0 : explicit;
    return math.max<num>(0, _totalAmount - _paidAmount);
  }

  String get _paymentStatusText {
    final latestStatus = _latestPaymentStatusCode;
    if (latestStatus.isNotEmpty) return _paymentStatusLabel(latestStatus);
    final mappedStatus = _booking?['paymentStatus']?.toString();
    if (mappedStatus != null && mappedStatus.trim().isNotEmpty) {
      return mappedStatus.trim();
    }
    if (_totalAmount > 0 && _paidAmount >= _totalAmount) {
      return 'Da thanh toan';
    }
    if (_paidAmount > 0) return 'Thanh toan mot phan';
    return 'Chua thanh toan';
  }

  Color get _paymentStatusColor {
    switch (_latestPaymentStatusCode) {
      case 'COMPLETED':
        return const Color(0xFF15803D);
      case 'FAILED':
        return const Color(0xFFDC2626);
      case 'REFUNDED':
      case 'PARTIALLY_REFUNDED':
        return const Color(0xFF7C3AED);
      case 'PENDING':
        return const Color(0xFFD97706);
      default:
        if (_totalAmount > 0 && _paidAmount >= _totalAmount) {
          return const Color(0xFF15803D);
        }
        if (_paidAmount > 0) return const Color(0xFFD97706);
        return AppColors.textSecondary;
    }
  }

  String get _latestPaymentStatusCode {
    if (_payments.isNotEmpty) {
      final status = _payments.first['statusCode']?.toString().trim();
      if (status != null && status.isNotEmpty) return status.toUpperCase();
    }
    final status = _booking?['paymentStatusCode']?.toString().trim();
    return status == null ? '' : status.toUpperCase();
  }

  String _paymentStatusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Da thanh toan';
      case 'FAILED':
        return 'Thanh toan that bai';
      case 'REFUNDED':
        return 'Da hoan tien';
      case 'PARTIALLY_REFUNDED':
        return 'Hoan tien mot phan';
      case 'PARTIAL':
        return 'Thanh toan mot phan';
      case 'PENDING':
        return 'Dang cho thanh toan';
      default:
        return 'Chua thanh toan';
    }
  }

  String get _titleText {
    final name = _booking?['name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
    return 'Chi tiết phòng đặt';
  }

  bool get _canModifyBooking {
    if (_bookingId == null) return false;
    final status = _statusCode;
    return status != 'CANCELLED' &&
        status != 'COMPLETED' &&
        status != 'CHECKED_OUT' &&
        status != 'REJECTED';
  }

  bool get _canReviewBooking {
    final status = _statusCode;
    return _bookingId != null &&
        (status == 'COMPLETED' || status == 'CHECKED_OUT');
  }

  bool get _hasReviewed => _booking?['reviewed'] == true;

  String get _statusCode {
    final code = _booking?['statusCode'] ?? _backendField('status');
    if (code is String && code.trim().isNotEmpty) {
      return code.trim().toUpperCase();
    }
    return '';
  }

  int? get _bookingId => _intValue(_booking?['id'] ?? _backendField('id'));

  Future<void> _openChangeBookingDate() async {
    final result = await Navigator.of(context).pushNamed(
      '/change-booking-date',
      arguments: _booking,
    );
    _syncReturnedBooking(result);
  }

  Future<void> _openCancelBooking() async {
    final result = await Navigator.of(context).pushNamed(
      '/cancel-booking',
      arguments: _booking,
    );
    _syncReturnedBooking(result);
  }

  Future<void> _openReviewBooking() async {
    final result = await Navigator.of(context).pushNamed(
      '/review-booking',
      arguments: _booking,
    );
    if (!mounted || result is! Map<String, dynamic>) return;
    setState(() {
      _booking = <String, dynamic>{
        ...?_booking,
        'reviewed': true,
      };
    });
  }

  Future<void> _openHotelOwnerChat() async {
    var ownerId = _bookingOwnerId;
    if (ownerId == null || ownerId <= 0) {
      await _refreshCurrentBooking();
      if (!mounted) return;
      ownerId = _bookingOwnerId;
    }
    if (ownerId == null || ownerId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong tim thay chu khach san.')),
      );
      return;
    }

    unawaited(
      Navigator.of(context).pushNamed(
        '/message-chat',
        arguments: {
          'userId': ownerId,
          'name': _titleText,
        },
      ),
    );
  }

  int? get _bookingOwnerId => _intValue(
        _booking?['ownerId'] ??
            _backendField('ownerId') ??
            _booking?['hotelOwnerId'] ??
            _backendField('hotelOwnerId'),
      );

  Future<void> _refreshCurrentBooking() async {
    final bookingId = _bookingId;
    if (bookingId == null) return;
    try {
      final bookings = await ApiService().fetchMyBookings(pageSize: 100);
      Map<String, dynamic>? matched;
      for (final item in bookings) {
        if (_intValue(item['id']) == bookingId) {
          matched = item;
          break;
        }
      }
      if (!mounted || matched == null) return;
      setState(() {
        _booking = {
          ...?_booking,
          ...matched!,
        };
      });
    } catch (_) {
      // Keep the current booking data and show the existing missing-owner message.
    }
  }

  void _syncReturnedBooking(Object? result) {
    if (!mounted || result is! Map<String, dynamic>) return;
    setState(() {
      _booking = result;
    });
    unawaited(_loadPayments());
  }

  dynamic _backendField(String key) {
    final backend = _booking?['backend'];
    if (backend is Map<String, dynamic>) return backend[key];
    if (backend is Map) return backend[key];
    return null;
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
      final normalized = value.replaceAll(',', '').trim();
      if (normalized.isEmpty) return null;
      return num.tryParse(normalized) ??
          num.tryParse(normalized.replaceAll(RegExp(r'[^0-9.]'), ''));
    }
    return null;
  }

  String _formatMoney(num value) {
    return '${value.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )} VND';
  }
}

class _RoomHeroImage extends StatelessWidget {
  const _RoomHeroImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: const AspectRatio(
        aspectRatio: 0.82,
        child: CustomPaint(
          painter: _RoomHeroPainter(),
        ),
      ),
    );
  }
}

class _RoomHeroPainter extends CustomPainter {
  const _RoomHeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final roomRect = Offset.zero & size;
    final wallPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE7E1D4),
          Color(0xFFB7AA91),
          Color(0xFFEDE8DD),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(roomRect);
    canvas.drawRect(roomRect, wallPaint);

    _paintCeiling(canvas, size);
    _paintWindows(canvas, size);
    _paintFeatureWall(canvas, size);
    _paintFloor(canvas, size);
    _paintBed(canvas, size);
    _paintFurniture(canvas, size);
  }

  void _paintCeiling(Canvas canvas, Size size) {
    final ceiling = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.22)
      ..lineTo(size.width * 0.44, size.height * 0.17)
      ..lineTo(0, size.height * 0.27)
      ..close();
    canvas.drawPath(
      ceiling,
      Paint()..color = const Color(0xFFD6D1C6),
    );

    final tray = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.09,
        size.width * 0.42,
        size.height * 0.12,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      tray,
      Paint()..color = const Color(0xFFB7AA91),
    );

    final glow = Paint()..color = const Color(0xFFFFC65A);
    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.58, size.height * 0.15),
        radius: size.width * 0.045,
      ),
      glow,
    );
    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(size.width * 0.78, size.height * 0.15),
        radius: size.width * 0.045,
      ),
      glow,
    );

    final spotPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final point in [
      Offset(size.width * 0.38, size.height * 0.2),
      Offset(size.width * 0.52, size.height * 0.24),
      Offset(size.width * 0.7, size.height * 0.23),
    ]) {
      canvas.drawCircle(point, size.width * 0.012, spotPaint);
    }
  }

  void _paintWindows(Canvas canvas, Size size) {
    final framePaint = Paint()..color = const Color(0xFF6B6259);
    final glassPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE8F6FF),
          Color(0xFFA9C5D8),
          Color(0xFFF8FBFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromLTWH(
          size.width * 0.61,
          size.height * 0.24,
          size.width * 0.28,
          size.height * 0.34,
        ),
      );

    final window = Rect.fromLTWH(
      size.width * 0.61,
      size.height * 0.24,
      size.width * 0.28,
      size.height * 0.34,
    );
    canvas.drawRect(window, glassPaint);
    canvas.drawRect(window, framePaint..style = PaintingStyle.stroke);
    framePaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.24),
      Offset(size.width * 0.75, size.height * 0.58),
      framePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.61, size.height * 0.4),
      Offset(size.width * 0.89, size.height * 0.4),
      framePaint,
    );
  }

  void _paintFeatureWall(Canvas canvas, Size size) {
    final wall = Rect.fromLTWH(
      0,
      size.height * 0.25,
      size.width * 0.46,
      size.height * 0.43,
    );
    canvas.drawRect(
      wall,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD7C58E), Color(0xFF998C63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(wall),
    );

    final linePaint = Paint()
      ..color = const Color(0xFF4C463D).withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var i = 0; i < 7; i++) {
      final y = size.height * (0.28 + i * 0.055);
      canvas.drawLine(
          Offset(0, y), Offset(size.width * 0.46, y + 12), linePaint);
    }
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.06 + i * 0.075);
      canvas.drawLine(Offset(x, size.height * 0.25),
          Offset(x - 14, size.height * 0.68), linePaint);
    }

    final plantPaint = Paint()..color = const Color(0xFF476E2B);
    for (var i = 0; i < 8; i++) {
      final cx = size.width * (0.13 + i * 0.038);
      final cy = size.height * (0.41 + math.sin(i) * 0.025);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: size.width * 0.05,
          height: size.height * 0.03,
        ),
        plantPaint,
      );
    }
  }

  void _paintFloor(Canvas canvas, Size size) {
    final floorPath = Path()
      ..moveTo(0, size.height * 0.67)
      ..lineTo(size.width, size.height * 0.56)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      floorPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF5B352A), Color(0xFF241713)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(0, size.height * 0.56, size.width, size.height * 0.44),
        ),
    );

    final seamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var i = 1; i < 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(
        Offset(x, size.height * 0.63),
        Offset(x + size.width * 0.1, size.height),
        seamPaint,
      );
    }
  }

  void _paintBed(Canvas canvas, Size size) {
    final headboard = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.47,
        size.width * 0.54,
        size.height * 0.17,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      headboard,
      Paint()..color = const Color(0xFF4E3A34),
    );

    final bedPath = Path()
      ..moveTo(size.width * 0.02, size.height * 0.63)
      ..lineTo(size.width * 0.57, size.height * 0.58)
      ..lineTo(size.width * 0.78, size.height * 0.84)
      ..lineTo(size.width * 0.18, size.height * 0.98)
      ..close();
    canvas.drawPath(
      bedPath,
      Paint()..color = const Color(0xFFF4F0EA),
    );

    final runnerPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.6)
      ..lineTo(size.width * 0.55, size.height * 0.59)
      ..lineTo(size.width * 0.75, size.height * 0.86)
      ..lineTo(size.width * 0.6, size.height * 0.9)
      ..close();
    canvas.drawPath(
      runnerPath,
      Paint()..color = const Color(0xFF5A392F),
    );

    final pillowPaint = Paint()..color = const Color(0xFFE8E0D3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.15,
          size.height * 0.55,
          size.width * 0.18,
          size.height * 0.08,
        ),
        const Radius.circular(7),
      ),
      pillowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.34,
          size.height * 0.53,
          size.width * 0.17,
          size.height * 0.08,
        ),
        const Radius.circular(7),
      ),
      pillowPaint..color = const Color(0xFF6B5149),
    );
  }

  void _paintFurniture(Canvas canvas, Size size) {
    final furniturePaint = Paint()..color = const Color(0xFF46322A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.67,
          size.height * 0.57,
          size.width * 0.23,
          size.height * 0.09,
        ),
        const Radius.circular(4),
      ),
      furniturePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.54),
      size.width * 0.055,
      Paint()..color = const Color(0xFFC8B68F),
    );
    canvas.drawLine(
      Offset(size.width * 0.71, size.height * 0.66),
      Offset(size.width * 0.66, size.height * 0.8),
      furniturePaint..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.66),
      Offset(size.width * 0.91, size.height * 0.79),
      furniturePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoomHeroPainter oldDelegate) {
    return false;
  }
}
