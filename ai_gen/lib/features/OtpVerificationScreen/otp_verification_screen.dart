import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_colors.dart';


class OTPVerificationScreen extends StatelessWidget {
  final String email;

  const OTPVerificationScreen({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        backgroundColor: AppColors.bluePrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the OTP sent to your email:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => authProvider.setOtp(value),
            ),
            const SizedBox(height: 24),
          ElevatedButton(
  onPressed: authProvider.isLoading
      ? null
      : () => authProvider.verifyOtp(context, email),
  child: authProvider.isLoading
      ? const CircularProgressIndicator(color: Colors.white)
      : const Text('Verify', style: TextStyle(fontSize: 18)),
),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () => authProvider.requestOtpAgain(email),
              child: const Text('Resend OTP'),
            )
          ],
        ),
      ),
    );
  }
}
