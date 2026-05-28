import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class PolicyConfigScreen extends StatefulWidget {
  const PolicyConfigScreen({super.key});

  @override
  State<PolicyConfigScreen> createState() => _PolicyConfigScreenState();
}

class _PolicyConfigScreenState extends State<PolicyConfigScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _noticeController = TextEditingController();

  bool _allowReview = true;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _depositController.dispose();
    _noticeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _api.fetchSettings();
      if (!mounted) return;
      _depositController.text = (doubleValue(data['depositRate']) * 100)
          .toStringAsFixed(0);
      _noticeController.text = '${intValue(data['minBookingNotice'])}';
      setState(() {
        _allowReview = data['allowReview'] != false;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final depositPercent = double.tryParse(_depositController.text.trim());
    final notice = int.tryParse(_noticeController.text.trim());
    if (depositPercent == null || depositPercent < 0 || depositPercent > 100) {
      _message('Ty le dat coc phai tu 0 den 100.');
      return;
    }
    if (notice == null || notice < 0) {
      _message('Thoi gian bao truoc khong hop le.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _api.updateSettings(
        depositRate: depositPercent / 100,
        minBookingNotice: notice,
        allowReview: _allowReview,
      );
      if (!mounted) return;
      _message('Da luu chinh sach.');
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Chinh sach dat phong'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Cau hinh nay duoc dung khi khach gui yeu cau dat phong.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                _label('Ty le dat coc yeu cau (%)'),
                TextField(
                  controller: _depositController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Vi du: 30'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Khach can thanh toan toi thieu ty le nay de dat phong duoc xu ly.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                _label('Thoi gian bao truoc toi thieu (gio)'),
                TextField(
                  controller: _noticeController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Vi du: 2'),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  child: SwitchListTile(
                    value: _allowReview,
                    activeThumbColor: _primaryBlue,
                    onChanged: (value) => setState(() => _allowReview = value),
                    title: const Text('Cho phep danh gia'),
                    subtitle: const Text(
                      'Khach hang co the danh gia sau khi hoan thanh luu tru.',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : const Text('Luu chinh sach'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}
