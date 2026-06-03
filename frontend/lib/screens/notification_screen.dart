import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _api = ApiService();
  int _selectedIndex = 0;
  bool _loading = true;
  bool _markingRead = false;
  final Set<int> _readingIds = <int>{};
  String? _error;
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _deals = [];
  List<Map<String, dynamic>> _messages = [];

  int get _unreadCount {
    final unreadNotifications =
        _notifications.where((item) => item['read'] != true).length;
    final unreadMessages = _messages.fold<int>(
      0,
      (total, item) => total + (_intValue(item['unread']) ?? 0),
    );
    return unreadNotifications + unreadMessages;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.restoreSession();
      final results = await Future.wait([
        _api.fetchNotifications(),
        _api.fetchCoupons(),
        _api.fetchChatConversations(),
      ]);
      if (!mounted) return;
      setState(() {
        _notifications = results[0];
        _deals = results[1];
        _messages = results[2];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    if (_markingRead) return;
    setState(() {
      _markingRead = true;
    });
    try {
      await _api.markAllNotificationsRead();
      await _loadData();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _markingRead = false;
        });
      }
    }
  }

  Future<void> _markOneRead(Map<String, dynamic> notification) async {
    final id = _intValue(notification['id']);
    if (id == null ||
        notification['read'] == true ||
        _readingIds.contains(id)) {
      return;
    }
    setState(() => _readingIds.add(id));
    try {
      await _api.markNotificationRead(id);
      if (!mounted) return;
      setState(() => notification['read'] = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _readingIds.remove(id));
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushNamed('/message');
        break;
      case 2:
        Navigator.of(context).pushNamed('/booking');
        break;
      case 3:
        Navigator.of(context).pushNamed('/search');
        break;
      case 4:
        Navigator.of(context).pushNamed('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
                child: _buildMobileContent(context),
              ),
            ),
          ),
        ],
      ),
      desktopBody: _buildDesktopPage(context),
      mobileBottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDesktopPage(BuildContext context) {
    return WebAppShell(
      title: 'Notification',
      subtitle:
          'Theo doi uu dai moi, tin nhan khach san va cac cap nhat quan trong tu StaySmart.',
      selectedIndex: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final summaryPanel = _buildDesktopSummaryPanel();
          final contentPanel = _buildDesktopContentPanel();

          if (stackPanels) {
            return Column(
              children: [
                summaryPanel,
                const SizedBox(height: 18),
                contentPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: summaryPanel),
              const SizedBox(width: 24),
              Expanded(child: contentPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context),
        const SizedBox(height: 18),
        if (_loading || _error != null)
          _buildStateContent()
        else ...[
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Thong bao cua ban',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: _markingRead ? null : _markAllRead,
                child: Text(_markingRead ? 'Dang xu ly...' : 'Doc tat ca'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotificationsList(),
          const SizedBox(height: 20),
          const Text(
            'Uu dai',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildDealsList(),
          const SizedBox(height: 18),
          const Text(
            'Tin nhan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMessagesCard(),
        ],
      ],
    );
  }

  Widget _buildDesktopSummaryPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.colorPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Trung tam thong bao',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Du lieu duoc lay tu notifications, coupons va messages tren backend.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _buildSummaryTile(
            icon: Icons.notifications_none,
            label: 'Thong bao',
            value: '${_notifications.length}',
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 10),
          _buildSummaryTile(
            icon: Icons.local_offer_outlined,
            label: 'Uu dai',
            value: '${_deals.length}',
            color: AppColors.colorPrimary,
          ),
          const SizedBox(height: 10),
          _buildSummaryTile(
            icon: Icons.mail_outline,
            label: 'Tin nhan',
            value: '${_messages.length}',
            color: const Color(0xFF22C55E),
          ),
          const SizedBox(height: 10),
          _buildSummaryTile(
            icon: Icons.mark_email_unread_outlined,
            label: 'Chua doc',
            value: '$_unreadCount',
            color: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContentPanel() {
    if (_loading || _error != null) {
      return WebPanel(child: _buildStateContent());
    }

    return Column(
      children: [
        WebPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Thong bao cua ban',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _markingRead ? null : _markAllRead,
                    child: Text(
                      _markingRead ? 'Dang xu ly...' : 'Danh dau da doc',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tai lai',
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNotificationsList(wide: true),
            ],
          ),
        ),
        const SizedBox(height: 18),
        WebPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uu dai moi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildDealsList(wide: true),
            ],
          ),
        ),
        const SizedBox(height: 18),
        WebPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tin nhan gan day',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildMessagesCard(wide: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStateContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.colorPrimary),
          const SizedBox(height: 10),
          const Text(
            'Khong tai duoc thong bao',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: _loadData, child: const Text('Thu lai')),
        ],
      ),
    );
  }

  Widget _buildNotificationsList({bool wide = false}) {
    if (_notifications.isEmpty) {
      return _buildEmptyCard('Ban chua co thong bao nao.');
    }

    return Column(
      children: [
        for (var index = 0; index < _notifications.length; index++) ...[
          _buildNotificationItem(_notifications[index], wide: wide),
          if (index < _notifications.length - 1)
            SizedBox(height: wide ? 10 : 12),
        ],
      ],
    );
  }

  Widget _buildNotificationItem(
    Map<String, dynamic> notification, {
    bool wide = false,
  }) {
    final id = _intValue(notification['id']);
    final read = notification['read'] == true;
    final busy = id != null && _readingIds.contains(id);
    final palette = _colorsValue(notification);
    return Material(
      color: read ? AppColors.white : palette.first.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: read || busy ? null : () => _markOneRead(notification),
        child: Container(
          padding: EdgeInsets.all(wide ? 16 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: read
                  ? AppColors.divider
                  : palette.first.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: wide ? 48 : 42,
                height: wide ? 48 : 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: palette),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconValue(notification),
                  color: AppColors.white,
                  size: wide ? 24 : 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _textValue(notification, 'title'),
                            style: TextStyle(
                              fontSize: wide ? 14 : 13,
                              fontWeight:
                                  read ? FontWeight.w700 : FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.colorPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _textValue(notification, 'message'),
                      maxLines: wide ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          _textValue(notification, 'time'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (!read)
                          Text(
                            busy ? 'Dang xu ly...' : 'Cham de danh dau da doc',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.colorPrimary,
                            ),
                          ),
                      ],
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

  Widget _buildDealsList({bool wide = false}) {
    if (_deals.isEmpty) {
      return _buildEmptyCard('Chua co uu dai dang hoat dong.');
    }

    if (!wide) {
      return Column(
        children: [
          for (final deal in _deals) ...[
            _buildDealCard(deal),
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final spacing = columns == 2 ? 14.0 : 0.0;
        final itemWidth = (constraints.maxWidth - spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (final deal in _deals)
              SizedBox(
                width: itemWidth,
                child: _buildDealCard(deal, wide: true),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const StaySmartBrandButton(),
          const Spacer(),
          _buildBellButton(context),
          const SizedBox(width: 18),
          const Icon(
            Icons.settings_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/user-profile'),
            child: _buildAvatar(size: 34),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 40),
        const Expanded(
          child: Center(
            child: Text(
              'Notification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.refresh,
            size: 18,
            color: AppColors.colorPrimary,
          ),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildDealCard(
    Map<String, dynamic> deal, {
    bool wide = false,
  }) {
    final colors = _colorsValue(deal);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(wide ? 14 : 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Container(
              width: wide ? 84 : 72,
              height: wide ? 82 : 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                _iconValue(deal),
                size: wide ? 38 : 34,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _textValue(deal, 'title'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: wide ? 13 : 11,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _textValue(deal, 'description'),
                  maxLines: wide ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: wide ? 11 : 10,
                    height: 1.25,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _textValue(deal, 'code'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesCard({bool wide = false}) {
    if (_messages.isEmpty) {
      return _buildEmptyCard('Chua co tin nhan gan day.');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: wide ? Border.all(color: AppColors.divider) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (var index = 0; index < _messages.length; index++) ...[
            _buildMessageItem(_messages[index], wide: wide),
            if (index < _messages.length - 1)
              const Divider(
                height: 1,
                indent: 70,
                endIndent: 12,
                color: AppColors.divider,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    Map<String, dynamic> message, {
    bool wide = false,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        '/message-chat',
        arguments: message,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, wide ? 12 : 9, 12, wide ? 12 : 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: wide ? 50 : 46,
                  height: wide ? 50 : 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF0F2F5),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.iconMuted,
                    size: 22,
                  ),
                ),
                if ((_intValue(message['unread']) ?? 0) > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.colorPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_intValue(message['unread'])}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _textValue(message, 'name'),
                          style: TextStyle(
                            fontSize: wide ? 14 : 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _textValue(message, 'time'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _textValue(message, 'message'),
                    maxLines: wide ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.colorPrimary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  Widget _buildBellButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/notification'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 22,
            color: AppColors.textPrimary,
          ),
          if (_unreadCount > 0)
            Positioned(
              right: -2,
              top: -4,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildAvatar({required double size}) {
    return CurrentUserAvatar(size: size);
  }

  String _textValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString();
  }

  IconData _iconValue(Map<String, dynamic> data) {
    final value = data['icon'];
    if (value is IconData) return value;
    return Icons.notifications_none;
  }

  List<Color> _colorsValue(Map<String, dynamic> data) {
    final value = data['colors'];
    if (value is List<Color> && value.length >= 2) return value;
    return const [Color(0xFFE9C088), Color(0xFFB95D34)];
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
