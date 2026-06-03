import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/language_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _language = LanguageService();

  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  bool get _isCustomer {
    final roles = ApiService().currentSession?.roles ?? const <String>[];
    return roles.any(
      (role) => role.toLowerCase().replaceFirst('role_', '') == 'customer',
    );
  }

  @override
  void initState() {
    super.initState();
    _language.addListener(_refreshLanguage);
  }

  @override
  void dispose() {
    _language.removeListener(_refreshLanguage);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _refreshLanguage() {
    if (mounted) setState(() {});
  }

  Future<void> _savePassword() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!ApiService().isAuthenticated) {
      setState(() {
        _errorMessage = _language.t('changePassword.loginRequired');
      });
      return;
    }
    if (!_isCustomer) {
      setState(() {
        _errorMessage = _language.t('changePassword.customerOnly');
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ApiService().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_language.t('changePassword.success'))),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePageScaffold(
      mobileBody: Column(
        children: [
          _buildMobileHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: _buildContentPanel(),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: _language.t('changePassword.title'),
        subtitle: _language.t('changePassword.subtitle'),
        selectedIndex: 4,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: WebPanel(child: _buildContentPanel()),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              _language.t('changePassword.title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContentPanel() {
    final blockedMessage = !ApiService().isAuthenticated
        ? _language.t('changePassword.loginRequired')
        : !_isCustomer
            ? _language.t('changePassword.customerOnly')
            : null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (blockedMessage != null) ...[
            _buildMessageBox(blockedMessage),
            const SizedBox(height: 16),
          ],
          if (_errorMessage != null) ...[
            _buildMessageBox(_errorMessage!, isError: true),
            const SizedBox(height: 16),
          ],
          _buildPasswordField(
            controller: _currentPasswordController,
            label: _language.t('changePassword.current'),
            obscureText: _obscureCurrent,
            onToggle: () {
              setState(() {
                _obscureCurrent = !_obscureCurrent;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _language.t('changePassword.currentRequired');
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _newPasswordController,
            label: _language.t('changePassword.new'),
            obscureText: _obscureNew,
            onToggle: () {
              setState(() {
                _obscureNew = !_obscureNew;
              });
            },
            validator: _validateNewPassword,
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: _language.t('changePassword.confirm'),
            obscureText: _obscureConfirm,
            onToggle: () {
              setState(() {
                _obscureConfirm = !_obscureConfirm;
              });
            },
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed:
                  _isSaving || blockedMessage != null ? null : _savePassword,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_reset_outlined, size: 18),
              label: Text(
                _isSaving
                    ? _language.t('changePassword.saving')
                    : _language.t('changePassword.save'),
              ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.colorPrimary),
        ),
      ),
    );
  }

  Widget _buildMessageBox(String message, {bool isError = false}) {
    final color = isError ? Colors.red : AppColors.colorPrimary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String? _validateNewPassword(String? value) {
    final password = value ?? '';
    if (password.trim().isEmpty) {
      return _language.t('changePassword.newRequired');
    }
    final strongPassword = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    if (!strongPassword.hasMatch(password)) {
      return _language.t('changePassword.strong');
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _language.t('changePassword.confirmRequired');
    }
    if (value != _newPasswordController.text) {
      return _language.t('changePassword.mismatch');
    }
    return null;
  }
}
