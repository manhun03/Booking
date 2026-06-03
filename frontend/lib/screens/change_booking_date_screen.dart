import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/availability_date_picker.dart';
import 'widgets/responsive_page.dart';

class ChangeBookingDateScreen extends StatefulWidget {
  const ChangeBookingDateScreen({
    super.key,
    this.booking,
  });

  final Map<String, dynamic>? booking;

  @override
  State<ChangeBookingDateScreen> createState() =>
      _ChangeBookingDateScreenState();
}

class _ChangeBookingDateScreenState extends State<ChangeBookingDateScreen> {
  late DateTime _checkInDate;
  late DateTime _checkOutDate;

  bool _isSaving = false;
  bool _isLoadingAvailability = false;
  String? _errorMessage;
  Map<String, bool> _availabilityByDate = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final fallbackCheckIn = today.add(const Duration(days: 1));
    final parsedCheckIn = _dateOnly(_dateTimeValue(_field('checkInDate')));
    final parsedCheckOut = _dateOnly(_dateTimeValue(_field('checkOutDate')));

    _checkInDate = parsedCheckIn == null || parsedCheckIn.isBefore(today)
        ? fallbackCheckIn
        : parsedCheckIn;
    _checkOutDate =
        parsedCheckOut == null || !parsedCheckOut.isAfter(_checkInDate)
            ? _checkInDate.add(const Duration(days: 1))
            : parsedCheckOut;
    _loadRoomAvailability();
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
        title: 'Thay đổi ngày đặt',
        subtitle:
            'Cập nhật ngày nhận phòng và ngày trả phòng, sau đó gửi yêu cầu duyệt lại về backend.',
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
      const SizedBox(height: 22),
      _buildAvailabilityLegend(),
      const SizedBox(height: 14),
      _buildDateSummary(),
      const SizedBox(height: 22),
      if (!_canChange) _buildInlineMessage('Booking này không thể đổi ngày.'),
      if (_errorMessage != null) _buildInlineMessage(_errorMessage!),
      if (!_canChange || _errorMessage != null) const SizedBox(height: 14),
      _buildSubmitButton(),
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

