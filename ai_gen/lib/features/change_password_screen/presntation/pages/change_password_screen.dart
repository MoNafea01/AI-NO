// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/features/change_password_screen/presntation/widgets/build_requirements.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = 'Very weak';
  Color _passwordStrengthColor = Colors.red;

  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = 0.0;
        _passwordStrengthText = 'Very weak';
        _passwordStrengthColor = Colors.red;
        return;
      }

      // Check password strength
      bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
      bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      bool hasMinLength = password.length >= 8;

      if (hasLetter && hasDigit && hasSpecial && hasMinLength) {
        _passwordStrength = 1.0;
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      } else if ((hasLetter && hasDigit) ||
          (hasLetter && hasSpecial) ||
          (hasDigit && hasSpecial)) {
        _passwordStrength = 0.66;
        _passwordStrengthText = 'Medium';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = 0.33;
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      }
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Make sure new password and confirm password match
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("New password and confirmation must match")),
        );
        setState(() => _isLoading = false);
        return;
      }

      bool success = await context.read<AuthProvider>().changePassword(
            oldPassword: _oldPasswordController.text.trim(),
            newPassword: _newPasswordController.text.trim(),
            context: context,
          );

      if (success) {
        // Show success message with custom style
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Password changed successfully"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context); // Only return to previous screen on success
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text("Error: ${e.toString()}")),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Change Password",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security icon and headline
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock_outline,
                            size: 48, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        "Secure Your Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Keep your account safe with a strong password",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Current password field
                    const Text(
                      "CURRENT PASSWORD",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 8),
                    _buildPasswordField(
                      label: 'Enter your current password',
                      controller: _oldPasswordController,
                      obscureText: _obscureOld,
                      onToggleVisibility: () {
                        setState(() => _obscureOld = !_obscureOld);
                      },
                      icon: Icons.vpn_key_outlined,
                    ),
                    const SizedBox(height: 24),

                    // New password section
                    const Text(
                      "NEW PASSWORD",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      label: 'Enter new password',
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      onToggleVisibility: () {
                        setState(() => _obscureNew = !_obscureNew);
                      },
                      icon: Icons.lock_outline,
                      onChanged: _checkPasswordStrength,
                    ),
                    const SizedBox(height: 8),

                    // Password strength indicator
                    if (_newPasswordController.text.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _passwordStrengthColor),
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _passwordStrengthText,
                            style: TextStyle(
                              fontSize: 12,
                              color: _passwordStrengthColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Password requirements
                      const Text(
                        "Your password should:",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      buildRequirement(
                        "Be at least 8 characters",
                        _newPasswordController.text.length >= 8,
                      ),
                      buildRequirement(
                        "Include letters",
                        RegExp(r'[a-zA-Z]')
                            .hasMatch(_newPasswordController.text),
                      ),
                      buildRequirement(
                        "Include numbers",
                        RegExp(r'[0-9]').hasMatch(_newPasswordController.text),
                      ),
                      buildRequirement(
                        "Include special characters (!@#\$%^&*)",
                        RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                            .hasMatch(_newPasswordController.text),
                      ),
                      const SizedBox(height: 16),
                    ] else
                      const SizedBox(height: 8),

                    // Confirm password field
                    const Text(
                      "CONFIRM PASSWORD",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      label: 'Confirm new password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      onToggleVisibility: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // primary: primaryColor,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "UPDATE PASSWORD",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    IconData? icon,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, color: Theme.of(context).primaryColor)
              : null,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
            onPressed: onToggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          if (controller == _confirmPasswordController &&
              value != _newPasswordController.text) {
            return 'Passwords do not match';
          }
          if (controller == _newPasswordController && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }
}
