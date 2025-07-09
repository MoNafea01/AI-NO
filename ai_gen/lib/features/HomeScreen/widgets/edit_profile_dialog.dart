// ignore_for_file: use_build_context_synchronously

import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileDialog extends StatefulWidget {
  final dynamic profile;
  final String? currentBio;
  final String? updatedUsername;
  final String? updatedFirstName;
  final String? updatedLastName;
  final String? updatedEmail;

  const EditProfileDialog(
      {required this.profile,
      this.currentBio,
      this.updatedUsername,
      this.updatedFirstName,
      this.updatedLastName,
      this.updatedEmail,
      super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use updated values if provided, otherwise use original profile values
    _usernameController = TextEditingController(
        text: widget.updatedUsername ?? widget.profile.username);
    _firstNameController = TextEditingController(
        text: widget.updatedFirstName ?? widget.profile.firstName);
    _lastNameController = TextEditingController(
        text: widget.updatedLastName ?? widget.profile.lastName);
    _emailController = TextEditingController(
        text: widget.updatedEmail ?? widget.profile.email);
    _bioController = TextEditingController(text: widget.currentBio ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveBioToPrefs(String bio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_bio', bio);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save bio to SharedPreferences
      await _saveBioToPrefs(_bioController.text.trim());

      await context.read<AuthProvider>().updateProfile(
            username: _usernameController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            bio: _bioController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context, true); // Pass true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateNotEmpty(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field cannot be empty';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Widget _buildFieldRow({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.bluePrimaryColor, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.bluePrimaryColor, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: hintText,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      child: Container(
        width: screenSize.width * 0.85, // 85% of screen width
        height: screenSize.height * 0.75, // 75% of screen height
        constraints: const BoxConstraints(
          maxWidth: 600, // Maximum width
          maxHeight: 700, // Maximum height
          minWidth: 400, // Minimum width
          minHeight: 500, // Minimum height
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: AppColors.bluePrimaryColor,
                      strokeWidth: 3.5,
                    ))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildFieldRow(
                              label: 'Username:',
                              controller: _usernameController,
                              validator: (value) =>
                                  _validateNotEmpty(value, 'Username'),
                            ),
                            _buildFieldRow(
                              label: 'First Name:',
                              controller: _firstNameController,
                              validator: (value) =>
                                  _validateNotEmpty(value, 'First name'),
                            ),
                            _buildFieldRow(
                              label: 'Last Name:',
                              controller: _lastNameController,
                              validator: (value) =>
                                  _validateNotEmpty(value, 'Last name'),
                            ),
                            _buildFieldRow(
                              label: 'Email:',
                              controller: _emailController,
                              validator: _validateEmail,
                            ),
                            _buildFieldRow(
                              label: 'Bio:',
                              controller: _bioController,
                              maxLines: 4,
                              hintText: 'Write about yourself',
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Footer with buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bluePrimaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: _isLoading ? null : _saveProfile,
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
}
