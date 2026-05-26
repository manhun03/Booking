import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  final Color primaryBlue = const Color(0xFF3F63B5);

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
                title: const Text('Thông báo', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                actions: [
                  IconButton(icon: Icon(Icons.done_all, color: primaryBlue), onPressed: () {}), // Nút Đánh dấu đã đọc tất cả
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _buildNotificationItem(Icons.book_online, primaryBlue, 'Booking mới #2221050704', 'Khách hàng Trần Hoàng Nam vừa đặt phòng Deluxe City View.', 'Vừa xong', true),
                  _buildNotificationItem(Icons.payment, Colors.green, 'Thanh toán thành công', 'Đơn đặt phòng #2221050704 đã thanh toán 3.500.000 đ.', '10 phút trước', true),
                  _buildNotificationItem(Icons.star, Colors.orange, 'Đánh giá mới', 'Khách hàng Lê Minh Anh vừa để lại đánh giá 5 sao cho khách sạn.', '2 giờ trước', false),
                  _buildNotificationItem(Icons.cancel, Colors.red, 'Booking bị hủy', 'Hệ thống đã hủy đơn #BK10022 do quá hạn thanh toán.', 'Hôm qua', false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, Color color, String title, String body, String time, bool isUnread) {
    return Container(
      color: isUnread ? primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: isUnread ? Colors.black87 : Colors.black54, fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Text(time, style: TextStyle(color: primaryBlue, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (isUnread)
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
        ],
      ),
    );
  }
}