import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/owner_api_service.dart';
import '../utils/display_format.dart';

class OwnerRoomToolsScreen extends StatefulWidget {
  const OwnerRoomToolsScreen({super.key});

  @override
  State<OwnerRoomToolsScreen> createState() => _OwnerRoomToolsScreenState();
}

class _OwnerRoomToolsScreenState extends State<OwnerRoomToolsScreen> {
  final _api = OwnerApiService();
  List<Map<String, dynamic>> _roomTypes = const [];
  List<Map<String, dynamic>> _rooms = const [];
  List<Map<String, dynamic>> _timeSlots = const [];
  int? _selectedRoomId;
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
      final values = await Future.wait([
        _api.fetchRoomTypes(),
        _api.fetchRooms(),
      ]);
      final rooms = values[1];
      final selectedRoomId =
          _selectedRoomId ??
          (rooms.isEmpty ? null : intValue(rooms.first['id']));
      final slots = selectedRoomId == null
          ? <Map<String, dynamic>>[]
          : await _api.fetchTimeSlotsByRoom(selectedRoomId);
      if (!mounted) return;
      setState(() {
        _roomTypes = values[0];
        _rooms = rooms;
        _selectedRoomId = selectedRoomId;
        _timeSlots = slots;
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

  Future<void> _loadSlotsForRoom(int? roomId) async {
    setState(() {
      _selectedRoomId = roomId;
      _timeSlots = const [];
    });
    if (roomId == null) return;
    try {
      final slots = await _api.fetchTimeSlotsByRoom(roomId);
      if (!mounted) return;
      setState(() => _timeSlots = slots);
    } on ApiException catch (error) {
      if (mounted) _snack(error.message, isError: true);
    }
  }

  Future<void> _editRoomType({Map<String, dynamic>? roomType}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _RoomTypeDialog(roomType: roomType),
    );
    if (result == true) await _load();
  }

  Future<void> _deleteRoomType(Map<String, dynamic> roomType) async {
    final id = intValue(roomType['id']);
    if (id <= 0) return;
    try {
      await _api.deleteRoomType(id);
      if (!mounted) return;
      _snack('Da xoa loai phong.');
      await _load();
    } on ApiException catch (error) {
      if (mounted) _snack(error.message, isError: true);
    }
  }

  Future<void> _editTimeSlot({Map<String, dynamic>? slot}) async {
    if (_rooms.isEmpty) {
      _snack('Can tao phong truoc khi them lich gia.', isError: true);
      return;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _TimeSlotDialog(
        rooms: _rooms,
        slot: slot,
        initialRoomId: _selectedRoomId,
      ),
    );
    if (result == true) await _loadSlotsForRoom(_selectedRoomId);
  }

  Future<void> _deleteTimeSlot(Map<String, dynamic> slot) async {
    final id = intValue(slot['id']);
    if (id <= 0) return;
    try {
      await _api.deleteTimeSlot(id);
      if (!mounted) return;
      _snack('Da xoa lich gia.');
      await _loadSlotsForRoom(_selectedRoomId);
    } on ApiException catch (error) {
      if (mounted) _snack(error.message, isError: true);
    }
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: const Text('Loai phong va lich gia'),
          actions: [
            IconButton(
              tooltip: 'Tai lai',
              onPressed: _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Loai phong'),
              Tab(text: 'Lich gia'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            : TabBarView(children: [_roomTypeTab(), _timeSlotTab()]),
      ),
    );
  }

  Widget _roomTypeTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _editRoomType(),
            icon: const Icon(Icons.add),
            label: const Text('Them loai phong'),
          ),
        ),
        const SizedBox(height: 12),
        if (_roomTypes.isEmpty)
          const _Empty(message: 'Chua co loai phong.')
        else
          ..._roomTypes.map(
            (type) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.category)),
                title: Text(
                  textValue(type['name'], 'Loai phong #${type['id']}'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  textValue(type['description'], 'Khong co mo ta'),
                ),
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: 'Sua',
                      onPressed: () => _editRoomType(roomType: type),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Xoa',
                      onPressed: () => _deleteRoomType(type),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _timeSlotTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 14,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 360,
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedRoomId,
                    decoration: const InputDecoration(labelText: 'Phong'),
                    items: _rooms
                        .map(
                          (room) => DropdownMenuItem(
                            value: intValue(room['id']),
                            child: Text(
                              'Phong ${textValue(room['roomNumber'])} - ${textValue(room['hotelName'])}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _loadSlotsForRoom,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _editTimeSlot(),
                  icon: const Icon(Icons.add),
                  label: const Text('Them lich gia'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_timeSlots.isEmpty)
          const _Empty(message: 'Phong nay chua co lich gia.')
        else
          ..._timeSlots.map(
            (slot) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.event)),
                title: Text(
                  '${formatDate(slot['startDate'])} - ${formatDate(slot['endDate'])}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(formatMoney(slot['price'])),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    Chip(
                      label: Text(slot['active'] == true ? 'ACTIVE' : 'OFF'),
                    ),
                    IconButton(
                      tooltip: 'Sua',
                      onPressed: () => _editTimeSlot(slot: slot),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Xoa',
                      onPressed: () => _deleteTimeSlot(slot),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RoomTypeDialog extends StatefulWidget {
  const _RoomTypeDialog({this.roomType});

  final Map<String, dynamic>? roomType;

  @override
  State<_RoomTypeDialog> createState() => _RoomTypeDialogState();
}

class _RoomTypeDialogState extends State<_RoomTypeDialog> {
  final _api = OwnerApiService();
  late final TextEditingController _name;
  late final TextEditingController _description;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: textValue(widget.roomType?['name'], ''),
    );
    _description = TextEditingController(
      text: textValue(widget.roomType?['description'], ''),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Vui long nhap ten loai phong.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final body = {
      'name': _name.text.trim(),
      'description': _description.text.trim(),
    };
    try {
      final id = intValue(widget.roomType?['id']);
      if (id <= 0) {
        await _api.createRoomType(body);
      } else {
        await _api.updateRoomType(id, body);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.roomType == null ? 'Them loai phong' : 'Sua loai phong',
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Ten loai phong'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Mo ta'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Huy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Luu'),
        ),
      ],
    );
  }
}

class _TimeSlotDialog extends StatefulWidget {
  const _TimeSlotDialog({
    required this.rooms,
    required this.initialRoomId,
    this.slot,
  });

  final List<Map<String, dynamic>> rooms;
  final int? initialRoomId;
  final Map<String, dynamic>? slot;

  @override
  State<_TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<_TimeSlotDialog> {
  final _api = OwnerApiService();
  final _price = TextEditingController();
  int? _roomId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _active = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final slot = widget.slot;
    _roomId = intValue(slot?['roomId']);
    if (_roomId == 0) _roomId = widget.initialRoomId;
    _startDate = _parseDate(slot?['startDate']) ?? DateTime.now();
    _endDate =
        _parseDate(slot?['endDate']) ??
        DateTime.now().add(const Duration(days: 1));
    _price.text = slot == null
        ? ''
        : doubleValue(slot['price']).round().toString();
    _active = slot?['active'] != false;
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await _pickDate(_startDate ?? DateTime.now());
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await _pickDate(_endDate ?? DateTime.now());
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<DateTime?> _pickDate(DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
  }

  Future<void> _save() async {
    final price = double.tryParse(_price.text.trim());
    if (_roomId == null ||
        _startDate == null ||
        _endDate == null ||
        price == null) {
      setState(() => _error = 'Thong tin lich gia khong hop le.');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      setState(() => _error = 'Ngay ket thuc phai sau ngay bat dau.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final body = {
      'room': {'id': _roomId},
      'startDate': _instant(_startDate!),
      'endDate': _instant(_endDate!),
      'price': price,
      'active': _active,
    };
    try {
      final id = intValue(widget.slot?['id']);
      if (id <= 0) {
        await _api.createTimeSlot(body);
      } else {
        await _api.updateTimeSlot(id, body);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.slot == null ? 'Them lich gia' : 'Sua lich gia'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
            ],
            DropdownButtonFormField<int>(
              initialValue: _roomId,
              decoration: const InputDecoration(labelText: 'Phong'),
              items: widget.rooms
                  .map(
                    (room) => DropdownMenuItem(
                      value: intValue(room['id']),
                      child: Text('Phong ${textValue(room['roomNumber'])}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _roomId = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStart,
                    child: Text('Bat dau: ${formatDate(_startDate)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEnd,
                    child: Text('Ket thuc: ${formatDate(_endDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Gia ap dung'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _active,
              onChanged: (value) => setState(() => _active = value),
              title: const Text('Dang kich hoat'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Huy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Luu'),
        ),
      ],
    );
  }

  DateTime? _parseDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '')?.toLocal();

  String _instant(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
    ).toUtc().toIso8601String();
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(child: Text(message)),
      ),
    );
  }
}
