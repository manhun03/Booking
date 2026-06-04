import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key, this.hotel});

  final Map<String, dynamic>? hotel;

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  List<Map<String, dynamic>> _rooms = const [];
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
      final allRooms = await _api.fetchRooms();
      final hotelId = widget.hotel == null
          ? null
          : intValue(widget.hotel!['id']);
      final rooms = hotelId == null
          ? allRooms
          : allRooms
                .where((room) => intValue(room['hotelId']) == hotelId)
                .toList();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
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

  Future<void> _openForm([Map<String, dynamic>? room]) async {
    final result = await Navigator.pushNamed(
      context,
      '/room-form',
      arguments: {'room': room, 'hotel': widget.hotel},
    );
    if (result == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.hotel == null
        ? null
        : textValue(widget.hotel!['name']);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quan ly phong'),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _rooms.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 160),
                        Center(child: Text('Chua co phong nao.')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rooms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) => _roomCard(_rooms[index]),
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _roomCard(Map<String, dynamic> room) {
    final status = textValue(room['status'], 'UNAVAILABLE');
    final color = switch (status) {
      'AVAILABLE' => Colors.green,
      'OCCUPIED' => _primaryBlue,
      'MAINTENANCE' => Colors.orange,
      _ => Colors.red,
    };
    return Card(
      elevation: 0,
      child: ListTile(
        onTap: () => _openForm(room),
        leading: const CircleAvatar(child: Icon(Icons.bed_outlined)),
        title: Text(
          'Phong ${textValue(room['roomNumber'])}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Suc chua: ${intValue(room['capacity'])} khach | ${formatMoney(room['price'])}'
          '${doubleValue(room['seasonalPrice']) > 0 ? ' | Gia mua vu: ${formatMoney(room['seasonalPrice'])}' : ''}',
        ),
        trailing: Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
