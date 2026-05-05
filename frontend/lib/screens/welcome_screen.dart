import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/strings.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<Map<String, dynamic>> hotels = [
    {
      'name': 'Ocean Breeze Hotel',
      'location': 'Đường Trần Hưng Đạo, Nha Trang',
      'rating': 4.7,
      'price': '5,500,000 VND',
      'date': '12 - 14 Thg 12 2026',
      'nights': '2 Người đêm (2 phòng)',
      'image': '🏨',
    },
    {
      'name': 'Sunrise Grand Resort',
      'location': '21 Phố Chợ Hoa, Huế, Huế',
      'rating': 4.6,
      'price': '2,500,000 VND',
      'date': '09 - 09 Thg 12 2026',
      'nights': '2 Người đêm (2 phòng)',
      'image': '🏰',
    },
    {
      'name': 'Emerald Bay Retreat',
      'location': '12 Tôn Đức Thắng, Cửa Lò, Cửa Lò',
      'rating': 4.8,
      'price': '3,300,000 VND',
      'date': '15 - 17 Thg 01 2026',
      'nights': 'Khách 2 Người đêm (2 phòng)',
      'image': '🏝️',
    },
  ];

  final List<Map<String, dynamic>> benefits = [
    {
      'icon': '🔍',
      'title': 'Tìm kiếm dễ dàng',
      'description': 'Tìm khách sạn phù hợp',
    },
    {
      'icon': '🎁',
      'title': 'Ưu đãi tốt',
      'description': 'Giá tốt mỗi ngày',
    },
    {
      'icon': '💳',
      'title': 'Thanh toán an toàn',
      'description': 'Bảo mật cao cấp',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top App Bar with buttons
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HotelBooking',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colorPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                final body = Column(
                  children: [
            // Promotional Banner
            Container(
              color: AppColors.colorPrimary,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HB',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'HotelBooking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Đặt phòng dễ dàng\nLưu lương chất lượng',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '🏨',
                        style: TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Suggestions Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đề xuất cho bạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Các điểm đến lý tưởng cho bạn',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppColors.divider, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  hotel['image'],
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          hotel['name'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '⭐ ${hotel['rating']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '📍 ${hotel['location']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '💰 ${hotel['price']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '📅 ${hotel['date']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '🛏️ ${hotel['nights']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.colorPrimary,
                        ),
                      ),
                      child: const Text(
                        'Xem tất cả',
                        style: TextStyle(
                          color: AppColors.colorPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Why Choose Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vì sao lại chọn HotelBooking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: benefits
                        .map((benefit) => Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Text(
                                      benefit['icon'],
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      benefit['title'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      benefit['description'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Promotion Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đi nhiều hơn, ưu đãi nhiều hơn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Những chương trình ưu đãi cực hấp dẫn, nhận được ngay khi bạn đồng ý tham gia',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Text(
                        '🎉',
                        style: const TextStyle(fontSize: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text(
                      'Tham gia ngay',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

                  ],
                );

                if (!isDesktop) {
                  return Column(
                    children: [
                      body,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSidebar(
                                '\u{1F4E2}',
                                'Qu\u1EA3ng c\u00E1o',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSidebar(
                                '\u{1F381}',
                                '\u01AFu \u0111\u00E3i \u0111\u1EB7c bi\u1EC7t',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * 0.2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                        child: _buildSidebar('\u{1F4E2}', 'Qu\u1EA3ng c\u00E1o'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: body),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: constraints.maxWidth * 0.2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                        child: _buildSidebar(
                          '\u{1F381}',
                          '\u01AFu \u0111\u00E3i \u0111\u1EB7c bi\u1EC7t',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Footer
            Container(
              color: AppColors.textPrimary,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'HotelBooking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon('f'),
                      const SizedBox(width: 16),
                      _buildSocialIcon('📧'),
                      const SizedBox(width: 16),
                      _buildSocialIcon('🐦'),
                      const SizedBox(width: 16),
                      _buildSocialIcon('📱'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Copyright © 2026 HotelBooking',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white24,
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildSidebar(String icon, String label) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 300;
        final containerHeight = isCompact ? 80.0 : 100.0;
        final fontSize = isCompact ? 28.0 : 36.0;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: containerHeight,
                decoration: BoxDecoration(
                  color: AppColors.colorBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
