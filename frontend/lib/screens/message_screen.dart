import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/chat_socket.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 1;
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;
  String? _error;
  ChatSocketConnection? _socket;
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _socketSubscription?.cancel();
    _socket?.close();
    super.dispose();
  }

  Future<void> _init() async {
    final restored = await _api.restoreSession();
    if (!restored || !_api.isAuthenticated) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Vui lòng đăng nhập để sử dụng tin nhắn.';
      });
      return;
    }

    _connectSocket();
    await _loadConversations();
  }

  void _connectSocket() {
    final token = _api.currentSession?.accessToken;
    if (token == null || token.trim().isEmpty || _socket != null) {
      return;
    }

    final socket = connectChatSocket(
      socketUrl: AppConstants.chatWebSocketUrl,
      accessToken: token,
    );
    _socket = socket;
    _socketSubscription = socket.messages.listen(
      (_) => unawaited(_loadConversations(silent: true)),
      onError: (_) {},
    );
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final conversations = await _api.fetchChatConversations();
      if (!mounted) return;
      setState(() {
        _conversations = conversations.where(_hasConversationMessages).toList();
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không tải được hộp thư: $error';
      });
    }
  }

  List<Map<String, dynamic>> get _filteredConversations {
    final keyword = _searchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return _conversations;
    return _conversations.where((conversation) {
      final name = conversation['name']?.toString().toLowerCase() ?? '';
      final email = conversation['email']?.toString().toLowerCase() ?? '';
      return name.contains(keyword) || email.contains(keyword);
    }).toList();
  }

  int get _unreadCount {
    return _conversations.fold<int>(
      0,
      (total, conversation) => total + _intValue(conversation['unread']),
    );
  }

  void _openConversation(Map<String, dynamic> conversation) async {
    await Navigator.of(context).pushNamed(
      '/message-chat',
      arguments: conversation,
    );
    await _loadConversations(silent: true);
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
          _buildMobileHeader(context),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildMobileTitleArea()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: _buildMobileConversationList(),
                ),
              ],
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: 'Tin nhắn',
        subtitle:
            'Trao đổi với khách sạn và bộ phận hỗ trợ, theo dõi tin nhắn chưa đọc và mở nhanh từng cuộc trò chuyện.',
        selectedIndex: 1,
        child: _buildDesktopContent(),
      ),
      mobileBottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          child: _buildControlPanel(),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildConversationPanel(),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hộp thư',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tìm liên hệ, kiểm tra tin chưa đọc và làm mới danh sách hội thoại.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          _buildSearchField(),
          const SizedBox(height: 18),
          _buildSummaryTile(
            icon: Icons.forum_outlined,
            label: 'Liên hệ',
            value: '${_conversations.length}',
            color: AppColors.colorPrimary,
          ),
          const SizedBox(height: 12),
          _buildSummaryTile(
            icon: Icons.mark_email_unread_outlined,
            label: 'Chưa đọc',
            value: '$_unreadCount',
            color: const Color(0xFFD97706),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _loading ? null : _loadConversations,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Tải lại tin nhắn',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.colorPrimary,
                side: const BorderSide(color: AppColors.colorPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationPanel() {
    final conversations = _filteredConversations;

    return WebPanel(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Danh sách hội thoại',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildConversationContent(conversations, desktop: true),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const StaySmartBrandButton(
            showLogo: false,
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.colorPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/notification',
                ),
                icon: const Icon(Icons.notifications_none),
                color: AppColors.textPrimary,
              ),
              CurrentUserAvatar(
                size: 34,
                onTap: () => Navigator.of(context).pushNamed('/user-profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTitleArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tin nhắn',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loading ? null : _loadConversations,
                icon: const Icon(Icons.refresh),
                color: AppColors.colorPrimary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Theo dõi các cuộc trò chuyện với khách sạn và hỗ trợ.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _buildSearchField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.forum_outlined,
                  label: 'Liên hệ',
                  value: '${_conversations.length}',
                  color: AppColors.colorPrimary,
                  compact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  icon: Icons.mark_email_unread_outlined,
                  label: 'Chưa đọc',
                  value: '$_unreadCount',
                  color: const Color(0xFFD97706),
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileConversationList() {
    final conversations = _filteredConversations;

    if (_loading || _error != null || conversations.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildConversationContent(conversations, desktop: false),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == conversations.length - 1 ? 0 : 12,
            ),
            child: _buildConversationCard(conversations[index]),
          );
        },
        childCount: conversations.length,
      ),
    );
  }

  Widget _buildConversationContent(
    List<Map<String, dynamic>> conversations, {
    required bool desktop,
  }) {
    if (_loading) {
      return SizedBox(
        height: desktop ? 260 : 220,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return _buildStateMessage(
        icon: Icons.error_outline,
        title: 'Không tải được tin nhắn',
        message: _error!,
        actionLabel: 'Thử lại',
        onAction: _loadConversations,
      );
    }

    if (conversations.isEmpty) {
      return _buildStateMessage(
        icon: Icons.chat_bubble_outline,
        title: 'Không có cuộc trò chuyện',
        message: 'Không có cuộc trò chuyện',
      );
    }

    if (!desktop) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (var index = 0; index < conversations.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == conversations.length - 1 ? 0 : 12,
            ),
            child: _buildConversationCard(conversations[index]),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên hoặc email',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.iconMuted,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.colorPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: compact ? 18 : 22),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 18 : 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateMessage({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    Future<void> Function()? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: () => unawaited(onAction()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorPrimary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation) {
    final unread = _intValue(conversation['unread']);
    final lastMessage = conversation['message']?.toString() ?? '';
    final name = conversation['name']?.toString() ?? 'Liên hệ';
    final email = conversation['email']?.toString() ?? '';
    final time = conversation['time']?.toString() ?? '';

    return InkWell(
      onTap: () => _openConversation(conversation),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unread > 0
                ? AppColors.colorPrimary.withValues(alpha: 0.32)
                : AppColors.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(name),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (time.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage.isEmpty
                              ? 'Bắt đầu trò chuyện'
                              : lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: unread > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                                unread > 0 ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          constraints: const BoxConstraints(minWidth: 24),
                          height: 24,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            borderRadius:
                                BorderRadius.all(Radius.circular(999)),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initials = _initials(name);
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2E6FAF), Color(0xFF48BFAA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w900,
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
        unselectedItemColor: AppColors.textPrimary,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  bool _hasConversationMessages(Map<String, dynamic> conversation) {
    if (conversation['lastMessageAt'] is DateTime) return true;
    final message = conversation['message']?.toString().trim() ?? '';
    return message.isNotEmpty && message != 'Bat dau tro chuyen';
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
