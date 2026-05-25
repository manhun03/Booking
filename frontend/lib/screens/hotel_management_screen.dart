import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';

class HotelManagementScreen extends StatefulWidget {
  const HotelManagementScreen({Key? key}) : super(key: key);

  @override
  State<HotelManagementScreen> createState() => _HotelManagementScreenState();
}

class _HotelManagementScreenState extends State<HotelManagementScreen> {
  List<Map<String, dynamic>> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService();
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hotels = await _apiService.fetchHotels(
        pageIndex: _currentPage,
        pageSize: _pageSize,
      );
      if (mounted) {
        setState(() {
          _hotels = hotels;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tải danh sách khách sạn: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteHotel(int hotelId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn chắc chắn muốn xóa khách sạn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteHotel(hotelId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa khách sạn thành công')),
          );
          _loadHotels();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xóa khách sạn: $e')),
          );
        }
      }
    }
  }

  void _showHotelDialog({Map<String, dynamic>? hotel}) {
    showDialog(
      context: context,
      builder: (context) => _HotelFormDialog(
        hotel: hotel,
        apiService: _apiService,
        onSaved: () {
          Navigator.pop(context);
          _loadHotels();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Khách sạn'),
        backgroundColor: AppColors.colorPrimary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHotels,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _hotels.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.hotel,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có khách sạn',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _showHotelDialog(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.colorPrimary,
                            ),
                            child: const Text(
                              'Thêm khách sạn đầu tiên',
                              style: TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tổng: ${_hotels.length} khách sạn',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showHotelDialog(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Thêm khách sạn'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.colorPrimary,
                                    foregroundColor: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildHotelTable(),
                          ],
                        ),
                      ),
                    ),
      floatingActionButton: _hotels.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppColors.colorPrimary,
              onPressed: () => _showHotelDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHotelTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Tên khách sạn')),
          DataColumn(label: Text('Địa chỉ')),
          DataColumn(label: Text('Tỉnh/Thành phố')),
          DataColumn(label: Text('Điện thoại')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Hành động')),
        ],
        rows: _hotels.map((hotel) {
          return DataRow(
            cells: [
              DataCell(Text(hotel['id']?.toString() ?? '-')),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(
                    hotel['name'] ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(
                    hotel['street'] ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(hotel['provinceName'] ?? '-')),
              DataCell(Text(hotel['phone'] ?? '-')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (hotel['status'] ?? 'ACTIVE') == 'ACTIVE'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    hotel['status'] ?? 'ACTIVE',
                    style: TextStyle(
                      color: (hotel['status'] ?? 'ACTIVE') == 'ACTIVE'
                          ? Colors.green.shade900
                          : Colors.orange.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.colorPrimary),
                      onPressed: () => _showHotelDialog(hotel: hotel),
                      tooltip: 'Chỉnh sửa',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteHotel(hotel['id']),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _HotelFormDialog extends StatefulWidget {
  final Map<String, dynamic>? hotel;
  final ApiService apiService;
  final VoidCallback onSaved;

  const _HotelFormDialog({
    required this.hotel,
    required this.apiService,
    required this.onSaved,
  });

  @override
  State<_HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<_HotelFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _streetController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  String _status = 'ACTIVE';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.hotel?['name'] ?? '',
    );
    _streetController = TextEditingController(
      text: widget.hotel?['street'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.hotel?['phone'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.hotel?['description'] ?? '',
    );
    _status = widget.hotel?['status'] ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng điền đầy đủ thông tin';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.hotel == null) {
        // Create new hotel
        await widget.apiService.createHotel(
          name: _nameController.text,
          street: _streetController.text,
          phone: _phoneController.text,
          description: _descriptionController.text,
          status: _status,
        );
      } else {
        // Update existing hotel
        await widget.apiService.updateHotel(
          id: widget.hotel!['id'],
          name: _nameController.text,
          street: _streetController.text,
          phone: _phoneController.text,
          description: _descriptionController.text,
          status: _status,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.hotel == null
                  ? 'Thêm khách sạn thành công'
                  : 'Cập nhật khách sạn thành công',
            ),
          ),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.hotel == null ? 'Thêm khách sạn' : 'Chỉnh sửa khách sạn'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên khách sạn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Điện thoại',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              minLines: 3,
              maxLines: 5,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: ['ACTIVE', 'INACTIVE'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.colorPrimary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.white,
                    ),
                  ),
                )
              : const Text(
                  'Lưu',
                  style: TextStyle(color: AppColors.white),
                ),
        ),
      ],
    );
  }
}
