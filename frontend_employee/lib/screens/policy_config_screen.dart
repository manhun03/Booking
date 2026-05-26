import 'package:flutter/material.dart';

class PolicyConfigScreen extends StatefulWidget {
  const PolicyConfigScreen({super.key});

  @override
  State<PolicyConfigScreen> createState() => _PolicyConfigScreenState();
}

class _PolicyConfigScreenState extends State<PolicyConfigScreen> {
  final Color primaryBlue = const Color(0xFF3F63B5);
  bool _allowFreeCancel = true;

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
                title: const Text('Chính sách Vận hành', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('THỜI GIAN NHẬN / TRẢ PHÒNG', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Giờ Check-in'),
                              _buildDropdown(['12:00', '14:00', '15:00'], '14:00'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Giờ Check-out'),
                              _buildDropdown(['11:00', '12:00', '13:00'], '12:00'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    const Text('CHÍNH SÁCH ĐẶT CỌC', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildLabel('Tỷ lệ cọc yêu cầu (%)'),
                    _buildTextField('VD: 50'),
                    const SizedBox(height: 8),
                    const Text('Khách hàng cần thanh toán trước số % này để đơn đặt phòng được xác nhận.', style: TextStyle(color: Colors.black45, fontSize: 12)),
                    const SizedBox(height: 32),

                    const Text('CHÍNH SÁCH HỦY PHÒNG', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Cho phép hủy miễn phí', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            value: _allowFreeCancel,
                            activeThumbColor: primaryBlue,
                            onChanged: (val) => setState(() => _allowFreeCancel = val),
                          ),
                          if (_allowFreeCancel) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Miễn phí hủy trước (Ngày)'),
                                  _buildTextField('VD: 3'),
                                  const SizedBox(height: 8),
                                  const Text('Nếu hủy sau thời gian này, khách sẽ mất tiền cọc.', style: TextStyle(color: Colors.black45, fontSize: 11)),
                                ],
                              ),
                            ),
                          ]
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
                        child: const Text('Lưu chính sách', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
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
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white, hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String initial) {
    return DropdownButtonFormField<String>(
      initialValue: initial,
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {},
    );
  }
}