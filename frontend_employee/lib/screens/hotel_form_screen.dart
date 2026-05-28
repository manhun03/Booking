import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class HotelFormScreen extends StatefulWidget {
  const HotelFormScreen({super.key, this.hotel});

  final Map<String, dynamic>? hotel;

  @override
  State<HotelFormScreen> createState() => _HotelFormScreenState();
}

class _HotelFormScreenState extends State<HotelFormScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final hotel = widget.hotel;
    if (hotel != null) {
      _name.text = textValue(hotel['name'], '');
      _street.text = textValue(hotel['street'], '');
      _phone.text = textValue(hotel['phone'], '');
      _description.text = textValue(hotel['description'], '');
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _street.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _street.text.trim().isEmpty) {
      _message('Vui long nhap ten va dia chi khach san.');
      return;
    }
    setState(() => _saving = true);
    final payload = {
      'name': _name.text.trim(),
      'street': _street.text.trim(),
      'phone': _phone.text.trim(),
      'description': _description.text.trim(),
    };
    try {
      final id = widget.hotel == null ? null : intValue(widget.hotel!['id']);
      if (id == null) {
        await _api.createHotel(payload);
      } else {
        await _api.updateHotel(id, payload);
      }
      if (!mounted) return;
      _message(
        id == null
            ? 'Da gui khach san de admin duyet.'
            : 'Da cap nhat khach san.',
      );
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
    final editing = widget.hotel != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(editing ? 'Chinh sua khach san' : 'Them khach san'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!editing)
            const Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Khach san moi se o trang thai cho admin duyet.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          if (!editing) const SizedBox(height: 15),
          _field('Ten khach san', _name),
          const SizedBox(height: 15),
          _field('Dia chi', _street),
          const SizedBox(height: 15),
          _field('So dien thoai', _phone, type: TextInputType.phone),
          const SizedBox(height: 15),
          _field('Mo ta', _description, lines: 4),
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
                  : const Text('Luu thong tin'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? type,
    int lines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: lines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
