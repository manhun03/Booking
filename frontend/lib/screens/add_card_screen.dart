import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final ApiService _api = ApiService();
  int _selectedIndex = 4;
  bool _saving = false;
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiredController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_refreshPreview);
    _cardHolderController.addListener(_refreshPreview);
    _expiredController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiredController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  Future<void> _submitCard() async {
    if (_saving) return;

    final cardNumber = _cardNumberController.text.trim();
    final cardHolder = _cardHolderController.text.trim();
    final expiry = _expiredController.text.trim();
    final cvv = _cvvController.text.trim();
    final digits = _digitsOnly(cardNumber);

    if (digits.length < 12 || digits.length > 19) {
      _showError('So the phai co tu 12 den 19 chu so.');
      return;
    }
    if (cardHolder.isEmpty) {
      _showError('Vui long nhap ten chu the.');
      return;
    }
    if (!_isValidExpiry(expiry)) {
      _showError('Ngay het han phai dung dinh dang MM/YY.');
      return;
    }
    if (cvv.isNotEmpty && !_isValidCvv(cvv)) {
      _showError('CVV phai co 3 hoac 4 chu so.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _api.restoreSession();
      await _api.addPaymentCard(
        cardNumber: cardNumber,
        cardHolderName: cardHolder,
        expiry: expiry,
        brand: _detectBrand(digits),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
              child: _buildMobileContent(context),
            ),
          ),
        ],
      ),
      desktopBody: _buildDesktopPage(context),
      mobileBottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDesktopPage(BuildContext context) {
    return WebAppShell(
      title: 'Add New Card',
      subtitle:
          'Them the thanh toan moi vao tai khoan. Backend chi luu metadata an toan, khong luu CVV.',
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final previewPanel = WebPanel(child: _buildPreviewPanel());
          final formPanel = WebPanel(child: _buildCardForm(context, web: true));

          if (stackPanels) {
            return Column(
              children: [
                previewPanel,
                const SizedBox(height: 18),
                formPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 360, child: previewPanel),
              const SizedBox(width: 24),
              Expanded(child: formPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context),
        const SizedBox(height: 22),
        Center(child: _buildPreviewCard()),
        const SizedBox(height: 34),
        _buildCardForm(context),
      ],
    );
  }

  Widget _buildPreviewPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card preview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Preview cap nhat theo thong tin dang nhap.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 22),
        Center(child: _buildPreviewCard(width: 316, height: 194)),
        const SizedBox(height: 20),
        _buildSecurityNotice(),
      ],
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.colorPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.colorPrimary.withValues(alpha: 0.16)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: AppColors.colorPrimary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Backend chi luu brand, 4 so cuoi, ngay het han va ten chu the. CVV khong duoc luu vao DB.',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm(BuildContext context, {bool web = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (web) ...[
          const Text(
            'Thong tin the',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
        ],
        _buildLabeledField(
          'Card Number',
          _cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
            LengthLimitingTextInputFormatter(23),
          ],
        ),
        const SizedBox(height: 18),
        _buildLabeledField('Card Holder Name', _cardHolderController),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _buildLabeledField(
                'Expired',
                _expiredController,
                hintText: 'MM/YY',
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLabeledField(
                'CVV Code',
                _cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _saving ? null : _submitCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text(
                    'Them',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const StaySmartBrandButton(),
          const Spacer(),
          _buildBellButton(context),
          const SizedBox(width: 18),
          const Icon(
            Icons.settings_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/user-profile'),
            child: _buildAvatar(size: 34),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
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
        const SizedBox(width: 40),
        const Expanded(
          child: Center(
            child: Text(
              'Add New Card',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
      ],
    );
  }

  Widget _buildPreviewCard({double width = 292, double height = 180}) {
    final digits = _digitsOnly(_cardNumberController.text);
    final brand = _detectBrand(digits);
    final holder = _cardHolderController.text.trim().isEmpty
        ? 'CARDHOLDER'
        : _cardHolderController.text.trim().toUpperCase();
    final expiry = _expiredController.text.trim().isEmpty
        ? 'MM/YY'
        : _expiredController.text.trim();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF201A59),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              brand,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.credit_card, color: Color(0xFFD7D5FF), size: 40),
          const SizedBox(height: 12),
          Text(
            _maskedCardNumber(digits),
            style: const TextStyle(
              color: Color(0xFFD7D5FF),
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            expiry,
            style: const TextStyle(color: AppColors.white, fontSize: 9),
          ),
          const Spacer(),
          Text(
            holder,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller, {
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
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
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  Widget _buildBellButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/notification'),
      child: const Icon(
        Icons.notifications_none,
        size: 22,
        color: AppColors.textPrimary,
      ),
    );
  }

  static Widget _buildAvatar({required double size}) {
    return CurrentUserAvatar(size: size);
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _maskedCardNumber(String digits) {
    final last4 =
        digits.length >= 4 ? digits.substring(digits.length - 4) : '0000';
    return '**** **** **** $last4';
  }

  String _detectBrand(String digits) {
    if (digits.startsWith('4')) return 'VISA';
    if (digits.startsWith('34') || digits.startsWith('37')) return 'AMEX';
    if (digits.startsWith('35')) return 'JCB';
    final prefix2 =
        digits.length >= 2 ? int.tryParse(digits.substring(0, 2)) : null;
    final prefix4 =
        digits.length >= 4 ? int.tryParse(digits.substring(0, 4)) : null;
    if ((prefix2 != null && prefix2 >= 51 && prefix2 <= 55) ||
        (prefix4 != null && prefix4 >= 2221 && prefix4 <= 2720)) {
      return 'MASTERCARD';
    }
    return 'CARD';
  }

  bool _isValidExpiry(String value) {
    final match = RegExp(r'^(\d{1,2})/(\d{2})$').firstMatch(value.trim());
    if (match == null) return false;
    final month = int.tryParse(match.group(1) ?? '');
    final year = int.tryParse(match.group(2) ?? '');
    if (month == null || year == null || month < 1 || month > 12) {
      return false;
    }
    final fullYear = 2000 + year;
    final now = DateTime.now();
    final expiryEnd = DateTime(fullYear, month + 1, 0, 23, 59, 59);
    return expiryEnd.isAfter(now);
  }

  bool _isValidCvv(String value) {
    return RegExp(r'^\d{3,4}$').hasMatch(value.trim());
  }
}
