import 'package:flutter/material.dart';

import '../utils/colors.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    Key? key,
    this.room,
    this.hotel,
    this.roomCount = 1,
  }) : super(key: key);

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
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBg,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 14),
                    _buildTextField(
                      label: 'Tên',
                      controller: _firstNameController,
                      validator: (value) => _required(value, 'tên'),
                    ),
                    _buildTextField(
                      label: 'Họ',
                      controller: _lastNameController,
                      validator: (value) => _required(value, 'họ'),
                    ),
                    _buildTextField(
                      label: 'Địa chỉ email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    _buildCountryField(),
                    _buildTextField(
                      label: 'Điện thoại',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 4),
                    _buildSaveInfoToggle(),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 14),
                    _buildTripPurpose(),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 14),
                    _buildPriceSummary(),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
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
                            'Bước tiếp theo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    final price = _asInt(widget.room?['price']) ?? 179000;
    final taxAndFee = _asInt(widget.room?['taxAndFee']) ?? 0;
    return (price * widget.roomCount) + taxAndFee;
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

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushNamed(
      context,
      '/payment-information',
      arguments: {
        'room': widget.room,
        'hotel': widget.hotel,
        'roomCount': widget.roomCount,
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
