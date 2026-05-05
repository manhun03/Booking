import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/strings.dart';

class RoomListScreen extends StatefulWidget {
  final Map<String, dynamic>? hotel;

  const RoomListScreen({Key? key, this.hotel}) : super(key: key);

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
        'name': 'Suite Có Giường Cỏ King',
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
        'name': 'Phòng Deluxe với Giường Cỏ King',
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
    return Scaffold(
      backgroundColor: AppColors.colorBg,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: AppColors.white,
            elevation: 1,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'chọn chỗ ở của bạn',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    '${rooms.length} tùy chọn đã cập nhật hôm qua',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Room Cards
                  ..._buildRoomCards(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoomCards() {
    return List.generate(
      rooms.length,
      (index) => _buildRoomCard(index),
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
                      Text(
                        '✓ Tiện nghi phòng',
                        style: const TextStyle(
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
                      // Handle room selection
                      _showRoomSelectedDialog(room['name']);
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
                Center(
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

  void _showRoomSelectedDialog(String roomName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phòng đã chọn'),
        content: Text('Bạn đã chọn: $roomName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
