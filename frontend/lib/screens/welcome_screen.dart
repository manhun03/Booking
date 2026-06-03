import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late List<Map<String, dynamic>> hotels;

  static const List<Map<String, dynamic>> _fallbackHotels = [
    {
      'name': 'Ocean Breeze Hotel',
      'location': 'Đường Trần Hưng Đạo, Nha Trang',
      'rating': '4.7',
      'price': '5,500,000 VND',
      'date': '12 - 14 Thg 12 2026',
      'nights': '2 người, 2 phòng',
      'image': '🏨',
    },
    {
      'name': 'Sunrise Grand Resort',
      'location': '21 Phố Chợ Hoa, Huế',
      'rating': '4.6',
      'price': '2,500,000 VND',
      'date': '09 - 11 Thg 12 2026',
      'nights': '2 người, 2 phòng',
      'image': '🏰',
    },
    {
      'name': 'Emerald Bay Retreat',
      'location': '12 Tôn Đức Thắng, Cửa Lò',
      'rating': '4.8',
      'price': '3,300,000 VND',
      'date': '15 - 17 Thg 01 2026',
      'nights': '2 người, 2 phòng',
      'image': '🏝️',
    },
  ];

  final List<Map<String, dynamic>> benefits = const [
    {
      'icon': Icons.search,
      'title': 'Tìm kiếm dễ dàng',
      'description': 'Lọc điểm đến, giá và tiện ích phù hợp.',
    },
    {
      'icon': Icons.local_offer_outlined,
      'title': 'Ưu đãi tốt',
      'description': 'Cập nhật gói nghỉ dưỡng và khuyến mãi.',
    },
    {
      'icon': Icons.verified_user_outlined,
      'title': 'Thanh toán an toàn',
      'description': 'Thông tin đặt phòng được bảo vệ.',
    },
  ];

  @override
  void initState() {
    super.initState();
    hotels = List<Map<String, dynamic>>.from(_fallbackHotels);
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    try {
      final loadedHotels = await ApiService().fetchHotels(pageSize: 3);
      if (!mounted || loadedHotels.isEmpty) return;
      setState(() {
        hotels = loadedHotels;
      });
    } catch (_) {
      // Keep bundled demo data when the backend is not reachable.
    }
  }

  void _handleSignIn() {
    Navigator.pushNamed(context, '/login');
  }

  void _handleContinueToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: Column(
        children: [
          _buildTopBar(context, compact: true),
          Expanded(
            child: SingleChildScrollView(
              child: _buildMobileContent(context),
            ),
          ),
        ],
      ),
      desktopBody: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 30, 32, 42),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: _buildDesktopContent(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, {bool compact = false}) {
    return Container(
      height: compact ? null : 68,
      color: AppColors.white,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 32,
        vertical: compact ? 12 : 0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StaySmartBrandButton(
                    showLogo: !compact,
                    circleSize: compact ? 32 : 36,
                    iconSize: compact ? 16 : 18,
                    spacing: 8,
                    textStyle: TextStyle(
                      fontSize: compact ? 16 : 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildTopButton(
                label: 'Sign Up',
                filled: false,
                compact: compact,
                onPressed: () => Navigator.pushNamed(context, '/signup'),
              ),
              const SizedBox(width: 8),
              _buildTopButton(
                label: 'Sign In',
                filled: true,
                compact: compact,
                onPressed: _handleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required String label,
    required bool filled,
    required VoidCallback onPressed,
    bool compact = false,
  }) {
    return SizedBox(
      height: compact ? 32 : 34,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
                elevation: 0,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(label, style: const TextStyle(fontSize: 12)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.divider),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildHeroPanel(context, compact: true),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildHotelSection(),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBenefitsSection(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: _buildPromotionPanel(context),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _buildHeroPanel(context),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: _buildBenefitsSection(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _buildHotelSection(),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: _buildPromotionPanel(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeroPanel(BuildContext context, {bool compact = false}) {
    return WebPanel(
      padding: EdgeInsets.all(compact ? 18 : 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đặt phòng dễ dàng, quản lý chuyến đi rõ ràng',
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'StaySmart giúp bạn tìm khách sạn, xem phòng trống, đặt phòng và theo dõi lịch sử trong một trải nghiệm thống nhất.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _handleContinueToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Bắt đầu',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 26),
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.colorPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('🏨', style: TextStyle(fontSize: 86)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHotelSection() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đề xuất cho bạn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Các điểm đến lý tưởng cho kỳ nghỉ tiếp theo',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < hotels.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == hotels.length - 1 ? 0 : 12),
              child: _buildHotelCard(hotels[i]),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.colorPrimary,
                side: const BorderSide(color: AppColors.colorPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _textValue(hotel, 'image', '🏨'),
                style: const TextStyle(fontSize: 38),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _textValue(hotel, 'name', 'StaySmart Hotel'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.star, size: 13, color: Color(0xFFFFC247)),
                    const SizedBox(width: 3),
                    Text(
                      _textValue(hotel, 'rating', '4.7'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _textValue(hotel, 'location', 'Địa điểm'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _textValue(hotel, 'price', '0 VND'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.colorPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_textValue(hotel, 'date', 'Ngày linh hoạt')} · ${_textValue(hotel, 'nights', '1 phòng')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vì sao chọn StaySmart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < benefits.length; i++)
            Padding(
              padding:
                  EdgeInsets.only(bottom: i == benefits.length - 1 ? 0 : 14),
              child: _buildBenefitRow(benefits[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(Map<String, dynamic> benefit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.colorPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _iconValue(benefit, 'icon'),
            size: 20,
            color: AppColors.colorPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _textValue(benefit, 'title', 'Tiện ích'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _textValue(benefit, 'description', ''),
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionPanel(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFBD38D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đi nhiều hơn, ưu đãi nhiều hơn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhận ưu đãi đặt phòng, gói nghỉ dưỡng và thông báo giá tốt khi bạn đăng nhập.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Tham gia ngay',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Text(
            'StaySmart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Copyright © 2026 StaySmart',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _textValue(
    Map<String, dynamic> data,
    String key,
    String fallback,
  ) {
    final value = data[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  IconData _iconValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is IconData ? value : Icons.info_outline;
  }
}
