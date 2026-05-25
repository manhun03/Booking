import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class AddPromotionScreen extends StatefulWidget {
  const AddPromotionScreen({super.key});

  @override
  State<AddPromotionScreen> createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final TextEditingController _codeController = TextEditingController();
  int? _selectedVoucherIndex;

  final List<Map<String, dynamic>> _vouchers = const [
    {
      'code': 'PHUQUOC15',
      'title': 'Bay Phú Quốc siêu tiết kiệm!',
      'description':
          'Ưu đãi 15% khi đặt phòng nghỉ dưỡng biển, áp dụng cho kỳ nghỉ từ 2 đêm.',
      'colors': [Color(0xFF5EC2FF), Color(0xFF0A58B7)],
      'icon': Icons.flight_takeoff,
      'cornerColor': Color(0xFF7364D8),
    },
    {
      'code': 'BIGSALE20',
      'title': 'Tiết kiệm đến 20% cho kỳ nghỉ cuối tuần',
      'description':
          'Tận hưởng ưu đãi đặc biệt cho khách sạn và căn hộ vào thứ sáu, thứ bảy.',
      'colors': [Color(0xFFFFB3C7), Color(0xFFE74C6A)],
      'icon': Icons.local_offer,
      'cornerColor': Color(0xFFFF8A7A),
    },
    {
      'code': 'VIETNAM40',
      'title': 'Giảm giá tại Việt Nam trong thời gian giới hạn',
      'description':
          'Giảm tới 40% cho các điểm lưu trú nổi bật, áp dụng khi thanh toán trên StaySmart.',
      'colors': [Color(0xFFE9C088), Color(0xFFB95D34)],
      'icon': Icons.apartment,
      'cornerColor': Color(0xFFFF8A7A),
    },
    {
      'code': 'NOIDIA25',
      'title': 'Ưu Đãi Nội địa - Giảm đến 25%',
      'description':
          'Tận hưởng giá đặc biệt tại các khách sạn và khu nghỉ dưỡng địa phương.',
      'colors': [Color(0xFF1FAA59), Color(0xFF74C67A)],
      'icon': Icons.location_on,
      'cornerColor': Color(0xFFFF8A7A),
    },
  ];

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _selectVoucher(int index) {
    setState(() {
      _selectedVoucherIndex = index;
      _codeController.text = _vouchers[index]['code'] as String;
    });
  }

  void _submitPromotion() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập hoặc chọn mã khuyến mãi')),
      );
      return;
    }

    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      backgroundColor: AppColors.colorBg,
      desktopBody: WebAppShell(
        title: 'Promotion Code',
        subtitle: 'Apply a voucher or enter a promo code for this booking.',
        selectedIndex: 2,
        child: _buildDesktopLayout(),
      ),
      mobileBody: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleRow(context),
                        const SizedBox(height: 18),
                        const Text(
                          'Nhập mã khuyến mãi',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCodeField(),
                        const SizedBox(height: 32),
                        for (var index = 0; index < _vouchers.length; index++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _vouchers.length - 1 ? 0 : 18,
                            ),
                            child: _buildVoucherCard(index),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 18),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitPromotion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.colorPrimary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Thêm',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380,
          child: WebPanel(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Promo code',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a voucher or enter a code manually.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Code',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCodeField(),
                const SizedBox(height: 24),
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
                const Text(
                  'Available vouchers',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                for (var index = 0; index < _vouchers.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _vouchers.length - 1 ? 0 : 18,
                    ),
                    child: _buildVoucherCard(index),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _submitPromotion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text(
          'ThÃªm',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
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
              'Thêm mã khuyến mãi',
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

  Widget _buildCodeField() {
    return TextField(
      controller: _codeController,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.colorBg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.iconMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.colorPrimary),
        ),
      ),
    );
  }

  Widget _buildVoucherCard(int index) {
    final voucher = _vouchers[index];
    final colors = voucher['colors'] as List<Color>;
    final isSelected = _selectedVoucherIndex == index;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.colorPrimary : Colors.transparent,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
              size: const Size(20, 20),
              painter: _CornerFoldPainter(voucher['cornerColor'] as Color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      voucher['icon'] as IconData,
                      color: AppColors.white,
                      size: 27,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          voucher['title'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          voucher['description'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 8.5,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 58,
                  width: 1,
                  child: CustomPaint(painter: _DashedLinePainter()),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 52,
                  height: 28,
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
                      isSelected ? 'Đã chọn' : 'Chọn',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
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

  Widget _buildBellButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/notification'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 22,
            color: AppColors.textPrimary,
          ),
          Positioned(
            right: -2,
            top: -4,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAvatar({required double size}) {
    return CurrentUserAvatar(size: size);
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.iconMuted
      ..strokeWidth = 1;
    const dashHeight = 4.0;
    const dashGap = 4.0;
    var y = 0.0;

    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
