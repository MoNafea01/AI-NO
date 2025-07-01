// ignore_for_file: use_build_context_synchronously

import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/verify_otp_screen-for_password/presentation/pages/verify_otp_for_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestOtpScreen extends StatefulWidget {
  const RequestOtpScreen({super.key});

  @override
  State<RequestOtpScreen> createState() => _RequestOtpScreenState();
}

class _RequestOtpScreenState extends State<RequestOtpScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _requestOtp() async {
    setState(() => isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .requestOtpAgain(emailController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VerifyOtpForPasswordScreen(email: emailController.text),
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
      appBar: AppBar(title: const Text('Request OTP')
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Enter your email to receive a password reset OTP."),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _requestOtp,
              child: isLoading
                  ? const CircularProgressIndicator(
                     color:AppColors.bluePrimaryColor,
                  )
                  : const Text("Request OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
