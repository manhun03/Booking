import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({Key? key, this.hotel}) : super(key: key);

  final Map<String, dynamic>? hotel;

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late List<Map<String, dynamic>> rooms;

  @override
  void initState() {
    super.initState();
    _initializeRooms();
  }

  void _initializeRooms() {
    rooms = [
      {
        'name': 'Phòng Superieur với Giường Cỏ King',
        'type': '1 giường đơn',
        'image': '🏨',
        'amenities': [
          {'name': 'Đặt giường đôi', 'icon': '🛏️'},
          {'name': 'Phòng tắm riêng', 'icon': '🚿'},
          {'name': 'Phòng tắm công cộng', 'icon': '🚪'},
          {'name': 'WiFi miễn phí', 'icon': '📶'},
        ],
        'policies': [
          '🚫 Không được hủy miễn phí - Thanh toán khi đặt phòng',
          '✓ Có thể hủy (hoàn tiền toàn bộ nếu hủy trước 14:00)',
        ],
        'price': 11934235,
        'oldPrice': 13241450,
        'selected': false,
      },
      {
        'name': 'Suite Có Giường Cỡ King',
        'type': '1 giường đôi',
        'image': '🏨',
        'amenities': [
          {'name': 'Đặt giường đôi', 'icon': '🛏️'},
          {'name': 'Phòng tắm riêng', 'icon': '🚿'},
          {'name': 'TV Có Cáp vệ tinh', 'icon': '📺'},
          {'name': 'WiFi miễn phí', 'icon': '📶'},
        ],
        'policies': [
          '🚫 Không được hủy miễn phí - Thanh toán khi đặt phòng',
          '✓ Có thể hủy (hoàn tiền toàn bộ nếu hủy trước 14:00)',
        ],
        'price': 7034235,
        'oldPrice': 7260450,
        'selected': false,
      },
      {
        'name': 'Phòng Deluxe với Giường Cỡ King',
        'type': '1 giường đôi',
        'image': '🏨',
        'amenities': [
          {'name': 'Đặt giường đôi', 'icon': '🛏️'},
          {'name': 'Phòng tắm riêng', 'icon': '🚿'},
          {'name': 'TV Có Cáp vệ tinh', 'icon': '📺'},
          {'name': 'WiFi miễn phí', 'icon': '📶'},
        ],
        'policies': [
          '🚫 Không được hủy miễn phí - Thanh toán khi đặt phòng',
          '✓ Có thể hủy (hoàn tiền toàn bộ nếu hủy trước 14:00)',
        ],
        'price': 7034235,
        'oldPrice': 7260450,
        'selected': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionHeader(),
                  const SizedBox(height: 16),
                  ..._buildRoomCards(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSidebar('📢', 'Quảng cáo'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSidebar('🎁', 'Ưu đãi đặc biệt'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      desktopBody: _buildDesktopPage(),
    );
  }

  Widget _buildDesktopPage() {
    return WebAppShell(
      title: 'Chọn phòng',
      subtitle:
          'So sánh loại phòng, tiện nghi, chính sách hủy và giá trước khi tiếp tục đặt phòng.',
      selectedIndex: 3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: Column(
              children: [
                _buildSelectionHeader(),
                const SizedBox(height: 16),
                WebPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tóm tắt lựa chọn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDesktopMetric(
                        Icons.king_bed_outlined,
                        '${rooms.length} loại phòng',
                      ),
                      const SizedBox(height: 10),
                      _buildDesktopMetric(
                        Icons.payments_outlined,
                        'Thanh toán linh hoạt',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(children: _buildRoomCards()),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMetric(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.colorPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ch\u1ECDn ch\u1ED7 c\u1EE7a b\u1EA1n',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '27 thg 9 - 30 thg 9',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gi\u00E1 \u0111\u00E3 \u0111\u01B0\u1EE3c \u0111\u1ED5i v\u1EDBi m\u1ED9t VND \u24D8',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
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

  List<Widget> _buildRoomCards() {
    return List.generate(
      rooms.length,
      _buildRoomCard,
    );
  }

  Widget _buildRoomCard(int index) {
    final room = rooms[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: room['selected'] ? AppColors.colorPrimary : AppColors.divider,
          width: room['selected'] ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Header with Selection Checkbox
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      room['selected'] = !room['selected'];
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: room['selected']
                            ? AppColors.colorPrimary
                            : AppColors.divider,
                        width: 2,
                      ),
                      color: room['selected']
                          ? AppColors.colorPrimary
                          : AppColors.white,
                    ),
                    child: room['selected']
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        room['type'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Room Image and Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.colorBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      room['image'],
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Amenities
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✓ Tiện nghi phòng',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        (room['amenities'] as List).length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${room['amenities'][i]['icon']} ${room['amenities'][i]['name']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Policies
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(
                  (room['policies'] as List).length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      room['policies'][i],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Price and Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatPrice(room['price'])} VNĐ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.colorPrimary,
                            ),
                          ),
                          if (room['oldPrice'] != null)
                            Text(
                              '${_formatPrice(room['oldPrice'])} (cũ)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Choose Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to room detail screen
                      Navigator.pushNamed(
                        context,
                        '/room-detail',
                        arguments: {
                          'room': room,
                          'hotel': widget.hotel,
                        },
                      );
                    },
                    child: const Text(
                      'Chọn',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // EasyStay Link
                const Center(
                  child: Text(
                    'Chi tiết 2 phòng trên EasyStay.com',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.colorPrimary,
                      decoration: TextDecoration.underline,
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
