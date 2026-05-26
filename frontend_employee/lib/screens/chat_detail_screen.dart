import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

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
                elevation: 1,
                leading: const BackButton(color: Colors.black87),
                title: Row(
                  children: [
                    const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=Trần Hoàng Nam')),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trần Hoàng Nam', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Booking #2221050704', style: TextStyle(color: primaryBlue, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.phone, color: Colors.black87), onPressed: () {}),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildMessageBubble('Chào khách sạn, cho mình hỏi phòng Deluxe có ban công không ạ?', false, '14:25'),
                        _buildMessageBubble('Chào bạn Nam, phòng Deluxe City View có ban công rộng rãi nhìn ra trung tâm thành phố nhé.', true, '14:28'),
                        _buildMessageBubble('Khách sạn có dịch vụ đưa đón sân bay không ạ?', false, '14:30'),
                      ],
                    ),
                  ),
                  _buildChatInput(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isOwner, String time) {
    return Align(
      alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isOwner ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isOwner ? 16 : 4),
                  bottomRight: Radius.circular(isOwner ? 4 : 16),
                ),
                border: isOwner ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Text(text, style: TextStyle(color: isOwner ? Colors.white : Colors.black87, fontSize: 14, height: 1.4)),
            ),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Colors.black45, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.add_photo_alternate_outlined, color: primaryBlue), onPressed: () {}),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                filled: true, fillColor: const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: () {}),
          ),
        ],
      ),
    );
  }
}