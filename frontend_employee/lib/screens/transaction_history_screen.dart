import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

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
                title: const Text('Lịch sử Thanh toán', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                actions: [
                  IconButton(icon: Icon(Icons.download_rounded, color: primaryBlue), onPressed: () {}), // Nút xuất file đối soát
                ],
              ),
              body: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildTransactionCard(index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(int index) {
    // Giả lập dữ liệu
    bool isRefund = index == 3;
    bool isPending = index == 1;

    Color iconBgColor = isRefund ? Colors.red.withValues(alpha: 0.1) : (isPending ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1));
    Color iconColor = isRefund ? Colors.red : (isPending ? Colors.orange : Colors.green);
    IconData icon = isRefund ? Icons.keyboard_return : (isPending ? Icons.hourglass_empty : Icons.check_circle_outline);
    String status = isRefund ? 'Hoàn tiền' : (isPending ? 'Đang chờ' : 'Thành công');
    String amount = isRefund ? '-1.200.000 đ' : '+3.500.000 đ';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mã Đơn: 2221050704', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('26/05/2026 - 14:30', style: TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isRefund ? Colors.red : Colors.black87)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}