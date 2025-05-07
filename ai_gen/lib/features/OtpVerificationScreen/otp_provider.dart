import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class OTPProvider extends ChangeNotifier {
  final String email;
  String otp = '';
  bool isLoading = false;

  final storage = const FlutterSecureStorage();

  OTPProvider({required this.email});

  void setOTP(String code) {
    otp = code;
  }

  Future<void> verifyOTP(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("https://your-api-url.com/verify-email/"),
        body: {
          "email": email,
          "otp": otp,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final access = data["access"];
        final refresh = data["refresh"];
        await storage.write(key: "accessToken", value: access);
        await storage.write(key: "refreshToken", value: refresh);

        // ✅ Navigate to your home/dashboard screen
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, "/dashboard");
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Verification Failed"),
            content: Text(data["message"] ?? "Please try again"),
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("OTP Verification error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestNewOTP(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse("https://your-api-url.com/request-otp/"),
        body: {
          "email": email,
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Sent Again!")),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Failed to resend OTP")),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Request OTP error: $e");
    }
  }
}
