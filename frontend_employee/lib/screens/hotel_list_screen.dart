import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  List<Map<String, dynamic>> _hotels = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final hotels = await _api.fetchHotels();
      if (!mounted) return;
      setState(() {
        _hotels = hotels;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _openForm([Map<String, dynamic>? hotel]) async {
    final changed = await Navigator.pushNamed(
      context,
      '/hotel-form',
      arguments: hotel,
    );
    if (changed == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Quan ly khach san'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorBody()
          : RefreshIndicator(
              onRefresh: _load,
              child: _hotels.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 160),
                        Center(child: Text('Chua co khach san nao.')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _hotels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => _hotelCard(_hotels[index]),
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Them khach san'),
      ),
    );
  }

  Widget _errorBody() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('Thu lai')),
        ],
      ),
    );
  }

  Widget _hotelCard(Map<String, dynamic> hotel) {
    final status = textValue(hotel['status'], 'INACTIVE');
    final color = switch (status) {
      'ACTIVE' => Colors.green,
      'PENDING_APPROVAL' => Colors.orange,
      'SUSPENDED' || 'REJECTED' => Colors.red,
      _ => Colors.grey,
    };
    final address = [
      textValue(hotel['street'], ''),
      textValue(hotel['wardName'], ''),
      textValue(hotel['provinceName'], ''),
    ].where((item) => item.isNotEmpty).join(', ');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#${intValue(hotel['id'])}',
                  style: const TextStyle(color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              textValue(hotel['name']),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address.isEmpty ? 'Chua cap nhat dia chi' : address,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Dien thoai: ${textValue(hotel['phone'])}',
              style: const TextStyle(color: Colors.black54),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/room-list',
                      arguments: hotel,
                    ),
                    child: const Text('Danh sach phong'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openForm(hotel),
                    child: const Text('Chinh sua'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
