import 'package:flutter/material.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({super.key});

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
            child: DefaultTabController(
              length: 4,
              child: Scaffold(
                backgroundColor: const Color(0xFFF8F9FA),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: const BackButton(color: Colors.black87),
                  title: const Text('Quản lý Booking', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                  bottom: TabBar(
                    isScrollable: true,
                    labelColor: primaryBlue,
                    unselectedLabelColor: Colors.black45,
                    indicatorColor: primaryBlue,
                    tabs: const [
                      Tab(text: 'Chờ duyệt'),
                      Tab(text: 'Sắp đến'),
                      Tab(text: 'Đang ở'),
                      Tab(text: 'Lịch sử'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    _buildBookingList(context, status: 'pending'),
                    _buildBookingList(context, status: 'confirmed'),
                    _buildBookingList(context, status: 'checked_in'),
                    _buildBookingList(context, status: 'completed'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, {required String status}) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3, 
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        String bookingId = index == 0 ? '2221050704' : '222105070${index + 5}'; 
        return _buildBookingCard(context, status, bookingId);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, String status, String bookingId) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/booking-detail');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#$bookingId', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                  _buildStatusBadge(status),
                ],
              ),
              const Divider(height: 24),
              const Row(
                children: [
                  CircleAvatar(backgroundColor: Color(0xFFF8F9FA), child: Icon(Icons.person, color: Colors.black54)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trần Hoàng Nam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('0901234567 • 2 Khách', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phòng:', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        Text('Deluxe City View (P.302)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thời gian:', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        Text('12/10 - 14/10 (2 đêm)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}