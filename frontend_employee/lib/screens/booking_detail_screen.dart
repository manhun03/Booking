import 'package:flutter/material.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  final Color primaryBlue = const Color(0xFF3F63B5);
  final String status = 'pending'; // Đổi thành 'confirmed', 'checked_in' để test UI các nút

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
                title: const Text('Chi tiết Booking', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Mã Booking
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mã Booking: #2221050704', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Thông tin khách hàng
                    const Text('THÔNG TIN KHÁCH HÀNG', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.person_outline, 'Họ và tên', 'Trần Hoàng Nam'),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.phone_outlined, 'Số điện thoại', '090 123 4567'),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.email_outlined, 'Email', 'nam.tran@email.com'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Thông tin nhận phòng
                    const Text('CHI TIẾT ĐẶT PHÒNG', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.hotel_outlined, 'Phòng', 'Deluxe City View (302)'),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.people_outline, 'Số lượng khách', '2 Người lớn'),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.login, 'Nhận phòng', '14:00 - 12/10/2026'),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.logout, 'Trả phòng', '12:00 - 14/10/2026'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Thông tin thanh toán
                    const Text('CHI TIẾT THANH TOÁN', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Trạng thái', style: TextStyle(color: Colors.black54, fontSize: 14)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                child: const Text('ĐÃ THANH TOÁN', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          const Divider(height: 24),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tiền phòng (2 đêm)', style: TextStyle(color: Colors.black54, fontSize: 14)),
                              Text('3.000.000 đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Thuế & Phí', style: TextStyle(color: Colors.black54, fontSize: 14)),
                              Text('500.000 đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Colors.black26, thickness: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TỔNG CỘNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('3.500.000 đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryBlue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              bottomNavigationBar: _buildBottomActions(context, status),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.black45, size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor; Color textColor; String text;
    switch (status) {
      case 'pending': bgColor = Colors.orange.withValues(alpha: 0.1); textColor = Colors.orange; text = 'CHỜ DUYỆT'; break;
      case 'confirmed': bgColor = primaryBlue.withValues(alpha: 0.1); textColor = primaryBlue; text = 'SẮP ĐẾN'; break;
      case 'checked_in': bgColor = Colors.green.withValues(alpha: 0.1); textColor = Colors.green; text = 'ĐANG Ở'; break;
      default: bgColor = Colors.grey.withValues(alpha: 0.2); textColor = Colors.black54; text = 'HOÀN TẤT';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBottomActions(BuildContext context, String status) {
    if (status == 'pending') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.red), child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: primaryBlue, foregroundColor: Colors.white), child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ),
      );
    } else if (status == 'confirmed') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text('Thực hiện Check-in', style: TextStyle(fontWeight: FontWeight.bold)))),
      );
    } else if (status == 'checked_in') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.orange, foregroundColor: Colors.white), child: const Text('Thực hiện Check-out', style: TextStyle(fontWeight: FontWeight.bold)))),
      );
    }
    return const SizedBox.shrink();
  }
}