  Widget _buildDateSummary() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildDateBlock(
              label: 'Nhận phòng',
              date: _formatDate(_checkInDate),
              onTap: _pickCheckInDate,
            ),
          ),
          const VerticalDivider(
            width: 26,
            thickness: 1,
            color: Color(0xFFD8DDE6),
          ),
          Expanded(
            child: _buildDateBlock(
              label: 'Trả phòng',
              date: _formatDate(_checkOutDate),
              onTap: _pickCheckOutDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildLegendItem(
            color: const Color(0xFFE2F8EA),
            borderColor: const Color(0xFF22C55E),
            label: 'Con phong',
          ),
          _buildLegendItem(
            color: const Color(0xFFFFE2E2),
            borderColor: const Color(0xFFEF4444),
            label: 'Het phong',
          ),
          if (_isLoadingAvailability)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateBlock({
    required String label,
    required String date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isSaving || !_canChange ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: AppColors.colorPrimary,
                ),
              ],
            ),
          ],
        ),
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
              onPressed: _isSaving ? null : () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Thay đổi ngày đặt',
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

  Widget _buildInlineMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF3B30),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: _isSaving || !_canChange ? null : _submitChange,
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
        child: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Text(
                'Lưu thay đổi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Future<void> _pickCheckInDate() async {
    final today = _today();
    final selected = await _pickAvailabilityDate(
      initialDate: _checkInDate.isBefore(today) ? today : _checkInDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      title: 'Chon ngay nhan phong',
      isSelectableDate: _isDateAvailable,
    );
    if (selected == null) return;
    setState(() {
      _checkInDate = _dateOnlyValue(selected);
      if (!_checkOutDate.isAfter(_checkInDate) ||
          !_isRangeAvailable(_checkInDate, _checkOutDate)) {
        _checkOutDate = _nextAvailableCheckOut(_checkInDate);
      }
      _errorMessage = null;
    });
  }

  Future<void> _pickCheckOutDate() async {
    final firstDate = _checkInDate.add(const Duration(days: 1));
    final selected = await _pickAvailabilityDate(
      initialDate:
          _checkOutDate.isBefore(firstDate) ? firstDate : _checkOutDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
      title: 'Chon ngay tra phong',
      isSelectableDate: (date) => _isRangeAvailable(_checkInDate, date),
    );
    if (selected == null) return;
    setState(() {
      _checkOutDate = _dateOnlyValue(selected);
      _errorMessage = null;
    });
  }

  Future<void> _loadRoomAvailability() async {
    final roomId = _roomId;
    if (roomId == null || !mounted) return;
    final today = _today();
    setState(() {
      _isLoadingAvailability = true;
    });
    try {
      final availability = await ApiService().fetchRoomAvailability(
        roomId: roomId,
        from: today,
        to: today.add(const Duration(days: 365)),
        excludedBookingId: _bookingId,
      );
      if (!mounted) return;
      setState(() {
        _availabilityByDate = availability;
        _isLoadingAvailability = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _availabilityByDate = {};
        _isLoadingAvailability = false;
      });
    }
  }

  Future<DateTime?> _pickAvailabilityDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required String title,
    bool Function(DateTime date)? isSelectableDate,
  }) async {
    if (_isLoadingAvailability) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dang tai lich trong cua phong...')),
      );
      return null;
    }
    if (_availabilityByDate.isEmpty) {
      await _loadRoomAvailability();
    }
    if (!mounted) return null;
    if (_roomId != null && _availabilityByDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Khong tai duoc lich trong cua phong. Vui long thu lai.'),
        ),
      );
      return null;
    }
    return showDialog<DateTime>(
      context: context,
      builder: (context) => AvailabilityDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        availabilityByDate: _availabilityByDate,
        isSelectableDate: isSelectableDate,
        title: title,
      ),
    );
  }

  bool _isDateAvailable(DateTime date) {
    return _availabilityByDate[_dateKey(date)] ?? true;
  }

  bool _isRangeAvailable(DateTime checkIn, DateTime checkOut) {
    if (!checkOut.isAfter(checkIn)) return false;
    var cursor = _dateOnlyValue(checkIn);
    final end = _dateOnlyValue(checkOut);
    while (cursor.isBefore(end)) {
      if (!_isDateAvailable(cursor)) return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  DateTime _nextAvailableCheckOut(DateTime checkIn) {
    var cursor = _dateOnlyValue(checkIn).add(const Duration(days: 1));
    for (var i = 0; i < 365; i++) {
      if (_isRangeAvailable(checkIn, cursor)) return cursor;
      cursor = cursor.add(const Duration(days: 1));
    }
    return _dateOnlyValue(checkIn).add(const Duration(days: 1));
  }

  Future<void> _submitChange() async {
    final bookingId = _bookingId;
    if (bookingId == null) {
      setState(() {
        _errorMessage = 'Không tìm thấy mã booking để đổi ngày.';
      });
      return;
    }
    if (!_checkOutDate.isAfter(_checkInDate)) {
      setState(() {
        _errorMessage = 'Ngày trả phòng phải sau ngày nhận phòng.';
      });
      return;
    }

    if (!_isRangeAvailable(_checkInDate, _checkOutDate)) {
      setState(() {
        _errorMessage =
            'Khoang ngay da chon co ngay het phong. Vui long chon lai.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ApiService().changeBooking(
        id: bookingId,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi yêu cầu đổi ngày đặt phòng')),
      );
      await Navigator.of(context).pushNamedAndRemoveUntil(
        '/booking',
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isSaving = false;
      });
    }
  }

  bool get _canChange {
    final id = _bookingId;
    if (id == null) return false;
    final status = _statusCode;
    return status != 'CANCELLED' &&
        status != 'COMPLETED' &&
        status != 'CHECKED_OUT' &&
        status != 'REJECTED';
  }

  int? get _bookingId => _intValue(_field('id'));

  int? get _roomId => _intValue(_field('roomId'));

  String get _bookingName =>
      _stringValue(_field('name')) ?? 'Booking #${_bookingId ?? ''}';

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

  DateTime? _dateTimeValue(dynamic value) {
    final text = _stringValue(value);
    return text == null ? null : DateTime.tryParse(text);
  }

  DateTime? _dateOnly(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  DateTime _dateOnlyValue(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
