import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/api_service.dart';
import '../utils/colors.dart';
import 'widgets/responsive_page.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!ApiService().isAuthenticated) {
      final session = ApiService().currentSession;
      _emailController.text = session?.email ?? '';
      _isLoading = false;
      _errorMessage = 'Ban can dang nhap de chinh sua ho so.';
      setState(() {});
      return;
    }

    try {
      final profile = await ApiService().fetchCurrentUser();
      if (!mounted) return;
      _applyProfile(profile);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _applyProfile(Map<String, dynamic> profile) {
    _firstNameController.text = _textValue(profile['firstName']);
    _lastNameController.text = _textValue(profile['lastName']);
    _emailController.text = _textValue(profile['email']);
    _phoneController.text = _textValue(profile['phone']);
    _avatarUrlController.text = _textValue(profile['avatarUrl']);
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final profile = await ApiService().updateCurrentUser(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        avatarUrl: _avatarUrlController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da cap nhat ho so')),
      );
      Navigator.of(context).pop(profile);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isSaving = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (!ApiService().isAuthenticated || _isUploadingAvatar) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: false,
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;

    setState(() {
      _isUploadingAvatar = true;
      _errorMessage = null;
    });

    try {
      final profile = await ApiService().uploadCurrentUserAvatar(
        bytes: bytes,
        fileName: file.name,
      );
      if (!mounted) return;
      _applyProfile(profile);
      setState(() {
        _isUploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da upload anh dai dien')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isUploadingAvatar = false;
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
              child: _buildFormPanel(),
            ),
          ),
        ],
      ),
      desktopBody: WebAppShell(
        title: 'Edit Profile',
        subtitle: 'Cap nhat ten, so dien thoai va anh dai dien cua customer.',
        selectedIndex: 4,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: WebPanel(child: _buildFormPanel()),
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
          const Expanded(
            child: Text(
              'Chinh sua ho so',
              textAlign: TextAlign.center,
              style: TextStyle(
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

  Widget _buildFormPanel() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 42),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatarPreview(),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            _buildErrorBox(_errorMessage!),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  label: 'Ho',
                  icon: Icons.badge_outlined,
                  validator: (value) => _required(value, 'ho'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'Ten',
                  icon: Icons.person_outline,
                  validator: (value) => _required(value, 'ten'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            enabled: false,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            label: 'So dien thoai',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _avatarUrlController,
            label: 'Avatar URL',
            icon: Icons.image_outlined,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: ApiService().isAuthenticated && !_isUploadingAvatar
                  ? _pickAndUploadAvatar
                  : null,
              icon: _isUploadingAvatar
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_outlined, size: 18),
              label: Text(
                _isUploadingAvatar
                    ? 'Dang upload anh'
                    : 'Upload anh tu thiet bi',
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
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isSaving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Huy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.divider),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ||
                          _isUploadingAvatar ||
                          !ApiService().isAuthenticated
                      ? null
                      : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(_isSaving ? 'Dang luu' : 'Luu thay doi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final avatarUrl = _avatarUrlController.text.trim();

    return Row(
      children: [
        ClipOval(
          child: Container(
            width: 76,
            height: 76,
            color: AppColors.colorPrimary.withValues(alpha: 0.12),
            child: avatarUrl.isEmpty
                ? const Icon(
                    Icons.person,
                    color: AppColors.colorPrimary,
                    size: 42,
                  )
                : Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      color: AppColors.colorPrimary,
                      size: 42,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anh dai dien',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _emailController.text.isEmpty
                    ? 'Dang cap nhat thong tin customer'
                    : _emailController.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) {
        if (controller == _avatarUrlController) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: enabled ? AppColors.white : AppColors.colorBg,
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

  Widget _buildErrorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
    );
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui long nhap $fieldName';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final requiredMessage = _required(value, 'so dien thoai');
    if (requiredMessage != null) return requiredMessage;

    final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) {
      return 'So dien thoai khong hop le';
    }
    return null;
  }

  String _textValue(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? '' : text;
  }
}
