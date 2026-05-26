import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

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
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: const BackButton(color: Colors.black87),
                title: const Text('Tin nhắn hỗ trợ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: ListView(
                children: [
                  _buildChatItem(context, 'Trần Hoàng Nam', 'Khách sạn có dịch vụ đưa đón sân bay không ạ?', '14:30', true),
                  const Divider(height: 1),
                  _buildChatItem(context, 'Nguyễn Thu Thảo', 'Vâng, cảm ơn admin.', 'Hôm qua', false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, String name, String lastMessage, String time, bool isUnread) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/chat-detail'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$name')),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isUnread ? Colors.black87 : Colors.black54, fontSize: 13, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(time, style: TextStyle(color: isUnread ? primaryBlue : Colors.black45, fontSize: 12, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                  const SizedBox(height: 8),
                  if (isUnread)
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}