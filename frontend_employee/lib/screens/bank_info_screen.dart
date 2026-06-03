import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class BankInfoScreen extends StatefulWidget {
  const BankInfoScreen({super.key});

  @override
  State<BankInfoScreen> createState() => _BankInfoScreenState();
}

class _BankInfoScreenState extends State<BankInfoScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _valid = false;
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
    _bankController.dispose();
    _numberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await Future.wait([
        _api.fetchSettings(),
        _api.validateBankInfo(),
      ]);
      final settings = data[0] as Map<String, dynamic>;
      _bankController.text = textValue(settings['bankName'], '');
      _numberController.text = textValue(settings['bankAccountNumber'], '');
      _nameController.text = textValue(settings['bankAccountName'], '');
      if (!mounted) return;
      setState(() {
        _valid = data[1] as bool;
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
    if (_bankController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      _message('Vui long nhap du thong tin ngan hang.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _api.updateBankInfo(
        bankName: _bankController.text,
        bankAccountNumber: _numberController.text,
        bankAccountName: _nameController.text,
      );
      final valid = await _api.validateBankInfo();
      if (!mounted) return;
      setState(() => _valid = valid);
      _message('Da cap nhat thong tin ngan hang.');
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
        leading: BackButton(onPressed: () => Navigator.pop(context, true)),
        title: const Text('Thong tin ngan hang'),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (_valid ? Colors.green : Colors.orange).withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _valid
                        ? 'Thong tin nhan thanh toan da day du.'
                        : 'Can cap nhat day du thong tin de nhan thanh toan.',
                    style: TextStyle(
                      color: _valid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _field('Ngan hang', _bankController),
                const SizedBox(height: 15),
                _field(
                  'So tai khoan',
                  _numberController,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 15),
                _field('Ten chu tai khoan', _nameController),
                const SizedBox(height: 30),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Cap nhat thong tin'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
