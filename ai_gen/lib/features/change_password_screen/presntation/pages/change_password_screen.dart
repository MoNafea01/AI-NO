// ignore_for_file: use_build_context_synchronously

import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/features/change_password_screen/presntation/widgets/build_password_field.dart';

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
        // Clear the password fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        setState(() {
          _obscureOld = true;
          _obscureNew = true;
          _obscureConfirm = true;
        });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                buildLabel("Current Password:"),
                buildPasswordField(_oldPasswordController, _obscureOld, () {
                  setState(() => _obscureOld = !_obscureOld);
                }),
                const SizedBox(height: 24),
                buildLabel("Change Password:"),
                buildPasswordField(_newPasswordController, _obscureNew, () {
                  setState(() => _obscureNew = !_obscureNew);
                }),
                const SizedBox(height: 24),
                buildLabel("Confirm Password:"),
                Row(
                  children: [
                    Expanded(
                      child: buildPasswordField(
                          _confirmPasswordController, _obscureConfirm, () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      }),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18),
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
                          : const Text("Confirm",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
