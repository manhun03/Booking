import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    this.room,
    this.hotel,
    this.roomCount = 1,
  });

  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;
  final int roomCount;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  int? _resolvedUnitPrice;
  bool _isRefreshingPrice = false;

  bool _saveInfo = false;
  String? _selectedCountry;
  String _tripPurpose = 'work';

  final List<String> _countries = const [
    'Việt Nam',
    'Hoa Kỳ',
    'Hàn Quốc',
    'Nhật Bản',
    'Singapore',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _checkInDate = DateTime(now.year, now.month, now.day + 1);
    _checkOutDate = DateTime(now.year, now.month, now.day + 2);
    _resolvedUnitPrice = _asInt(widget.room?['price']);
    _prefillCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRoomPrice());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _prefillCurrentUser() {
    final session = ApiService().currentSession;
    final cachedUser = ApiService().cachedUser;
    final fullName =
        (cachedUser?['fullName'] ?? session?.fullName)?.toString().trim();

    if (fullName != null && fullName.isNotEmpty) {
      final parts = fullName.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        _firstNameController.text = parts.first;
      } else {
        _firstNameController.text = parts.last;
        _lastNameController.text = parts.take(parts.length - 1).join(' ');
      }
    }

    final email = (cachedUser?['email'] ?? session?.email)?.toString().trim();
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }

    final phone = cachedUser?['phone']?.toString().trim();
    if (phone != null && phone.isNotEmpty) {
      _phoneController.text = phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      backgroundColor: AppColors.colorBg,
      mobileBody: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: _buildMobileForm(context),
      ),
      desktopBody: WebAppShell(
        title: 'Booking Information',
        subtitle:
            'Nhap thong tin khach hang, xac nhan muc dich chuyen di va kiem tra tong tien truoc khi thanh toan.',
        selectedIndex: 2,
        child: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 14),
          _buildFormFields(),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          _buildPriceSummary(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: WebPanel(child: _buildFormFields()),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 360,
            child: Column(
              children: [
                WebPanel(child: _buildDesktopSummary()),
                const SizedBox(height: 16),
                _buildSubmitButton(height: 46),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Ten',
          controller: _firstNameController,
          validator: (value) => _required(value, 'ten'),
        ),
        _buildTextField(
          label: 'Ho',
          controller: _lastNameController,
          validator: (value) => _required(value, 'ho'),
        ),
        _buildTextField(
          label: 'Dia chi email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        _buildCountryField(),
        _buildTextField(
          label: 'Dien thoai',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),
        _buildDateFields(),
        const SizedBox(height: 4),
        _buildSaveInfoToggle(),
        const SizedBox(height: 18),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 14),
        _buildTripPurpose(),
      ],
    );
  }

  Widget _buildDesktopSummary() {
    final hotelName = _stringValue(widget.hotel?['name'], 'Khach san');
    final roomName = _stringValue(widget.room?['name'], 'Phong da chon');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tom tat dat phong',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildSummaryLine(Icons.apartment_outlined, hotelName),
        const SizedBox(height: 12),
        _buildSummaryLine(Icons.king_bed_outlined, roomName),
        const SizedBox(height: 12),
        _buildSummaryLine(Icons.meeting_room_outlined, '1 phong'),
        const SizedBox(height: 12),
        _buildSummaryLine(Icons.calendar_month_outlined, '$_nightCount dem'),
        const SizedBox(height: 18),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 16),
        _buildPriceSummary(),
      ],
    );
  }

  Widget _buildSummaryLine(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.colorPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton({double height = 44}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Buoc tiep theo',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Điền thông tin của bạn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredLabel(label),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            decoration: _inputDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredLabel('Vùng/quốc gia'),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _selectedCountry,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textSecondary,
            ),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            decoration: _inputDecoration(),
            items: _countries
                .map(
                  (country) => DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng chọn vùng/quốc gia';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateFields() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildDateButton(
              label: 'Ngay nhan phong',
              value: _formatDate(_checkInDate),
              onTap: _pickCheckInDate,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDateButton(
              label: 'Ngay tra phong',
              value: _formatDate(_checkOutDate),
              onTap: _pickCheckOutDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(label),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(2),
          child: InputDecorator(
            decoration: _inputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveInfoToggle() {
    return InkWell(
      onTap: () {
        setState(() {
          _saveInfo = !_saveInfo;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: _saveInfo,
              onChanged: (value) {
                setState(() {
                  _saveInfo = value ?? false;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              side: const BorderSide(color: AppColors.textSecondary, width: 1),
              activeColor: AppColors.colorPrimary,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Lưu thông tin của bạn cho các lần đặt phòng tương lai',
              style: TextStyle(
                fontSize: 10,
                height: 1.25,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripPurpose() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mục đích chuyến đi của bạn là gì ?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: _tripPurpose,
          onChanged: (selected) {
            if (selected == null) return;
            setState(() {
              _tripPurpose = selected;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPurposeOption(value: 'leisure', label: 'Giải trí'),
              const SizedBox(height: 4),
              _buildPurposeOption(value: 'work', label: 'Công việc'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurposeOption({
    required String value,
    required String label,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _tripPurpose = value;
        });
      },
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Radio<String>(
              value: value,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              activeColor: AppColors.colorPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_formatPrice(_totalPrice)} VND',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Đã bao gồm thuế và phí',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textPrimary,
          ),
        ),
        if (_isRefreshingPrice) ...[
          const SizedBox(height: 8),
          const Text(
            'Dang cap nhat gia theo ngay da chon...',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      filled: true,
      fillColor: AppColors.colorBg,
      errorStyle: const TextStyle(fontSize: 10, height: 1.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: Color(0xFFBAC1CC), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: Color(0xFFBAC1CC), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: AppColors.colorPrimary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  int get _totalPrice {
    final price = _resolvedUnitPrice ?? _asInt(widget.room?['price']) ?? 179000;
    final taxAndFee = _asInt(widget.room?['taxAndFee']) ?? 0;
    return (price + taxAndFee) * _nightCount;
  }

  int get _nightCount {
    final days = _checkOutDate.difference(_checkInDate).inDays;
    return days < 1 ? 1 : days;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    return null;
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

  String _stringValue(dynamic value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final requiredMessage = _required(value, 'email');
    if (requiredMessage != null) return requiredMessage;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final requiredMessage = _required(value, 'số điện thoại');
    if (requiredMessage != null) return requiredMessage;

    final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  Future<void> _refreshRoomPrice() async {
    final roomId = _asInt(widget.room?['id']);
    if (roomId == null || !mounted) return;
    setState(() {
      _isRefreshingPrice = true;
    });
    try {
      final price = await ApiService().fetchRoomPriceForDates(
        roomId: roomId,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
      );
      if (!mounted) return;
      setState(() {
        _resolvedUnitPrice = price ?? _asInt(widget.room?['price']);
        _isRefreshingPrice = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resolvedUnitPrice = _asInt(widget.room?['price']);
        _isRefreshingPrice = false;
      });
    }
  }

  Future<void> _pickCheckInDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: _checkInDate.isBefore(today) ? today : _checkInDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (selected == null) return;
    setState(() {
      _checkInDate = DateTime(selected.year, selected.month, selected.day);
      if (!_checkOutDate.isAfter(_checkInDate)) {
        _checkOutDate = _checkInDate.add(const Duration(days: 1));
      }
    });
    await _refreshRoomPrice();
  }

  Future<void> _pickCheckOutDate() async {
    final firstDate = _checkInDate.add(const Duration(days: 1));
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _checkOutDate.isBefore(firstDate) ? firstDate : _checkOutDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
    );
    if (selected == null) return;
    setState(() {
      _checkOutDate = DateTime(selected.year, selected.month, selected.day);
    });
    await _refreshRoomPrice();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushNamed(
      context,
      '/payment-information',
      arguments: {
        'room': {
          ...?widget.room,
          if (_resolvedUnitPrice != null) 'price': _resolvedUnitPrice,
        },
        'hotel': widget.hotel,
        'roomCount': widget.roomCount,
        'checkInDate': _checkInDate,
        'checkOutDate': _checkOutDate,
        'customer': {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'country': _selectedCountry,
          'phone': _phoneController.text.trim(),
          'saveInfo': _saveInfo,
          'tripPurpose': _tripPurpose,
        },
      },
    );
  }
}
