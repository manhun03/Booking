import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key, this.room, this.hotel});

  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;

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
    final capacity = _intValue(room['capacity'], 1);
    final price = _intValue(room['price'], 0);
    final roomNumber = _stringValue(room['roomNumber']);
    final name = _stringValue(room['name']) ??
        (roomNumber == null ? 'Phòng đang cập nhật' : 'Phòng $roomNumber');
    final amenities = _listValue(room['amenities']).isEmpty
        ? [
            {'name': '$capacity người lớn', 'icon': '👥'},
            {'name': 'Phòng tắm riêng', 'icon': '🚿'},
            {'name': 'WiFi miễn phí', 'icon': '📶'},
          ]
        : _listValue(room['amenities']);
    final policies = _listValue(room['policies'])
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();

    return {
      ...defaultRoom,
      ...room,
      'name': name,
      'type': _stringValue(room['type']) ?? '$capacity người lớn',
      'capacity': capacity,
      'guests': _stringValue(room['guests']) ?? '$capacity người lớn',
      'amenities': amenities,
      'policies': policies,
      'price': price,
      'taxAndFee': _intValue(room['taxAndFee'], 0),
      'extraFee': _intValue(room['extraFee'], 0),
      'description': _stringValue(room['description']) ??
          (capacity >= 3
              ? 'Phù hợp cho gia đình hoặc nhóm nhỏ'
              : 'Phù hợp cho chuyến đi cá nhân hoặc cặp đôi'),
      'cancellationPolicy': _stringValue(room['cancellationPolicy']) ??
          (policies.isEmpty ? 'Theo chính sách của khách sạn' : policies.first),
      'paymentNote': _stringValue(room['paymentNote']) ??
          (policies.length > 1
              ? policies[1]
              : 'Thanh toán và xác nhận theo yêu cầu đặt phòng'),
    };
  }

  final Map<String, dynamic> defaultRoom = {
    'name': 'Phòng đang cập nhật',
    'type': 'Đang cập nhật sức chứa',
    'image': '🏨',
    'area': null,
    'amenities': [
      {'name': 'Phòng tắm riêng', 'icon': '🚿'},
      {'name': 'WiFi miễn phí', 'icon': '📶'},
    ],
    'policies': [],
    'guests': 'Đang cập nhật',
    'cancellationPolicy': 'Theo chính sách của khách sạn',
    'paymentNote': 'Thanh toán và xác nhận theo yêu cầu đặt phòng',
    'earlyCheckout': null,
    'extraFee': 0,
    'price': 0,
    'taxAndFee': 0,
    'description': 'Thông tin phòng đang được cập nhật',
  };

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHeaderCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildRoomCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSidebar('📢', 'Quảng cáo'),
                  const SizedBox(height: 12),
                  _buildSidebar('🎁', 'Ưu đãi đặc biệt'),
                ],
              ),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: roomData['name'] as String,
        subtitle:
            'Xem tiện nghi, chính sách, giá phòng và tiếp tục điền thông tin đặt phòng trên layout web rộng rãi.',
        selectedIndex: 3,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 18),
                _buildRoomCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
            _hotelName,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _hotelLocation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
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
          if (_stringValue(roomData['earlyCheckout']) != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('🔔', roomData['earlyCheckout'] ?? ''),
          ],
          if (_intValue(roomData['extraFee'], 0) > 0) ...[
            const SizedBox(height: 12),
            _buildExtraFeeBox(),
          ],
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
                '${_formatPrice(_intValue(roomData['price'], 0))} VNĐ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _taxAndFeeText,
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
                            '${_formatPrice(_intValue(roomData['price'], 0))} VND',
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
                            child: Text(
                              _statusBadgeText,
                              style: const TextStyle(
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
                                '${_formatPrice(_intValue(roomData['price'], 0))} VND · $roomCount phòng',
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
                            child: Text(
                              _statusBadgeText,
                              style: const TextStyle(
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
                disabledBackgroundColor: const Color(0xFFB8C0CC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: !_canBook
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        '/booking-form',
                        arguments: {
                          'room': roomData,
                          'hotel': widget.hotel,
                          'roomCount': roomCount,
                        },
                      );
                    },
              child: Text(
                _canBook ? 'Đặt phòng' : 'Phòng hiện không khả dụng',
                style: const TextStyle(
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

  Widget _buildExtraFeeBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.colorBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Phụ phí: ${_formatPrice(_intValue(roomData['extraFee'], 0))} VND',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _hotelName {
    final name = _stringValue(widget.hotel?['name']);
    return name ?? 'Khách sạn đang cập nhật';
  }

  String get _hotelLocation {
    final location = _stringValue(widget.hotel?['location']);
    return location ?? 'Đang cập nhật địa chỉ khách sạn';
  }

  String get _taxAndFeeText {
    final amount = _intValue(roomData['taxAndFee'], 0);
    return amount > 0
        ? '+ ${_formatPrice(amount)} VNĐ thuế và phí'
        : 'Thuế và phí sẽ được xác nhận khi đặt phòng';
  }

  String get _statusBadgeText {
    final status = _stringValue(roomData['status'])?.toUpperCase();
    return status == 'AVAILABLE' ? 'Còn phòng' : 'Theo tình trạng phòng';
  }

  bool get _canBook {
    final status = _stringValue(roomData['status'])?.toUpperCase();
    return status == null || status.isEmpty || status == 'AVAILABLE';
  }

  List<dynamic> _listValue(dynamic value) {
    return value is List ? value : const [];
  }

  String? _stringValue(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  int _intValue(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? fallback;
    }
    return fallback;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
