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
    roomData = _mergeRoomData(widget.room ?? defaultRoom);
  }

  Map<String, dynamic> _mergeRoomData(Map<String, dynamic> room) {
    return {
      ...defaultRoom,
      ...room,
    };
  }

  final Map<String, dynamic> defaultRoom = {
    'name': 'Phòng Superior Có Giường Cỏ King',
    'type': '2 giường đôi',
    'image': '🏨',
    'area': '22m²',
    'amenities': [
      {'name': '2 giường đôi', 'icon': '🛏️'},
      {'name': 'Diện tích: 22m²', 'icon': '📐'},
      {'name': 'Phòng tắm riêng', 'icon': '🚿'},
      {'name': 'TV 4k sắc nét', 'icon': '📺'},
      {'name': 'Nhìn xuống phố', 'icon': '👀'},
      {'name': 'Hệ thống cách âm', 'icon': '🔇'},
    ],
    'guests': '3 người lớn',
    'cancellationPolicy': 'Toàn bộ tiền phòng',
    'paymentNote': 'Khứng cần thanh toán trước - thanh toán tại khách sạn',
    'earlyCheckout': 'Có báo sáng (thank toàn tại chỗ ngủ)',
    'extraFee': 1000564,
    'price': 11934235,
    'taxAndFee': 601545,
    'description': 'Phù hợp cho có gia đình',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBg,
      body: CustomScrollView(
        slivers: [
          // Header with 3-Column Layout
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 900;

                  if (isDesktop) {
                    // 3-Column Header for Desktop
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Empty Box
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.colorBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.divider),
                            ),
                            height: 60,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Center Header
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.arrow_back,
                                        color: AppColors.textPrimary),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Chọn chỗ của bạn',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '27 thg 9 - 30 thg 9',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Giá đã được đối với một VND ⓘ',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right Empty Box
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.colorBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.divider),
                            ),
                            height: 60,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Single Column Header for Mobile
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.arrow_back,
                                  color: AppColors.textPrimary),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chọn chỗ của bạn',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '27 thg 9 - 30 thg 9',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Giá đã được đối với một VND ⓘ',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          // Main Content with Responsive Layout
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 900;

                  if (isDesktop) {
                    // 3-Column Layout for Desktop
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Sidebar
                        Expanded(
                          flex: 1,
                          child: _buildSidebar('📢', 'Quảng cáo'),
                        ),
                        const SizedBox(width: 12),
                        // Center Main Card
                        Expanded(
                          flex: 2,
                          child: _buildRoomCard(),
                        ),
                        const SizedBox(width: 12),
                        // Right Sidebar
                        Expanded(
                          flex: 1,
                          child: _buildSidebar('🎁', 'Ưu đãi đặc biệt'),
                        ),
                      ],
                    );
                  } else {
                    // Single Column Layout for Mobile
                    return Column(
                      children: [
                        _buildRoomCard(),
                        const SizedBox(height: 16),
                        _buildSidebar('📢', 'Quảng cáo'),
                        const SizedBox(height: 12),
                        _buildSidebar('🎁', 'Ưu đãi đặc biệt'),
                      ],
                    );
                  }
                },
              ),
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

  Widget _buildRoomCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Image Row
          LayoutBuilder(
            builder: (context, constraints) {
              final imageSize = constraints.maxWidth < 300 ? 60.0 : 80.0;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomData['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.colorPrimary,
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Room Image
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: AppColors.colorBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Center(
                      child: Text(
                        roomData['image'],
                        style: TextStyle(fontSize: imageSize * 0.5),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          // Amenities Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 16,
            ),
            itemCount: (roomData['amenities'] as List).length,
            itemBuilder: (context, index) {
              final amenity = roomData['amenities'][index];
              return Row(
                children: [
                  Text(
                    amenity['icon'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      amenity['name'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          // Additional Info
          _buildInfoRow('👥', 'Giá cho ${roomData['guests'] ?? ''}'),
          const SizedBox(height: 8),
          _buildInfoRow(
              '🚫', 'Phí hủy: ${roomData['cancellationPolicy'] ?? ''}'),
          const SizedBox(height: 8),
          _buildInfoRow('💳', roomData['paymentNote'] ?? ''),
          const SizedBox(height: 8),
          _buildInfoRow('🔔', roomData['earlyCheckout'] ?? ''),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Text(
                  '🍽️',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Có báo sáng (thanh toán tại chỗ ngủ)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '(${_formatPrice(roomData['extraFee'] as int? ?? 0)} VND)',
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
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          // Pricing Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giá 1 đêm',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatPrice((roomData['price'] as int?) ?? 0)} VNĐ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+ ${_formatPrice((roomData['taxAndFee'] as int?) ?? 0)} VNĐ thuế và phí',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          // Booking Section
          Container(
            decoration: BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 300;
                return isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatPrice((roomData['price'] as int?) ?? 0)} VND',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$roomCount phòng',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Phù hợp cho có gia đình',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatPrice((roomData['price'] as int?) ?? 0)} VND · $roomCount phòng',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                roomData['description'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Phù hợp cho có gia đình',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
          const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    // This method is no longer used - pricing is now integrated in _buildRoomCard()
    return const SizedBox.shrink();
  }

  Widget _buildBookingSection() {
    // This method is no longer used - booking section is now integrated in _buildRoomCard()
    return const SizedBox.shrink();
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
