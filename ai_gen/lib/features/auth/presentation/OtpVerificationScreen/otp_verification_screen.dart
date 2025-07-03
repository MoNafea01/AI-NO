import 'dart:async';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/themes/app_colors.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({required this.email, super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late Timer _resendCooldownTimer;
  late Timer _otpExpiryTimer;

  int _resendSeconds = 30;
  int _otpValidSeconds = 300;

  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _startOtpCountdown();
  }

  void _startResendCooldown() {
    _canResend = false;
    _resendSeconds = 30;
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _startOtpCountdown() {
    _otpValidSeconds = 300;
    _otpExpiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpValidSeconds == 0) {
        timer.cancel();
        _showOtpExpiredDialog();
      } else {
        setState(() => _otpValidSeconds--);
      }
    });
  }

  void _showOtpExpiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("OTP Expired"),
        content: const Text("The OTP has expired. Please request a new one."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.bluePrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),

            ),
            child: const Text("OK" , style: TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _resendCooldownTimer.cancel();
    _otpExpiryTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
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
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(),
                counterText: "", // hides the default character counter
              ),
              onChanged: (value) {
                authProvider.setOtp(value);
                if (value.length == 6) {
                  authProvider.verifyOtp(context, widget.email);
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Expires in ${_otpValidSeconds ~/ 60}:${(_otpValidSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () => authProvider.verifyOtp(context, widget.email),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: AppColors.bluePrimaryColor)
                  : const Text('Verify', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _canResend
                  ? () {
                      authProvider.requestOtpAgain(widget.email);
                      _startResendCooldown();
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.bluePrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                _canResend ? 'Resend OTP' : 'Resend in $_resendSeconds seconds',
                style: const TextStyle(fontSize: 16 , color: AppColors.bluePrimaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
