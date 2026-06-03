import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  final ApiService _api = ApiService();
  int _selectedIndex = 4;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _cards = [];

  Map<String, dynamic>? get _defaultCard {
    for (final card in _cards) {
      if (card['defaultCard'] == true) return card;
    }
    return _cards.isEmpty ? null : _cards.first;
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.restoreSession();
      final cards = await _api.fetchPaymentCards();
      if (!mounted) return;
      setState(() {
        _cards = cards;
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

  Future<void> _openAddCard() async {
    final saved = await Navigator.of(context).pushNamed('/add-card');
    if (saved == true) {
      await _loadCards();
    }
  }

  Future<void> _setDefaultCard(Map<String, dynamic> card) async {
    final id = _intValue(card['id']);
    if (id == null || card['defaultCard'] == true) return;
    try {
      await _api.setDefaultPaymentCard(id);
      await _loadCards();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _deleteCard(Map<String, dynamic> card) async {
    final id = _intValue(card['id']);
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa the thanh toan?'),
        content:
            Text('The ${_textValue(card, 'number')} se bi xoa khoi tai khoan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.deletePaymentCard(id);
      await _loadCards();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
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
              onRefresh: _loadCards,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
                child: Column(
                  children: [
                    _buildTitleRow(context, 'Credit Card'),
                    const SizedBox(height: 22),
                    _buildMobileCards(),
                  ],
                ),
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
      title: 'Payment Cards',
      subtitle:
          'Quan ly the thanh toan da luu, them the moi va kiem tra trang thai bao mat tai khoan.',
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final summaryPanel = _buildDesktopSummaryPanel(context);
          final cardsPanel = _buildDesktopCardsPanel(context);

          if (stackPanels) {
            return Column(
              children: [
                summaryPanel,
                const SizedBox(height: 18),
                cardsPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: summaryPanel),
              const SizedBox(width: 24),
              Expanded(child: cardsPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileCards() {
    if (_loading || _error != null || _cards.isEmpty) {
      return _buildStateContent();
    }

    return Column(
      children: [
        for (final card in _cards) ...[
          _buildCardTile(card: card),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerRight,
          child: _buildAddButton(context),
        ),
      ],
    );
  }

  Widget _buildDesktopSummaryPanel(BuildContext context) {
    final defaultCard = _defaultCard;
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
              Icons.credit_card,
              color: AppColors.colorPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'The da luu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_cards.length} the dang kha dung cho thanh toan dat phong.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _buildSummaryTile(
            icon: Icons.verified_user_outlined,
            label: 'Bao mat',
            value: 'Chi luu metadata',
          ),
          const SizedBox(height: 10),
          _buildSummaryTile(
            icon: Icons.payments_outlined,
            label: 'Mac dinh',
            value: defaultCard == null
                ? 'Chua co'
                : '${_textValue(defaultCard, 'brand')} ${_textValue(defaultCard, 'number')}',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _openAddCard,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Them the moi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
                elevation: 0,
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

  Widget _buildDesktopCardsPanel(BuildContext context) {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh sach the',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Tai lai',
                onPressed: _loadCards,
                icon: const Icon(Icons.refresh),
              ),
              TextButton.icon(
                onPressed: _openAddCard,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add card'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_loading || _error != null || _cards.isEmpty)
            _buildStateContent()
          else
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                for (final card in _cards)
                  _buildCardTile(card: card, wide: true),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStateContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final hasError = _error != null;
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
          Icon(
            hasError ? Icons.error_outline : Icons.credit_card_off_outlined,
            color: AppColors.colorPrimary,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            hasError
                ? 'Khong tai duoc danh sach the'
                : 'Chua co the thanh toan',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasError ? _error! : 'Bam Add card de luu the moi vao backend.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          if (hasError)
            OutlinedButton(onPressed: _loadCards, child: const Text('Thu lai'))
          else
            ElevatedButton.icon(
              onPressed: _openAddCard,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorPrimary,
                foregroundColor: AppColors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardTile({
    required Map<String, dynamic> card,
    bool wide = false,
  }) {
    return Container(
      width: wide ? 344 : double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.colorBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentCard(card,
              width: wide ? 320 : 292, height: wide ? 198 : 180),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _textValue(card, 'brand'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (card['defaultCard'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.colorPrimary,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => _setDefaultCard(card),
                  child: const Text('Set default'),
                ),
              IconButton(
                tooltip: 'Xoa the',
                onPressed: () => _deleteCard(card),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _textValue(card, 'number'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.colorBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
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

  Widget _buildTitleRow(BuildContext context, String title) {
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
        Expanded(
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
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
          onPressed: _loadCards,
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
    Map<String, dynamic> card, {
    double width = 292,
    double height = 180,
  }) {
    final colors = _colorsValue(card);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _textValue(card, 'brand'),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.credit_card, color: Color(0xFFD7D5FF), size: 40),
          const SizedBox(height: 12),
          Text(
            _textValue(card, 'displayNumber'),
            style: const TextStyle(
              color: Color(0xFFD7D5FF),
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _textValue(card, 'expiry'),
            style: const TextStyle(color: AppColors.white, fontSize: 9),
          ),
          const Spacer(),
          Text(
            _textValue(card, 'holder').toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return OutlinedButton(
      onPressed: _openAddCard,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: const BorderSide(color: AppColors.colorPrimary),
        padding: const EdgeInsets.all(10),
      ),
      child: const Icon(Icons.add, color: AppColors.colorPrimary, size: 28),
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
      child: const Icon(
        Icons.notifications_none,
        size: 22,
        color: AppColors.textPrimary,
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

  List<Color> _colorsValue(Map<String, dynamic> data) {
    final value = data['colors'];
    if (value is List<Color> && value.length >= 2) return value;
    return const [Color(0xFF201A59), Color(0xFF4B3DA3)];
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
