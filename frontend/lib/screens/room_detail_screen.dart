import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RoomDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;

  const RoomDetailScreen({Key? key, this.room, this.hotel}) : super(key: key);

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Map<String, dynamic> roomData;
  int roomCount = 1;

  @override
  void initState() {
    super.initState();
    roomData = widget.room ?? defaultRoom;
  }

  final Map<String, dynamic> defaultRoom = {
    'name': 'Phòng Superieur Có Giường Cỏ King',
    'type': '1 giường đôi',
    'image': '🏨',
    'amenities': [
      {'name': 'Đặt giường đôi', 'icon': '🛏️'},
      {'name': 'Phòng tắm riêng', 'icon': '🚿'},
      {'name': 'Phòng tắm công cộng', 'icon': '🚪'},
      {'name': 'WiFi miễn phí', 'icon': '📶'},
      {'name': 'TV Có Cáp vệ tinh', 'icon': '📺'},
      {'name': 'Điều hòa không khí', 'icon': '❄️'},
    ],
    'policies': [
      '🚫 Không được hủy miễn phí - Thanh toán khi đặt phòng',
      '✓ Có thể hủy (hoàn tiền toàn bộ nếu hủy trước 14:00)',
    ],
    'price': 11934235,
    'oldPrice': 13241450,
    'description':
        'Phòng rộng rãi với đầy đủ tiện nghi hiện đại, phù hợp cho du khách công vụ và gia đình nhỏ.',
  };

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
          // Room Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Header
                  _buildRoomHeader(),
                  const SizedBox(height: 16),
                  // Room Image
                  _buildRoomImage(),
                  const SizedBox(height: 24),
                  // Amenities Section
                  _buildAmenitiesSection(),
                  const SizedBox(height: 24),
                  // Policies Section
                  _buildPoliciesSection(),
                  const SizedBox(height: 24),
                  // Price Section
                  _buildPriceSection(),
                  const SizedBox(height: 24),
                  // Room Count Selector
                  _buildRoomCountSelector(),
                  const SizedBox(height: 16),
                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          roomData['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          roomData['type'],
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.colorBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          roomData['image'],
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '✓ Tiện nghi phòng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: (roomData['amenities'] as List).length,
          itemBuilder: (context, index) {
            final amenity = roomData['amenities'][index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.colorBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Text(
                    amenity['icon'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      amenity['name'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPoliciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chính sách hủy phòng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          (roomData['policies'] as List).length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              roomData['policies'][index],
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatPrice(roomData['price'])} VNĐ · 1 phòng',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.colorPrimary,
            ),
          ),
          if (roomData['oldPrice'] != null) ...[
            const SizedBox(height: 4),
            Text(
              '${_formatPrice(roomData['oldPrice'])} (cũ)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomCountSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Số phòng',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: roomCount > 1
                    ? () {
                        setState(() => roomCount--);
                      }
                    : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: roomCount > 1
                          ? AppColors.colorPrimary
                          : AppColors.divider,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '−',
                      style: TextStyle(
                        fontSize: 18,
                        color: roomCount > 1
                            ? AppColors.colorPrimary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$roomCount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: roomCount < 10
                    ? () {
                        setState(() => roomCount++);
                      }
                    : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: roomCount < 10
                          ? AppColors.colorPrimary
                          : AppColors.divider,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 18,
                        color: roomCount < 10
                            ? AppColors.colorPrimary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Available Button
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            border: Border.all(color: const Color(0xFF4CAF50)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'Tiếp tục có sẵn',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Book Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              _showBookingConfirmation();
            },
            child: const Text(
              'Đặt phòng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt phòng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phòng: ${roomData['name']}'),
            const SizedBox(height: 8),
            Text('Số phòng: $roomCount'),
            const SizedBox(height: 8),
            Text(
              'Tổng giá: ${_formatPrice(roomData['price'] * roomCount)} VNĐ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.colorPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorPrimary,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đặt phòng thành công!')),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
