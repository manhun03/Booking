import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class SettingsMenuScreen extends StatefulWidget {
  const SettingsMenuScreen({super.key});

  @override
  State<SettingsMenuScreen> createState() => _SettingsMenuScreenState();
}

class _SettingsMenuScreenState extends State<SettingsMenuScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  Map<String, dynamic> _settings = const {};
  bool _bankValid = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait([
        _api.fetchSettings(),
        _api.validateBankInfo(),
      ]);
      if (!mounted) return;
      setState(() {
        _settings = values[0] as Map<String, dynamic>;
        _bankValid = values[1] as bool;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(String route) async {
    final changed = await Navigator.pushNamed(context, route);
    if (changed == true) await _load();
  }

  void _logout() {
    AuthService().logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthService().currentSession;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Tai khoan & Cai dat'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(
                      textValue(session?.fullName, 'Owner'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(session?.email ?? ''),
                  ),
                ),
                const SizedBox(height: 20),
                _header('VAN HANH'),
                _tile(
                  Icons.rule_folder_outlined,
                  'Chinh sach dat phong',
                  'Coc: ${(doubleValue(_settings['depositRate']) * 100).toStringAsFixed(0)}% | Bao truoc: ${intValue(_settings['minBookingNotice'])} gio',
                  () => _open('/policy-config'),
                ),
                _tile(
                  Icons.account_balance_outlined,
                  'Thong tin ngan hang',
                  _bankValid ? 'Da day du thong tin nhan tien' : 'Can cap nhat',
                  () => _open('/bank-info'),
                  statusColor: _bankValid ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 20),
                _header('TAI KHOAN'),
                _tile(
                  Icons.lock_outline,
                  'Doi mat khau',
                  'Quan ly mat khau truy cap',
                  () => Navigator.pushNamed(context, '/reset-password'),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Dang xuat',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.black45,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _tile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? statusColor,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: _primaryBlue),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: statusColor ?? Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
