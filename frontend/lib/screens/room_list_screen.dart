import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key, this.hotel});

  final Map<String, dynamic>? hotel;

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late List<Map<String, dynamic>> rooms;
  late List<Map<String, dynamic>> _allRooms;
  late List<Map<String, dynamic>> _roomTypes;
  int? _selectedRoomTypeId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeRooms();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final hotelId = _hotelId;
    if (hotelId == null) {
      setState(() {
        _errorMessage = 'Khong tim thay khach san de tai danh sach phong.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final values = await Future.wait([
        ApiService().fetchRoomsByHotel(hotelId),
        ApiService().fetchRoomTypesByHotel(hotelId),
      ]);
      final loadedRooms = values[0];
      final roomTypes = values[1];
      if (!mounted) return;
      setState(() {
        _allRooms = loadedRooms;
        _roomTypes = roomTypes;
        rooms = _filterRoomsBySelectedType(loadedRooms);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  int? get _hotelId {
    // Try from hotel parameter first
    final hotelValue = widget.hotel?['id'];
    if (hotelValue != null) {
      if (hotelValue is int) return hotelValue;
      if (hotelValue is num) return hotelValue.toInt();
      if (hotelValue is String) return int.tryParse(hotelValue);
    }

    return null;
  }

  void _initializeRooms() {
    rooms = [];
    _allRooms = [];
    _roomTypes = const [];
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
              Expanded(
                child: Text(
                  _hotelName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _hotelLocation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _priceHint,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          if (_roomTypes.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildRoomTypeFilter(),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomTypeFilter() {
    return DropdownButtonFormField<int?>(
      initialValue: _selectedRoomTypeId,
      decoration: const InputDecoration(
        labelText: 'Loai phong',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Tat ca loai phong')),
        ..._roomTypes.map((type) {
          final id = _intValue(type['id']);
          return DropdownMenuItem<int?>(
            value: id,
            child: Text(type['name']?.toString() ?? 'Room type #$id'),
          );
        }),
      ],
      onChanged: (value) => _loadRoomsForType(value),
    );
  }

  Future<void> _loadRoomsForType(int? roomTypeId) async {
    final hotelId = _hotelId;
    if (hotelId == null) return;
    setState(() {
      _selectedRoomTypeId = roomTypeId;
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final loadedRooms = roomTypeId == null
          ? _allRooms
          : (await ApiService().fetchRoomsByRoomType(roomTypeId))
              .where((room) => _intValue(room['hotelId']) == hotelId)
              .toList();
      if (!mounted) return;
      setState(() {
        rooms = loadedRooms;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filterRoomsBySelectedType(
    List<Map<String, dynamic>> source,
  ) {
    final selected = _selectedRoomTypeId;
    if (selected == null) return source;
    return source.where((room) => _intValue(room['roomTypeId']) == selected).toList();
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
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
    if (_isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_errorMessage != null) {
      return [_buildErrorMessage(_errorMessage!)];
    }

    if (rooms.isEmpty) {
      return [_buildStateMessage('Khong co phong de hien thi')];
    }

    return List.generate(
      rooms.length,
      _buildRoomCard,
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Builder(
                builder: (context) => ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/search'),
                  icon: const Icon(Icons.search),
                  label: const Text('Tìm khách sạn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorSecondary,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateMessage(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRoomCard(int index) {
    final room = rooms[index];
    final available = _isAvailable(room);
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: (available
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFD97706))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    available ? 'Còn phòng' : 'Không khả dụng',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: available
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
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
                      disabledBackgroundColor: const Color(0xFFB8C0CC),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: !available
                        ? null
                        : () {
                            // Navigate to room detail screen
                            Navigator.pushNamed(
                              context,
                              '/room-detail',
                              arguments: {
                                'room': room,
                                'hotel': widget.hotel,
                                'availableRooms': rooms.length,
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
                // StaySmart Link
                Center(
                  child: Text(
                    'Chi tiết ${rooms.length} loại phòng tại $_hotelName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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

  String get _hotelName {
    final name = widget.hotel?['name']?.toString().trim();
    return name == null || name.isEmpty ? 'Chọn chỗ của bạn' : name;
  }

  String get _hotelLocation {
    final location = widget.hotel?['location']?.toString().trim();
    return location == null || location.isEmpty
        ? 'Đang cập nhật địa chỉ khách sạn'
        : location;
  }

  String get _priceHint {
    if (_isLoading) return 'Đang tải giá phòng mới nhất';
    if (rooms.isEmpty) return 'Chưa có giá phòng khả dụng';
    return 'Giá được lấy trực tiếp từ dữ liệu phòng hiện tại';
  }

  bool _isAvailable(Map<String, dynamic> room) {
    return '${room['status'] ?? ''}'.toUpperCase() == 'AVAILABLE';
  }
}
