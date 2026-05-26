import 'package:flutter/material.dart';

class RoomListScreen extends StatelessWidget {
  const RoomListScreen({super.key});

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
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quản lý Phòng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('White Hotel - Hoàn Kiếm', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildRoomCard('Phòng 301', 'Deluxe Double', '1.200.000 đ', 'CÓ SẴN', Colors.green),
                  const SizedBox(height: 12),
                  _buildRoomCard('Phòng 302', 'Suite Family', '2.500.000 đ', 'ĐANG BẢO TRÌ', Colors.red),
                  const SizedBox(height: 12),
                  _buildRoomCard('Phòng 303', 'Standard', '800.000 đ', 'CÓ SẴN', Colors.green),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/room-form');
                },
                backgroundColor: primaryBlue,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(String roomNumber, String type, String price, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.bed, color: Colors.black45, size: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(roomNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(type, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: Color(0xFF3F63B5), fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}