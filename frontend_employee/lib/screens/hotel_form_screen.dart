import 'package:flutter/material.dart';

class HotelFormScreen extends StatefulWidget {
  const HotelFormScreen({super.key});

  @override
  State<HotelFormScreen> createState() => _HotelFormScreenState();
}

class _HotelFormScreenState extends State<HotelFormScreen> {
  final Color primaryBlue = const Color(0xFF3F63B5);
  bool _isActive = true;

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
                title: const Text('Thông tin Khách sạn', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Ảnh (Giả lập)
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12, style: BorderStyle.solid)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: primaryBlue),
                          const SizedBox(height: 8),
                          const Text('Tải ảnh bìa lên (Chọn từ thư mục lastest)', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildLabel('Tên khách sạn'),
                    _buildTextField('VD: White Hotel - Cầu Giấy'),
                    const SizedBox(height: 16),
                    
                    _buildLabel('Tỉnh / Thành phố'),
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration(),
                      items: ['Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) {},
                      hint: const Text('Chọn Tỉnh/Thành'),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Địa chỉ chi tiết'),
                    _buildTextField('Số nhà, tên đường...'),
                    const SizedBox(height: 16),

                    _buildLabel('Mô tả ngắn gọn'),
                    TextFormField(
                      maxLines: 4,
                      decoration: _inputDecoration().copyWith(hintText: 'Mô tả cơ sở vật chất, vị trí...'),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trạng thái hoạt động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Switch(
                            value: _isActive,
                            activeThumbColor: primaryBlue,
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
    );
  }

  Widget _buildTextField(String hint) {
    return TextFormField(decoration: _inputDecoration().copyWith(hintText: hint));
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
    );
  }
}