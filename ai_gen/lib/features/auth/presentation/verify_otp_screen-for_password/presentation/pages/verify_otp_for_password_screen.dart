// ignore_for_file: use_build_context_synchronously

import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/auth/presentation/resetting_password_screen/presentation/pages/resetting_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerifyOtpForPasswordScreen extends StatefulWidget {
  final String email;
  const VerifyOtpForPasswordScreen({required this.email, super.key});

  @override
  State<VerifyOtpForPasswordScreen> createState() =>
      _VerifyOtpForPasswordScreenState();
}

class _VerifyOtpForPasswordScreenState
    extends State<VerifyOtpForPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() => isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .verifyOtpForPassword(widget.email, otpController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Enter OTP sent to ${widget.email}"),
            TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: 'OTP')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _verifyOtp,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
