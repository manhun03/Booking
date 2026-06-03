import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({super.key, this.room, this.initialHotel});

  final Map<String, dynamic>? room;
  final Map<String, dynamic>? initialHotel;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _capacity = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _amenities = TextEditingController();
  final TextEditingController _seasonalPrice = TextEditingController();
  final TextEditingController _promotionPrice = TextEditingController();

  List<Map<String, dynamic>> _hotels = const [];
  List<Map<String, dynamic>> _roomTypes = const [];
  int? _hotelId;
  int? _roomTypeId;
  String _status = 'AVAILABLE';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    if (room != null) {
      _number.text = textValue(room['roomNumber'], '');
      _capacity.text = '${intValue(room['capacity'])}';
      _price.text = '${doubleValue(room['price']).round()}';
      _amenities.text = textValue(room['amenities'], '');
      _seasonalPrice.text = _nullableNumber(room['seasonalPrice']);
      _promotionPrice.text = _nullableNumber(room['promotionPrice']);
      _hotelId = intValue(room['hotelId']);
      _roomTypeId = intValue(room['roomTypeId']);
      _status = textValue(room['status'], 'AVAILABLE');
    } else if (widget.initialHotel != null) {
      _hotelId = intValue(widget.initialHotel!['id']);
    }
    _loadChoices();
  }

  @override
  void dispose() {
    _number.dispose();
    _capacity.dispose();
    _price.dispose();
    _amenities.dispose();
    _seasonalPrice.dispose();
    _promotionPrice.dispose();
    super.dispose();
  }

  Future<void> _loadChoices() async {
    try {
      final values = await Future.wait([
        _api.fetchHotels(),
        _api.fetchRoomTypes(),
      ]);
      if (!mounted) return;
      setState(() {
        _hotels = values[0];
        _roomTypes = values[1];
        _hotelId ??= _hotels.isEmpty ? null : intValue(_hotels.first['id']);
        _roomTypeId ??= _roomTypes.isEmpty
            ? null
            : intValue(_roomTypes.first['id']);
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

  Future<void> _save() async {
    final capacity = int.tryParse(_capacity.text.trim());
    final price = double.tryParse(_price.text.trim());
    if (_hotelId == null || _roomTypeId == null) {
      _message('Can co khach san va loai phong de luu.');
      return;
    }
    if (_number.text.trim().isEmpty ||
        capacity == null ||
        capacity <= 0 ||
        price == null ||
        price < 0) {
      _message('Thong tin phong khong hop le.');
      return;
    }
    setState(() => _saving = true);
    final payload = {
      'hotel': {'id': _hotelId},
      'roomType': {'id': _roomTypeId},
      'roomNumber': _number.text.trim(),
      'capacity': capacity,
      'price': price,
      'amenities': _amenities.text.trim(),
      'seasonalPrice': _optionalNumber(_seasonalPrice.text),
      'promotionPrice': _optionalNumber(_promotionPrice.text),
      'status': _status,
    };
    try {
      final id = widget.room == null ? null : intValue(widget.room!['id']);
      if (id == null) {
        await _api.createRoom(payload);
      } else {
        await _api.updateRoom(id, payload);
      }
      if (!mounted) return;
      _message('Da luu thong tin phong.');
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(widget.room == null ? 'Them phong' : 'Cap nhat phong'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _label('Khach san'),
                DropdownButtonFormField<int>(
                  initialValue: _hotelId,
                  decoration: _decoration(),
                  items: _hotels
                      .map(
                        (hotel) => DropdownMenuItem(
                          value: intValue(hotel['id']),
                          child: Text(textValue(hotel['name'])),
                        ),
                      )
                      .toList(),
                  onChanged: widget.room == null
                      ? (value) => setState(() => _hotelId = value)
                      : null,
                ),
                const SizedBox(height: 15),
                _label('Loai phong'),
                DropdownButtonFormField<int>(
                  initialValue: _roomTypeId,
                  decoration: _decoration(),
                  items: _roomTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: intValue(type['id']),
                          child: Text(textValue(type['name'])),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _roomTypeId = value),
                ),
                const SizedBox(height: 15),
                _field('So phong', _number),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _field('Suc chua', _capacity)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Gia co ban', _price)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _field('Gia mua vu', _seasonalPrice)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Gia khuyen mai', _promotionPrice)),
                  ],
                ),
                const SizedBox(height: 15),
                _field('Tien ich', _amenities, lines: 3),
                const SizedBox(height: 15),
                _label('Trang thai'),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: _decoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'AVAILABLE',
                      child: Text('San sang'),
                    ),
                    DropdownMenuItem(
                      value: 'UNAVAILABLE',
                      child: Text('Khong san sang'),
                    ),
                    DropdownMenuItem(
                      value: 'MAINTENANCE',
                      child: Text('Bao tri'),
                    ),
                    DropdownMenuItem(
                      value: 'OCCUPIED',
                      child: Text('Dang co khach'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _status = value ?? _status),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Luu phong'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int lines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          maxLines: lines,
          keyboardType: lines == 1 ? TextInputType.text : null,
          decoration: _decoration(),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  InputDecoration _decoration() => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  double? _optionalNumber(String value) {
    final text = value.trim();
    return text.isEmpty ? null : double.tryParse(text);
  }

  String _nullableNumber(dynamic value) {
    if (value == null) return '';
    return '${doubleValue(value).round()}';
  }
}
