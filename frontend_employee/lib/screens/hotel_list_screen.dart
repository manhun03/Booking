import 'package:flutter/material.dart';

class HotelListScreen extends StatelessWidget {
  const HotelListScreen({super.key});

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
                title: const Text('Quản lý Khách sạn', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHotelCard('White Hotel - Hoàn Kiếm', 'Mã ĐD: 2221050704', '123 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', 'ĐANG HOẠT ĐỘNG', Colors.green),
                  const SizedBox(height: 16),
                  _buildHotelCard('White Hotel - Hồ Tây', 'Mã ĐD: HT-002', '45 Thanh Niên, Tây Hồ, Hà Nội', 'CHỜ ADMIN DUYỆT', Colors.orange),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/hotel-form');
                },
                backgroundColor: primaryBlue,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm Khách sạn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelCard(String name, String code, String address, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.more_horiz, color: Colors.black45),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(code, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.black45),
              const SizedBox(width: 4),
              Expanded(child: Text(address, style: const TextStyle(color: Colors.black54, fontSize: 12))),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Danh sách Phòng'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F63B5), foregroundColor: Colors.white), child: const Text('Chỉnh sửa'))),
            ],
          )
        ],
      ),
    );
  }
}