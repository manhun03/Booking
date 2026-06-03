import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/colors.dart';

class CurrentUserAvatar extends StatefulWidget {
  const CurrentUserAvatar({
    super.key,
    required this.size,
    this.borderWidth = 2,
    this.onTap,
  });

  final double size;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  State<CurrentUserAvatar> createState() => _CurrentUserAvatarState();
}

class _CurrentUserAvatarState extends State<CurrentUserAvatar> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _avatarUrl = _avatarFrom(ApiService().cachedUser);
    ApiService().profileVersion.addListener(_syncFromCache);
    _loadAvatar();
  }

  @override
  void dispose() {
    ApiService().profileVersion.removeListener(_syncFromCache);
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    if (!ApiService().isAuthenticated) return;
    try {
      final user = await ApiService().fetchCurrentUser();
      if (!mounted) return;
      setState(() {
        _avatarUrl = _avatarFrom(user);
      });
    } catch (_) {
      // Keep the fallback icon when the profile cannot be loaded.
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white,
            width: widget.borderWidth,
          ),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6D4C41),
              Color(0xFFD7A86E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _avatarUrl == null
            ? Icon(
                Icons.person,
                size: widget.size * 0.58,
                color: AppColors.white,
              )
            : Image.network(
                _avatarUrl!,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  size: widget.size * 0.58,
                  color: AppColors.white,
                ),
              ),
      ),
    );

    if (widget.onTap == null) {
      return avatar;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: avatar,
    );
  }

  void _syncFromCache() {
    if (!mounted) return;
    setState(() {
      _avatarUrl = _avatarFrom(ApiService().cachedUser);
    });
  }

  String? _avatarFrom(Map<String, dynamic>? user) {
    final value = user?['avatarUrl']?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }
}
