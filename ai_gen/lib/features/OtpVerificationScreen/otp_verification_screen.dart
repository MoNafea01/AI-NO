import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/presentation/widgets/custom_text_field.dart';
import 'otp_provider.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String email;

  const OTPVerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OTPProvider(email: email),
      child: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 3,
                    color: Colors.black.withOpacity(0.1))
              ],
            ),
            child: Consumer<OTPProvider>(
              builder: (context, otpProvider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Verify OTP',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: "Enter 6-digit OTP",
                      keyboardType: TextInputType.number,
                      onChanged: otpProvider.setOTP,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: otpProvider.isLoading
                          ? null
                          : () => otpProvider.verifyOTP(context),
                      child: otpProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Verify"),
                    ),
                    TextButton(
                      onPressed: () => otpProvider.requestNewOTP(context),
                      child: const Text("Resend OTP"),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
