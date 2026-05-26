import 'package:flutter/material.dart';

class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({super.key});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final Color primaryBlue = const Color(0xFF3F63B5);
  bool _isAvailable = true;
  
  // State cho các tiện ích (Amenities)
  final Map<String, bool> _amenities = {
    'WiFi miễn phí': true,
    'Tivi': false,
    'Điều hòa': true,
    'Bồn tắm': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Container(
            decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]),
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: const BackButton(color: Colors.black87),
                title: const Text('Cập nhật Phòng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Số / Tên phòng'),
                              _buildTextField('VD: 301'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Loại phòng'),
                              DropdownButtonFormField<String>(
                                decoration: _inputDecoration(),
                                items: ['Standard', 'Deluxe', 'Suite'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (value) {},
                                hint: const Text('Loại'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Giá mỗi đêm (VNĐ)'),
                              _buildTextField('VD: 1500000'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Sức chứa (Khách)'),
                              _buildTextField('VD: 2'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Tiện ích phòng'),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                      child: Column(
                        children: _amenities.keys.map((key) {
                          return CheckboxListTile(
                            title: Text(key, style: const TextStyle(fontSize: 14)),
                            value: _amenities[key],
                            activeColor: primaryBlue,
                            onChanged: (bool? value) {
                              setState(() {
                                _amenities[key] = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sẵn sàng đón khách', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Switch(value: _isAvailable, activeColor: primaryBlue, onChanged: (val) => setState(() => _isAvailable = val)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Lưu thông tin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)));
  }

  Widget _buildTextField(String hint) {
    return TextFormField(decoration: _inputDecoration().copyWith(hintText: hint));
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true, fillColor: Colors.white, hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
    );
  }
}