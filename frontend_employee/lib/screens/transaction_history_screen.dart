import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final OwnerApiService _api = OwnerApiService();

  List<Map<String, dynamic>> _payments = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final payments = await _api.fetchPayments();
      if (!mounted) return;
      setState(() {
        _payments = payments;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Lich su thanh toan'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  TextButton(onPressed: _load, child: const Text('Thu lai')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _payments.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 180),
                        Center(child: Text('Chua co giao dich nao.')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _payments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _paymentCard(_payments[index]),
                    ),
            ),
    );
  }

  Widget _paymentCard(Map<String, dynamic> payment) {
    final status = textValue(payment['status'], 'PENDING').toUpperCase();
    final refunded = status.contains('REFUND');
    final successful = status == 'COMPLETED';
    final color = refunded
        ? Colors.red
        : successful
        ? Colors.green
        : Colors.orange;
    final icon = refunded
        ? Icons.keyboard_return
        : successful
        ? Icons.check_circle_outline
        : Icons.hourglass_empty;
    final label = switch (status) {
      'COMPLETED' => 'Thanh cong',
      'FAILED' => 'That bai',
      'REFUNDED' => 'Da hoan tien',
      'PARTIALLY_REFUNDED' => 'Hoan tien mot phan',
      _ => 'Dang cho',
    };
    final amount = refunded && payment['refundedAmount'] != null
        ? payment['refundedAmount']
        : payment['amount'];
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Don #${intValue(payment['bookingId'])}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${textValue(payment['provider'], textValue(payment['method']))} - '
                    '${formatDate(payment['createdAt'], withTime: true)}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
