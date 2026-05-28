import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class ReviewBookingScreen extends StatefulWidget {
  const ReviewBookingScreen({
    super.key,
    this.booking,
  });

  final Map<String, dynamic>? booking;

  @override
  State<ReviewBookingScreen> createState() => _ReviewBookingScreenState();
}

class _ReviewBookingScreenState extends State<ReviewBookingScreen> {
  final TextEditingController _commentController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(_buildContent()),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: 'Đánh giá khách sạn',
        subtitle: 'Chia sẻ đánh giá cho kỳ lưu trú đã hoàn tất.',
        selectedIndex: 2,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: WebPanel(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      _buildBookingSummary(),
      const SizedBox(height: 24),
      if (_alreadyReviewed)
        _buildMessage(
          icon: Icons.check_circle_outline,
          text: 'Bạn đã đánh giá kỳ lưu trú này.',
          color: const Color(0xFF15803D),
        )
      else if (!_canReview)
        _buildMessage(
          icon: Icons.info_outline,
          text: 'Chỉ booking đã hoàn tất mới có thể đánh giá.',
          color: const Color(0xFFD97706),
        )
      else ...[
        const Text(
          'Mức độ hài lòng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildRatingSelector(),
        const SizedBox(height: 20),
        TextField(
          controller: _commentController,
          enabled: !_isSubmitting,
          minLines: 4,
          maxLines: 6,
          maxLength: 1000,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            labelText: 'Nhận xét (không bắt buộc)',
            alignLabelWithHint: true,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.colorPrimary),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF3B30),
            ),
          ),
        ],
        const SizedBox(height: 18),
        _buildSubmitButton(),
      ],
    ];
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
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Đánh giá khách sạn',
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

  Widget _buildBookingSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _bookingDate,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
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

  Widget _buildRatingSelector() {
    return Row(
      children: [
        for (var value = 1; value <= 5; value++)
          Tooltip(
            message: '$value sao',
            child: IconButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _rating = value;
                        _errorMessage = null;
                      });
                    },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 42,
                height: 42,
              ),
              icon: Icon(
                value <= _rating ? Icons.star : Icons.star_border,
                size: 34,
                color: const Color(0xFFFFB703),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          _rating == 0 ? 'Chưa chọn' : '$_rating/5',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting || _rating == 0 ? null : _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: const Color(0xFFB8C0CC),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.rate_review_outlined, size: 18),
        label: Text(
          _isSubmitting ? 'Đang gửi...' : 'Gửi đánh giá',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    final bookingId = _bookingId;
    if (bookingId == null || !_canReview) {
      setState(() {
        _errorMessage = 'Booking này chưa đủ điều kiện để đánh giá.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final review = await ApiService().createReview(
        bookingId: bookingId,
        rating: _rating,
        comment: _commentController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đánh giá khách sạn')),
      );
      Navigator.of(context).pop(review);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.toString();
      });
    }
  }

  bool get _alreadyReviewed => _field('reviewed') == true;

  bool get _canReview {
    final status = _statusCode;
    return _bookingId != null &&
        (status == 'COMPLETED' || status == 'CHECKED_OUT');
  }

  int? get _bookingId => _intValue(_field('id'));

  String get _bookingName =>
      _stringValue(_field('name')) ?? 'Booking #${_bookingId ?? ''}';

  String get _bookingDate =>
      _stringValue(_field('detailDate')) ??
      _stringValue(_field('date')) ??
      'Đang cập nhật ngày lưu trú';

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
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
