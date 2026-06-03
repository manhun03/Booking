import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);

  Map<String, dynamic> _dashboard = const {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AuthService().fetchAdminDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Khong tai duoc du lieu dashboard.';
        _isLoading = false;
      });
    }
  }

  void _logout() {
    AuthService().logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthService().currentSession;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Tai lai',
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Dang xuat',
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Xin chao, ${session?.fullName?.isNotEmpty == true ? session!.fullName : session?.email ?? 'Admin'}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tong quan he thong StaySmart',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _metricCard(
                            icon: Icons.people_outline,
                            label: 'Nguoi dung',
                            value: _value('users'),
                            color: _primaryBlue,
                          ),
                          _metricCard(
                            icon: Icons.domain_outlined,
                            label: 'Khach san',
                            value: _value('hotels'),
                            color: Colors.teal,
                          ),
                          _metricCard(
                            icon: Icons.book_online_outlined,
                            label: 'Booking',
                            value: _value('bookings'),
                            color: Colors.orange,
                          ),
                          _metricCard(
                            icon: Icons.check_circle_outline,
                            label: 'Hoan tat',
                            value: _value('completedBookings'),
                            color: Colors.green,
                          ),
                          _metricCard(
                            icon: Icons.cancel_outlined,
                            label: 'Da huy',
                            value: _value('cancelledBookings'),
                            color: Colors.redAccent,
                          ),
                          _metricCard(
                            icon: Icons.payments_outlined,
                            label: 'Doanh thu',
                            value: _moneyValue('revenue'),
                            color: Colors.indigo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _sectionCard(
                        title: 'Chuc nang admin',
                        children: [
                          _actionTile(
                            icon: Icons.manage_accounts_outlined,
                            title: 'Quan ly nguoi dung',
                            subtitle:
                                'Xem, tim kiem, tao, cap nhat, khoa va mo khoa tai khoan.',
                            route: '/admin-users',
                          ),
                          _actionTile(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Vai tro va phan quyen',
                            subtitle:
                                'Xem role, permission theo module va kiem tra RBAC/JWT.',
                            route: '/admin-roles',
                          ),
                          _actionTile(
                            icon: Icons.verified_outlined,
                            title: 'Quan ly khach san',
                            subtitle:
                                'Duyet, tu choi, khoa hoac mo khoa khach san owner tao.',
                            route: '/admin-hotels',
                          ),
                          _actionTile(
                            icon: Icons.book_online_outlined,
                            title: 'Quan ly booking',
                            subtitle:
                                'Theo doi booking toan he thong va force-complete khi can.',
                            route: '/admin-bookings',
                          ),
                          _actionTile(
                            icon: Icons.payments_outlined,
                            title: 'Quan ly thanh toan',
                            subtitle:
                                'Theo doi giao dich, trang thai payment va xu ly hoan tien.',
                            route: '/admin-payments',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _sectionCard(
                        title: 'Noi dung va van hanh',
                        children: [
                          _actionTile(
                            icon: Icons.reviews_outlined,
                            title: 'Kiem duyet danh gia',
                            subtitle:
                                'Xem review theo khach san, loc review bi bao cao va an review khong phu hop.',
                            route: '/admin-reviews',
                          ),
                          _actionTile(
                            icon: Icons.notifications_outlined,
                            title: 'Quan ly thong bao',
                            subtitle:
                                'Theo doi thong bao he thong va danh dau thong bao da doc.',
                            route: '/admin-notifications',
                          ),
                          _actionTile(
                            icon: Icons.tune_outlined,
                            title: 'Cau hinh he thong',
                            subtitle: 'Xem va cap nhat system config theo key.',
                            route: '/admin-system-configs',
                          ),
                          _actionTile(
                            icon: Icons.location_city_outlined,
                            title: 'Tinh va phuong',
                            subtitle:
                                'Quan ly Province/Ward dung cho dia chi khach san.',
                            route: '/admin-locations',
                          ),
                          _actionTile(
                            icon: Icons.history_outlined,
                            title: 'Audit log',
                            subtitle:
                                'Xem lich su thao tac quan trong da duoc backend ghi nhan.',
                            route: '/admin-audit-logs',
                          ),
                          _actionTile(
                            icon: Icons.integration_instructions_outlined,
                            title: 'Tich hop he thong',
                            subtitle:
                                'Kiem tra actuator health, MinIO, Firebase va ChatAI theo endpoint backend hien co.',
                            route: '/admin-integrations',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboard,
              child: const Text('Thu lai'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _primaryBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).pushNamed(route),
    );
  }

  String _value(String key) => (_dashboard[key] ?? 0).toString();

  String _moneyValue(String key) {
    final value = _dashboard[key];
    if (value == null) return '0 VND';
    return '$value VND';
  }
}
