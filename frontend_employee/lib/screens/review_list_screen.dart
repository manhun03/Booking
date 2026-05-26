import 'package:flutter/material.dart';

class ReviewListScreen extends StatelessWidget {
  const ReviewListScreen({super.key});

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
                title: const Text('Đánh giá của khách', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildReviewCard(context, 'Lê Minh Anh', 5, 'Phòng rất sạch sẽ, nhân viên thân thiện và hỗ trợ nhiệt tình. Sẽ quay lại vào lần sau!', '14/10/2026', true),
                  const SizedBox(height: 16),
                  _buildReviewCard(context, 'Nguyễn Văn C', 3, 'Điều hòa trong phòng hơi ồn, wifi thi thoảng bị chập chờn.', '10/10/2026', false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, String name, int stars, String comment, String date, bool hasReplied) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey[200], backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$name')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) => Icon(Icons.star, size: 14, color: index < stars ? Colors.amber : Colors.grey[300])),
                    ),
                  ],
                ),
              ),
              Text(date, style: const TextStyle(color: Colors.black45, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),
          
          if (hasReplied)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.subdirectory_arrow_right, color: primaryBlue, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Cảm ơn bạn đã tin tưởng và ủng hộ White Hotel. Rất mong được đón tiếp bạn trong tương lai!', style: TextStyle(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReplyBottomSheet(context),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Phản hồi'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.flag, size: 16, color: Colors.red), 
                  label: const Text('Báo cáo', style: TextStyle(color: Colors.red)),
                )
              ],
            )
        ],
      ),
    );
  }

  void _showReplyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phản hồi đánh giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập câu trả lời của bạn...',
                filled: true, fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Gửi phản hồi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}