import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color primaryBlue = const Color(0xFF3F63B5);

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
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: _buildAppBar(context),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'TRANG CHỦ QUẢN LÝ',
                      style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chào buổi sáng, Chủ khách sạn',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),

                    // Thẻ thống kê
                    _buildSummaryCard(
                      title: 'DOANH THU HÔM NAY',
                      mainValue: '24.500', suffixValue: ' .000 VNĐ',
                      subText: '+12% so với hôm qua', subIcon: Icons.trending_up, subColor: Colors.green,
                      icon: Icons.payments_outlined, leftBorderColor: primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      title: 'TỶ LỆ LẤP ĐẦY',
                      mainValue: '85', suffixValue: ' %',
                      subText: '42/50 phòng đang ở', subIcon: Icons.check_circle, subColor: Colors.green,
                      icon: Icons.bed_outlined, leftBorderColor: Colors.green,
                    ),
                    const SizedBox(height: 32),

                    // Lối tắt quản lý
                    Row(
                      children: [
                        Icon(Icons.grid_view_rounded, color: primaryBlue, size: 20),
                        const SizedBox(width: 8),
                        const Text('Lối tắt quản lý', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: 0.9, 
                      physics: const NeverScrollableScrollPhysics(), 
                      children: [
                        _buildShortcutCard(
                          Icons.domain, 'Quản lý Khách sạn', 'Danh sách cơ sở kinh doanh',
                          () => Navigator.pushNamed(context, '/hotel-list'),
                        ),
                        _buildShortcutCard(
                          Icons.hotel_class, 'Quản lý Phòng', 'Cập nhật trạng thái, giá',
                          () => Navigator.pushNamed(context, '/room-list'),
                        ),
                        _buildShortcutCard(
                          Icons.book_online, 'Quản lý Booking', 'Xác nhận, hủy, đổi lịch',
                          () => Navigator.pushNamed(context, '/booking'),
                        ),
                        _buildShortcutCard(
                          Icons.bar_chart, 'Quản lý Doanh thu', 'Báo cáo chi tiết theo tháng',
                          () => Navigator.pushNamed(context, '/revenue-detail'), // Nút này giờ đã hoạt động 100%
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Hoạt động gần đây
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, color: primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            const Text('Hoạt động gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/booking'),
                          child: Text('XEM TẤT CẢ', style: TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildActivityItem('Lê Minh Anh', 'Phòng Deluxe 302', '2.400.000 đ', 'ĐÃ THANH TOÁN', Colors.green),
                    const Divider(height: 24, color: Colors.black12),
                    _buildActivityItem('Trần Hoàng Nam', 'Mã đặt: 2221050704', '3.500.000 đ', 'CHỜ XÁC NHẬN', primaryBlue),
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
      backgroundColor: const Color(0xFFF8F9FA),
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'StaySmart Hotel',
        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(context, '/notifications'), 
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(context, '/chats'), 
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title, required String mainValue, required String suffixValue, required String subText,
    required IconData subIcon, required Color subColor, required IconData icon, required Color leftBorderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: leftBorderColor, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: mainValue, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryBlue),
                  children: [TextSpan(text: suffixValue, style: const TextStyle(fontSize: 12, color: Colors.black87))],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(subIcon, color: subColor, size: 14),
                  const SizedBox(width: 4),
                  Text(subText, style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              )
            ],
          ),
          Positioned(right: 0, top: 0, child: Icon(icon, color: Colors.black.withValues(alpha: 0.05), size: 48))
        ],
      ),
    );
  }

  Widget _buildShortcutCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap, 
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: primaryBlue, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black45, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String name, String room, String price, String status, Color statusColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20, backgroundColor: Colors.black12,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$name'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(room, style: const TextStyle(color: Colors.black45, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          ],
        )
      ],
    );
  }
}