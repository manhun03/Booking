import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';
import '../utils/web_image_picker_stub.dart'
    if (dart.library.html) '../utils/web_image_picker_web.dart';

class HotelFormScreen extends StatefulWidget {
  const HotelFormScreen({super.key, this.hotel});

  final Map<String, dynamic>? hotel;

  @override
  State<HotelFormScreen> createState() => _HotelFormScreenState();
}

class _HotelFormScreenState extends State<HotelFormScreen> {
  static const Color _primaryBlue = Color(0xFF3F63B5);
  final OwnerApiService _api = OwnerApiService();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _description = TextEditingController();

  List<Map<String, dynamic>> _images = const [];
  bool _loadingImages = false;
  bool _uploadingImage = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final hotel = widget.hotel;
    if (hotel != null) {
      _name.text = textValue(hotel['name'], '');
      _street.text = textValue(hotel['street'], '');
      _phone.text = textValue(hotel['phone'], '');
      _description.text = textValue(hotel['description'], '');
      _loadImages();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _street.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _street.text.trim().isEmpty) {
      _message('Vui long nhap ten va dia chi khach san.');
      return;
    }
    setState(() => _saving = true);
    final payload = {
      'name': _name.text.trim(),
      'street': _street.text.trim(),
      'phone': _phone.text.trim(),
      'description': _description.text.trim(),
    };
    try {
      final id = widget.hotel == null ? null : intValue(widget.hotel!['id']);
      if (id == null) {
        await _api.createHotel(payload);
      } else {
        await _api.updateHotel(id, payload);
      }
      if (!mounted) return;
      _message(
        id == null
            ? 'Da gui khach san de admin duyet.'
            : 'Da cap nhat khach san.',
      );
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadImages() async {
    final id = widget.hotel == null ? 0 : intValue(widget.hotel!['id']);
    if (id <= 0) return;
    setState(() => _loadingImages = true);
    try {
      final images = await _api.fetchHotelImages(id);
      if (!mounted) return;
      setState(() {
        _images = images;
        _loadingImages = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _loadingImages = false);
      _message(error.message);
    }
  }

  Future<void> _uploadImage() async {
    final hotelId = widget.hotel == null ? 0 : intValue(widget.hotel!['id']);
    if (hotelId <= 0) return;
    final selected = await pickImageFile();
    if (selected == null) return;
    setState(() => _uploadingImage = true);
    try {
      await _api.uploadHotelImage(
        hotelId: hotelId,
        bytes: selected.bytes,
        fileName: selected.name,
        primaryImage: _images.isEmpty,
        sortOrder: _images.length,
      );
      if (!mounted) return;
      _message('Da upload anh khach san.');
      await _loadImages();
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _deleteImage(Map<String, dynamic> image) async {
    final hotelId = widget.hotel == null ? 0 : intValue(widget.hotel!['id']);
    final imageId = intValue(image['id']);
    if (hotelId <= 0 || imageId <= 0) return;
    try {
      await _api.deleteHotelImage(hotelId: hotelId, imageId: imageId);
      if (!mounted) return;
      _message('Da xoa anh.');
      await _loadImages();
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _setPrimaryImage(Map<String, dynamic> image) async {
    final hotelId = widget.hotel == null ? 0 : intValue(widget.hotel!['id']);
    final imageId = intValue(image['id']);
    if (hotelId <= 0 || imageId <= 0) return;
    try {
      for (final item in _images) {
        final itemId = intValue(item['id']);
        if (itemId <= 0) continue;
        await _api.updateHotelImage(
          hotelId: hotelId,
          imageId: itemId,
          image: {
            'imageUrl': item['imageUrl'],
            'objectKey': item['objectKey'],
            'primaryImage': itemId == imageId,
            'sortOrder': intValue(item['sortOrder']),
          },
        );
      }
      if (!mounted) return;
      _message('Da dat anh dai dien.');
      await _loadImages();
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.hotel != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(editing ? 'Chinh sua khach san' : 'Them khach san'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!editing)
            const Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Khach san moi se o trang thai cho admin duyet.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          if (!editing) const SizedBox(height: 15),
          _field('Ten khach san', _name),
          const SizedBox(height: 15),
          _field('Dia chi', _street),
          const SizedBox(height: 15),
          _field('So dien thoai', _phone, type: TextInputType.phone),
          const SizedBox(height: 15),
          _field('Mo ta', _description, lines: 4),
          if (editing) ...[const SizedBox(height: 24), _imageManager()],
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
                  : const Text('Luu thong tin'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageManager() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Anh khach san',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _uploadingImage || _loadingImages
                      ? null
                      : _uploadImage,
                  icon: _uploadingImage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_outlined),
                  label: const Text('Upload anh'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loadingImages)
              const Center(child: CircularProgressIndicator())
            else if (_images.isEmpty)
              const Text(
                'Chua co anh nao cho khach san nay.',
                style: TextStyle(color: Colors.black54),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _images.map(_imageTile).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imageTile(Map<String, dynamic> image) {
    final imageUrl = textValue(image['imageUrl'], '');
    final primary = image['primaryImage'] == true || image['isPrimary'] == true;
    return SizedBox(
      width: 190,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: primary ? _primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: imageUrl.isEmpty
                    ? const ColoredBox(
                        color: Color(0xFFE9EEF8),
                        child: Icon(Icons.image_outlined),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFE9EEF8),
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (primary)
                    const Chip(
                      label: Text('Dai dien'),
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    TextButton(
                      onPressed: () => _setPrimaryImage(image),
                      child: const Text('Dat dai dien'),
                    ),
                  IconButton(
                    tooltip: 'Xoa anh',
                    onPressed: () => _deleteImage(image),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? type,
    int lines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: lines,
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
