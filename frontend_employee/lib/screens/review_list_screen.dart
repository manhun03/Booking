import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();

  List<Map<String, dynamic>> _reviews = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final hotels = await _api.fetchHotels();
      final reviews = await _api.fetchReviewsForHotels(hotels);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
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

  Future<void> _reply(Map<String, dynamic> review) async {
    final controller = TextEditingController();
    final reply = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phan hoi danh gia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Nhap noi dung phan hoi...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isNotEmpty) Navigator.pop(context, value);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Gui phan hoi'),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (reply == null) return;

    try {
      await _api.replyReview(intValue(review['id']), reply);
      if (!mounted) return;
      _message('Da gui phan hoi.');
      await _load();
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Danh gia cua khach'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorView()
          : RefreshIndicator(
              onRefresh: _load,
              child: _reviews.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 180),
                        Center(child: Text('Chua co danh gia nao.')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _reviews.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _reviewCard(_reviews[index]),
                    ),
            ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _load, child: const Text('Thu lai')),
        ],
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final rating = intValue(review['rating']).clamp(0, 5);
    final answer = textValue(review['ownerReply'], '');
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textValue(review['hotelName']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Khach hang #${intValue(review['customerId'])}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatDate(review['createdAt']),
                  style: const TextStyle(color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 17,
                  color: index < rating ? Colors.amber : Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(textValue(review['comment'], 'Khong co noi dung.')),
            const SizedBox(height: 14),
            if (answer.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Phan hoi: $answer'),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _reply(review),
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Phan hoi'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
