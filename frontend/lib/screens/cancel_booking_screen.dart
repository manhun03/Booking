import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({
    super.key,
    this.booking,
  });

  final Map<String, dynamic>? booking;

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final TextEditingController _reasonController = TextEditingController();

  bool _isCancelling = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(40, 12, 40, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(_buildContent(context)),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: 'Hủy đặt phòng',
        subtitle:
            'Xác nhận hủy toàn bộ phòng trong đơn và gửi lý do hủy về backend.',
        selectedIndex: 2,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: WebPanel(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    return [
      _buildBookingSummary(),
      const SizedBox(height: 18),
      const Text(
        'Bạn sẽ hủy toàn bộ phòng đã đặt khi bấm nút xác nhận hủy. Thao tác này sẽ cập nhật trạng thái booking trên backend.',
        style: TextStyle(
          fontSize: 14,
          height: 1.28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 18),
      TextField(
        controller: _reasonController,
        minLines: 3,
        maxLines: 4,
        enabled: !_isCancelling && _canCancel,
        decoration: InputDecoration(
          labelText: 'Lý do hủy (không bắt buộc)',
          alignLabelWithHint: true,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.colorPrimary),
          ),
        ),
      ),
      if (_errorMessage != null) ...[
        const SizedBox(height: 12),
        Text(
          _errorMessage!,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF3B30),
          ),
        ),
      ],
      const SizedBox(height: 24),
      _buildConfirmButton(context),
    ];
  }

  Widget _buildBookingSummary() {
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
          Text(
            _bookingName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _bookingDate,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trạng thái: $_statusText',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
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
              onPressed: _isCancelling ? null : () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Hủy đặt phòng',
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

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: _isCancelling || !_canCancel ? null : _cancelBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: const Color(0xFFB8C0CC),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _isCancelling
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Text(
                'Xác nhận hủy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Future<void> _cancelBooking() async {
    final bookingId = _bookingId;
    if (bookingId == null) {
      setState(() {
        _errorMessage = 'Không tìm thấy mã booking để hủy.';
      });
      return;
    }

    setState(() {
      _isCancelling = true;
      _errorMessage = null;
    });

    try {
      await ApiService().cancelBooking(
        id: bookingId,
        reason: _reasonController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy đặt phòng')),
      );
      await Navigator.of(context).pushNamedAndRemoveUntil(
        '/booking',
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isCancelling = false;
      });
    }
  }

  bool get _canCancel {
    final id = _bookingId;
    if (id == null) return false;
    final status = _statusCode;
    return status != 'CANCELLED' &&
        status != 'COMPLETED' &&
        status != 'CHECKED_OUT' &&
        status != 'REJECTED';
  }

  int? get _bookingId => _intValue(_field('id'));

  String get _bookingName =>
      _stringValue(_field('name')) ?? 'Booking #${_bookingId ?? ''}';

  String get _bookingDate =>
      _stringValue(_field('detailDate')) ??
      _stringValue(_field('date')) ??
      'Đang cập nhật ngày';

  String get _statusText =>
      _stringValue(_field('status')) ?? 'Đang cập nhật trạng thái';

  String get _statusCode => (_stringValue(_field('statusCode')) ??
          _stringValue(_field('status')) ??
          '')
      .toUpperCase();

  dynamic _field(String key) {
    final value = widget.booking?[key];
    if (value != null) return value;
    final backend = widget.booking?['backend'];
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

  String? _stringValue(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
