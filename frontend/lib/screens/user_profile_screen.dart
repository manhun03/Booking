import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/language_service.dart';
import '../utils/colors.dart';
import 'widgets/current_user_avatar.dart';
import 'widgets/responsive_page.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final LanguageService _language = LanguageService();
  int _selectedIndex = 4;
  bool _isLoadingProfile = false;
  bool _isSendingEmailVerification = false;
  String? _profileError;
  Map<String, dynamic>? _profile;

  List<_ProfileMenuItem> get _menuItems => [
        _ProfileMenuItem(
          Icons.home_outlined,
          _language.t('profile.home'),
          route: '/home',
        ),
        _ProfileMenuItem(
          Icons.account_balance_wallet_outlined,
          _language.t('profile.bankAccount'),
        ),
        _ProfileMenuItem(Icons.history, _language.t('profile.history')),
        _ProfileMenuItem(
          Icons.favorite,
          _language.t('profile.favorites'),
          route: '/favorite',
          color: Colors.red,
        ),
        _ProfileMenuItem(
          Icons.credit_card_outlined,
          _language.t('profile.paymentCards'),
          route: '/credit-card',
        ),
        _ProfileMenuItem(
          Icons.notifications_none,
          _language.t('profile.notifications'),
          route: '/notification',
        ),
        _ProfileMenuItem(
          Icons.article_outlined,
          _language.t('profile.language'),
          route: '/language',
        ),
        _ProfileMenuItem(
          Icons.local_offer_outlined,
          _language.t('profile.promotions'),
          route: '/promotion',
        ),
        _ProfileMenuItem(
          Icons.account_balance_outlined,
          _language.t('profile.policies'),
          route: '/legal-policies',
        ),
        if (_isCustomer)
          _ProfileMenuItem(
            Icons.lock_reset_outlined,
            _language.t('profile.changePassword'),
            route: '/change-password',
          ),
      ];

  @override
  void initState() {
    super.initState();
    _language.addListener(_refreshLanguage);
    _loadProfile();
  }

  @override
  void dispose() {
    _language.removeListener(_refreshLanguage);
    super.dispose();
  }

  void _refreshLanguage() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    if (!ApiService().isAuthenticated) {
      if (!mounted) return;
      setState(() {
        _profile = _sessionProfile();
        _isLoadingProfile = false;
      });
      return;
    }

    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await ApiService().fetchCurrentUser();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _profile = _sessionProfile();
        _profileError = error.toString();
        _isLoadingProfile = false;
      });
    }
  }

  Map<String, dynamic> _sessionProfile() {
    final session = ApiService().currentSession;
    return {
      'fullName': session?.fullName ?? 'Customer',
      'email': session?.email ?? '',
      'phone': '',
      'avatarUrl': '',
    };
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).pushNamed('/edit-profile');
    if (!mounted) return;
    if (updated is Map<String, dynamic>) {
      setState(() {
        _profile = updated;
        _profileError = null;
      });
      return;
    }
    await _loadProfile();
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

  void _logout() {
    ApiService().logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _openChangePassword() {
    Navigator.of(context).pushNamed('/change-password');
  }

  Future<void> _sendEmailVerification() async {
    final email = _textValue(_profile?['email']);
    if (!ApiService().isAuthenticated) {
      _showSnack(_language.t('emailVerification.loginRequired'));
      return;
    }
    if (!_isCustomer) {
      _showSnack(_language.t('emailVerification.customerOnly'));
      return;
    }
    if (email.isEmpty || _isSendingEmailVerification) return;

    setState(() {
      _isSendingEmailVerification = true;
      _profileError = null;
    });

    try {
      final response = await ApiService().sendEmailVerification(email: email);
      if (!mounted) return;
      setState(() {
        _isSendingEmailVerification = false;
      });
      _showSnack(_language.t('emailVerification.sendSuccess'));
      await _showEmailVerificationDialog(
        generatedToken: _textValue(response['token']),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSendingEmailVerification = false;
        _profileError = error.toString();
      });
    }
  }

  Future<void> _showEmailVerificationDialog({String? generatedToken}) async {
    final tokenController = TextEditingController(text: generatedToken ?? '');
    var isVerifying = false;
    String? errorMessage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> verify() async {
              final token = tokenController.text.trim();
              if (token.isEmpty) {
                setDialogState(() {
                  errorMessage = _language.t('emailVerification.tokenRequired');
                });
                return;
              }

              setDialogState(() {
                isVerifying = true;
                errorMessage = null;
              });

              try {
                await ApiService().verifyEmail(token: token);
                final profile = await ApiService().fetchCurrentUser();
                if (!mounted) return;
                setState(() {
                  _profile = profile;
                  _profileError = null;
                });
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showSnack(_language.t('emailVerification.success'));
              } catch (error) {
                if (!dialogContext.mounted) return;
                setDialogState(() {
                  isVerifying = false;
                  errorMessage = error.toString();
                });
              }
            }

            return AlertDialog(
              title: Text(_language.t('emailVerification.title')),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_language.t('emailVerification.subtitle')),
                    if (generatedToken != null &&
                        generatedToken.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SelectableText(
                        '${_language.t('emailVerification.generatedToken')}: $generatedToken',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.colorPrimary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: tokenController,
                      decoration: InputDecoration(
                        labelText: _language.t('emailVerification.token'),
                        prefixIcon: const Icon(Icons.verified_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: isVerifying ? null : verify,
                  child: Text(
                    isVerifying
                        ? _language.t('emailVerification.verifying')
                        : _language.t('emailVerification.verify'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    tokenController.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get _isCustomer {
    final roles = ApiService().currentSession?.roles ?? const <String>[];
    return roles.any(
      (role) => role.toLowerCase().replaceFirst('role_', '') == 'customer',
    );
  }

  bool get _emailVerified => _profile?['emailVerified'] == true;

  String get _displayName {
    final name = _textValue(_profile?['fullName']);
    return name.isEmpty ? 'Customer' : name;
  }

  String get _displayEmail {
    final email = _textValue(_profile?['email']);
    return email.isEmpty ? _language.t('profile.missingEmail') : email;
  }

  String get _displayPhone {
    final phone = _textValue(_profile?['phone']);
    return phone.isEmpty ? _language.t('profile.notUpdated') : phone;
  }

  String _textValue(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? '' : text;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      backgroundColor: AppColors.colorBg,
      mobileBody: ColoredBox(
        color: AppColors.colorBg,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleRow(context, _language.t('profile.title')),
                    const SizedBox(height: 18),
                    _buildUserInfoCard(),
                    const SizedBox(height: 28),
                    _buildMenuCard(context),
                    const SizedBox(height: 18),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      desktopBody: _buildDesktopPage(context),
      mobileBottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDesktopPage(BuildContext context) {
    return WebAppShell(
      title: _language.t('profile.accountSettings'),
      subtitle: _language.t('profile.subtitle'),
      selectedIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackPanels = constraints.maxWidth < 920;
          final profilePanel = _buildDesktopProfilePanel();
          final settingsPanel = _buildDesktopSettingsPanel(context);

          if (stackPanels) {
            return Column(
              children: [
                profilePanel,
                const SizedBox(height: 18),
                settingsPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 340, child: profilePanel),
              const SizedBox(width: 24),
              Expanded(child: settingsPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopProfilePanel() {
    return WebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoadingProfile
                          ? _language.t('profile.loading')
                          : _displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _language.t('profile.member'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildProfileStat(
            Icons.bookmark_added_outlined,
            _language.t('profile.bookings'),
            '12',
          ),
          const SizedBox(height: 10),
          _buildProfileStat(
            Icons.favorite_border,
            _language.t('profile.favorites'),
            '8',
          ),
          const SizedBox(height: 10),
          _buildProfileStat(
            Icons.local_offer_outlined,
            _language.t('profile.promotions'),
            '3',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _openEditProfile,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(_language.t('profile.edit')),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 18),
              label: Text(_language.t('profile.logout')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
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

  Widget _buildDesktopSettingsPanel(BuildContext context) {
    return Column(
      children: [
        WebPanel(child: _buildUserInfoCard(compact: false)),
        const SizedBox(height: 18),
        WebPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _language.t('profile.quickSettings'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _language.t('profile.quickSettingsSubtitle'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 2 : 1;
                  final spacing = columns == 2 ? 14.0 : 0.0;
                  final itemWidth =
                      (constraints.maxWidth - spacing) / columns.toDouble();

                  return Wrap(
                    spacing: spacing,
                    runSpacing: 14,
                    children: [
                      for (final item in _menuItems)
                        SizedBox(
                          width: itemWidth,
                          child: _buildDesktopMenuItem(context, item),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStat(IconData icon, String label, String value) {
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.colorPrimary,
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
          _buildAvatar(size: 34),
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
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 28,
          height: 28,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.tune,
              size: 18,
              color: AppColors.colorPrimary,
            ),
            onPressed: _openEditProfile,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard({bool compact = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            _isLoadingProfile ? _language.t('profile.loading') : _displayName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              if (_profileError != null) ...[
                _buildInfoRow(_language.t('profile.status'), _profileError!),
                const Divider(height: 1, color: AppColors.divider),
              ],
              _buildInfoRow(
                _language.t('profile.email'),
                '$_displayEmail • ${_language.t(_emailVerified ? 'profile.emailVerified' : 'profile.emailUnverified')}',
                trailing: _isCustomer && !_emailVerified
                    ? TextButton.icon(
                        onPressed: _isSendingEmailVerification
                            ? null
                            : _sendEmailVerification,
                        icon: _isSendingEmailVerification
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.mark_email_read_outlined),
                        label: Text(
                          _isSendingEmailVerification
                              ? _language.t('profile.sendingVerification')
                              : _language.t('profile.sendVerification'),
                        ),
                      )
                    : Icon(
                        _emailVerified
                            ? Icons.verified_outlined
                            : Icons.error_outline,
                        color: _emailVerified ? Colors.green : Colors.orange,
                        size: 20,
                      ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildInfoRow(_language.t('profile.phone'), _displayPhone),
              const Divider(height: 1, color: AppColors.divider),
              _buildInfoRow(
                _language.t('profile.password'),
                '****************',
                trailing: _isCustomer
                    ? TextButton(
                        onPressed: _openChangePassword,
                        child: Text(_language.t('profile.changePassword')),
                      )
                    : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 8),
                  child: SizedBox(
                    width: compact ? 88 : 132,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: _openEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.colorPrimary,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _language.t('profile.editShort'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    final items = _menuItems;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _buildMenuItem(context, items[index]),
            if (index < items.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _ProfileMenuItem item) {
    return InkWell(
      onTap: () => _openMenuItem(context, item),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 18,
              color: item.color ?? AppColors.textPrimary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopMenuItem(BuildContext context, _ProfileMenuItem item) {
    final color = item.color ?? AppColors.colorPrimary;

    return InkWell(
      onTap: () => _openMenuItem(context, item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _openMenuItem(BuildContext context, _ProfileMenuItem item) {
    if (item.route == null) return;
    Navigator.of(context).pushNamed(item.route!);
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          _language.t('profile.logout'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: _language.t('nav.home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mail_outline),
            activeIcon: const Icon(Icons.mail),
            label: _language.t('nav.message'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            activeIcon: const Icon(Icons.book),
            label: _language.t('nav.booking'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: _language.t('nav.search'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: _language.t('nav.menu'),
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
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
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
    );
  }

  static Widget _buildAvatar({required double size}) {
    return CurrentUserAvatar(size: size);
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem(
    this.icon,
    this.label, {
    this.route,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? route;
  final Color? color;
}
