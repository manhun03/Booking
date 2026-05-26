import 'package:flutter/material.dart';

class RevenueDetailScreen extends StatefulWidget {
  const RevenueDetailScreen({super.key});

  @override
  State<RevenueDetailScreen> createState() => _RevenueDetailScreenState();
}

class _RevenueDetailScreenState extends State<RevenueDetailScreen> {
  final Color primaryBlue = const Color(0xFF3F63B5);
  final Color secondaryOrange = const Color(0xFFF2994A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: _buildAppBar(context),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tổng quan doanh thu
                    _buildRevenueOverviewCard(),
                    const SizedBox(height: 24),

                    // Biểu đồ
                    const Text('BIỂU ĐỒ TĂNG TRƯỞNG', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 12),
                    _buildChartCard(),
                    const SizedBox(height: 24),

                    // Thông tin Insights (Khung giờ/ngày đông khách)
                    const Text('HÀNH VI KHÁCH HÀNG', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInsightCard(Icons.calendar_month, 'Ngày đông nhất', 'Thứ 6 & Thứ 7')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInsightCard(Icons.access_time, 'Giờ đặt nhiều', '14:00 - 16:00')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Top phòng hiệu quả
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOP PHÒNG DOANH THU CAO', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: Text('TẤT CẢ', style: TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTopRoomItem('Deluxe City View', 'Phòng 302', '45.000.000 đ', '32 Booking', 1),
                    const SizedBox(height: 12),
                    _buildTopRoomItem('Suite Balcony', 'Phòng 501', '38.500.000 đ', '18 Booking', 2),
                    const SizedBox(height: 12),
                    _buildTopRoomItem('Standard Room', 'Phòng 105', '22.000.000 đ', '45 Booking', 3),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Báo cáo Doanh thu',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: primaryBlue),
          onPressed: () {
            // TODO: Mở bộ lọc chọn tháng/năm
          },
        ),
      ],
    );
  }

  Widget _buildRevenueOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, const Color(0xFF2A4B9B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: primaryBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng doanh thu tháng này', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text('Tháng 10', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text('125.500.000 đ', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 8),
              const Text('+15% so với tháng trước', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  // Build một biểu đồ cột giả lập bằng các Container
  Widget _buildChartCard() {
    // Dữ liệu giả lập tỷ lệ phần trăm (0.0 -> 1.0) của 6 tháng
    final List<double> percentages = [0.4, 0.6, 0.3, 0.8, 1.0, 0.7];
    final List<String> labels = ['T5', 'T6', 'T7', 'T8', 'T9', 'T10'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Doanh thu 6 tháng qua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 24),
          SizedBox(
            height: 150, // Chiều cao của biểu đồ
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end, // Căn đáy cho các cột
              children: List.generate(percentages.length, (index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cột biểu đồ
                    Container(
                      width: 24,
                      height: 120 * percentages[index], // Tính chiều cao dựa trên tỷ lệ
                      decoration: BoxDecoration(
                        color: index == percentages.length - 1 ? primaryBlue : primaryBlue.withValues(alpha: 0.2), // Nhấn mạnh cột cuối
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Nhãn trục X
                    Text(labels[index], style: TextStyle(color: index == percentages.length - 1 ? primaryBlue : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: secondaryOrange, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTopRoomItem(String roomType, String roomNumber, String revenue, String bookings, int rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rank == 1 ? Colors.amber.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rank == 1 ? Colors.amber[800] : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Room Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(roomType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(roomNumber, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          // Revenue Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(revenue, style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(bookings, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}