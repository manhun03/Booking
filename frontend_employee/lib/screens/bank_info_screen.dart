import 'package:flutter/material.dart';

class BankInfoScreen extends StatelessWidget {
  const BankInfoScreen({super.key});

  final Color primaryBlue = const Color(0xFF3F63B5);
  final bool isVerified = true; // Đổi thành false để xem trạng thái chưa xác minh

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
                title: const Text('Thông tin Ngân hàng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isVerified ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isVerified ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(isVerified ? Icons.check_circle : Icons.warning_amber_rounded, color: isVerified ? Colors.green : Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isVerified ? 'TRẠNG THÁI: ĐÃ XÁC MINH' : 'TRẠNG THÁI: CHƯA ĐẦY ĐỦ', style: TextStyle(color: isVerified ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(isVerified ? 'Hệ thống đã sẵn sàng đối soát doanh thu.' : 'Vui lòng cập nhật thông tin để nhận thanh toán.', style: const TextStyle(color: Colors.black87, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text('THÔNG TIN TÀI KHOẢN', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _buildLabel('Ngân hàng'),
                    DropdownButtonFormField<String>(
                      value: 'Vietcombank', // Generic Bank
                      decoration: _inputDecoration(),
                      items: ['Vietcombank', 'MB Bank', 'Techcombank', 'BIDV'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Số tài khoản'),
                    TextFormField(
                      initialValue: isVerified ? '0987654321' : '',
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration().copyWith(hintText: 'Nhập số tài khoản'),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Tên chủ tài khoản'),
                    TextFormField(
                      initialValue: isVerified ? 'TRAN VAN CHU' : '',
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDecoration().copyWith(hintText: 'VIẾT HOA KHÔNG DẤU'),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Cập nhật & Xác minh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true, fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
    );
  }
}