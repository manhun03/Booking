import 'package:flutter/material.dart';

class SettingsMenuScreen extends StatelessWidget {
  const SettingsMenuScreen({super.key});

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
                title: const Text('Tài khoản & Cài đặt', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              body: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  // Thông tin Owner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 30, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Trần Văn Chủ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('owner@whitehotel.vn', style: TextStyle(color: Colors.black54, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nhóm Cài đặt Hệ thống
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('CÀI ĐẶT VẬN HÀNH', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  _buildMenuTile(context, Icons.rule_folder, 'Chính sách đặt & Hủy phòng', '/policy-config'),
                  _buildMenuTile(context, Icons.account_balance, 'Thông tin Ngân hàng', '/bank-info', subtitle: 'Đã xác minh', subtitleColor: Colors.green),
                  _buildMenuTile(context, Icons.notifications_active, 'Cài đặt thông báo', ''),

                  const SizedBox(height: 24),

                  // Nhóm Tài khoản
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('TÀI KHOẢN CỦA TÔI', style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  _buildMenuTile(context, Icons.lock_outline, 'Đổi mật khẩu', '/reset-password'),
                  _buildMenuTile(context, Icons.help_outline, 'Trung tâm hỗ trợ', ''),
                  
                  const SizedBox(height: 16),
                  
                  // Đăng xuất
                  Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 16),
                            Text('Đăng xuất', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String route, {String? subtitle, Color? subtitleColor}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: route.isNotEmpty ? () => Navigator.pushNamed(context, route) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              if (subtitle != null)
                Text(subtitle, style: TextStyle(color: subtitleColor ?? Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}