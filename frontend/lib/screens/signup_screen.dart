import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';
import '../utils/strings.dart';
import 'widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields');
      return;
    }

    if (!_isValidUsername(username)) {
      _showMessage(
        'Username must be 4-20 characters and use only letters, numbers, or underscores.',
      );
      return;
    }

    if (!_isStrongPassword(password)) {
      _showMessage(
        'Password must be at least 8 characters and include uppercase, lowercase, number, and special character.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService().register(
        fullName: name,
        username: username,
        email: email,
        password: password,
      );
      if (!mounted) return;
      _goToHome();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not connect to backend. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleGoogleSignUp() {
    _showMessage('Google sign up is not connected on the backend yet.');
  }

  void _goToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  bool _isValidUsername(String value) {
    return RegExp(r'^[A-Za-z0-9_]{4,20}$').hasMatch(value);
  }

  bool _isStrongPassword(String value) {
    return RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    ).hasMatch(value);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.colorBg,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 56, bottom: 24),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.divider,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      AppStrings.signUp,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.signUpSubtitle,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          // Name Field
                          CustomTextField(
                            label: AppStrings.nameLabel,
                            hint: AppStrings.nameSubtitle,
                            icon: Icons.person_outline,
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            label: AppStrings.usernameLabel,
                            hint: AppStrings.usernameHint,
                            icon: Icons.alternate_email,
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          CustomTextField(
                            label: AppStrings.emailLabel,
                            hint: AppStrings.emailHint,
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          CustomTextField(
                            label: AppStrings.passwordLabel,
                            hint: AppStrings.passwordHint,
                            icon: Icons.lock_outlined,
                            controller: _passwordController,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onTogglePassword: _togglePasswordVisibility,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colorPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 1,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Google Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _handleGoogleSignUp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          backgroundColor:
                              const Color.fromARGB(255, 230, 233, 238)
                                  .withValues(),
                          side: const BorderSide(
                            color: AppColors.divider,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_translate,
                                size: 20,
                                color: AppColors
                                    .colorPrimary), // Reusing existing icon style
                            SizedBox(width: 8),
                            Text(
                              AppStrings.signUpWithGoogle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Terms and Conditions Footer
                    const Column(
                      children: [
                        Text(
                          'By signing up you agree to our',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Terms ',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'and ',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Conditions of Use',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
