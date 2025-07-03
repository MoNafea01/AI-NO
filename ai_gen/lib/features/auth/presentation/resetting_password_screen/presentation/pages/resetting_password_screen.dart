// ignore_for_file: use_build_context_synchronously

import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({required this.email, super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    setState(() => isLoading = true);
    try {
      if (newPasswordController.text != confirmPasswordController.text) {
        throw Exception("Passwords do not match");
      }

      await Provider.of<AuthProvider>(context, listen: false)
          .resetPassword(widget.email, newPasswordController.text);
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _resetPassword,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
