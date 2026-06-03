import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class AddPromotionScreen extends StatefulWidget {
  const AddPromotionScreen({super.key});

  @override
  State<AddPromotionScreen> createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _codeController = TextEditingController();

  List<Map<String, dynamic>> _vouchers = const [];
  int? _selectedVoucherIndex;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  num? _amount;
  bool _argumentsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentsLoaded) return;
    _argumentsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final value = args['amount'];
      if (value is num) {
        _amount = value;
      } else if (value is String) {
        _amount = num.tryParse(value);
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _api.restoreSession();
      final vouchers = await _api.fetchCoupons();
      if (!mounted) return;
      setState(() {
        _vouchers = vouchers;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _selectVoucher(int index) {
    setState(() {
      _selectedVoucherIndex = index;
      _codeController.text = _textValue(_vouchers[index], 'code');
    });
  }

  Future<void> _submitPromotion() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showMessage('Vui long nhap hoac chon ma khuyen mai.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final selected = _selectedVoucherIndex == null
          ? _findVoucherByCode(code)
          : _vouchers[_selectedVoucherIndex!];
      final amount = _amount;
      final result = amount == null
          ? <String, dynamic>{
              'code': code,
              'coupon': selected,
              'discountAmount': selected?['discountValue'] ?? 0,
            }
          : await _api.validateCoupon(code: code, amount: amount);
      if (!mounted) return;
      Navigator.of(context).pop({
        ...result,
        'code': result['code'] ?? code,
        'coupon': selected,
      });
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Map<String, dynamic>? _findVoucherByCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final voucher in _vouchers) {
      if (_textValue(voucher, 'code').toUpperCase() == normalized) {
        return voucher;
      }
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      backgroundColor: AppColors.colorBg,
      desktopBody: WebAppShell(
        title: 'Promotion Code',
        subtitle: 'Chon voucher dang hoat dong tu DB hoac nhap ma thu cong.',
        selectedIndex: 2,
        child: _buildDesktopLayout(),
      ),
      mobileBody: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadVouchers,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleRow(context),
                          const SizedBox(height: 18),
                          _buildCodePanel(),
                          const SizedBox(height: 20),
                          _buildVoucherList(),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                  child: _buildSubmitButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 390,
          child: WebPanel(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nhap ma khuyen mai',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ma se duoc kiem tra truc tiep voi backend.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 22),
                _buildCodeField(),
                const SizedBox(height: 18),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: WebPanel(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Voucher dang hoat dong',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadVouchers,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildVoucherList(wide: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhap ma khuyen mai',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _buildCodeField(),
        ],
      ),
    );
  }

  Widget _buildCodeField() {
    return TextField(
      controller: _codeController,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'VD: DEMO10',
        filled: true,
        fillColor: AppColors.colorBg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.colorPrimary),
        ),
      ),
    );
  }

  Widget _buildVoucherList({bool wide = false}) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return _buildStateCard(
        icon: Icons.error_outline,
        title: 'Khong tai duoc voucher',
        message: _error!,
        actionLabel: 'Thu lai',
        onAction: _loadVouchers,
      );
    }
    if (_vouchers.isEmpty) {
      return _buildStateCard(
        icon: Icons.confirmation_number_outlined,
        title: 'Chua co voucher kha dung',
        message: 'Backend hien chua tra ve ma khuyen mai dang hoat dong.',
        actionLabel: 'Tai lai',
        onAction: _loadVouchers,
      );
    }

    if (!wide) {
      return Column(
        children: [
          for (var index = 0; index < _vouchers.length; index++) ...[
            _buildVoucherCard(index),
            if (index < _vouchers.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820 ? 2 : 1;
        final gap = columns == 2 ? 14.0 : 0.0;
        final width = (constraints.maxWidth - gap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 14,
          children: [
            for (var index = 0; index < _vouchers.length; index++)
              SizedBox(width: width, child: _buildVoucherCard(index)),
          ],
        );
      },
    );
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(int index) {
    final voucher = _vouchers[index];
    final colors = _colorsValue(voucher);
    final isSelected = _selectedVoucherIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.colorPrimary : AppColors.divider,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: CustomPaint(
              size: const Size(24, 24),
              painter: _CornerFoldPainter(colors.last),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      _iconValue(voucher),
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _textValue(voucher, 'title'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _textValue(voucher, 'description'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _textValue(voucher, 'code'),
                        style: const TextStyle(
                          color: AppColors.colorPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 68,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _selectVoucher(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isSelected ? 'Da chon' : 'Chon',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitPromotion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _submitting
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Text(
                'Ap dung',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
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
        const SizedBox(width: 28),
        const Expanded(
          child: Center(
            child: Text(
              'Them ma khuyen mai',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 56),
      ],
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

  String _textValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value == null ? '' : value.toString();
  }

  IconData _iconValue(Map<String, dynamic> data) {
    final value = data['icon'];
    return value is IconData ? value : Icons.confirmation_number_outlined;
  }

  List<Color> _colorsValue(Map<String, dynamic> data) {
    final value = data['colors'];
    if (value is List<Color> && value.length >= 2) return value;
    return const [Color(0xFFE9C088), Color(0xFFB95D34)];
  }
}

class _CornerFoldPainter extends CustomPainter {
  const _CornerFoldPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * .58, size.height * .22),
      Offset(size.width * .84, size.height * .48),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerFoldPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
