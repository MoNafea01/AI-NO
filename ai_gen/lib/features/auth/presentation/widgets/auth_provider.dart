// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:ai_gen/features/OtpVerificationScreen/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  String _fullName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _agreeTerms = false;
  bool isLoading = false;

  final _storage = const FlutterSecureStorage();
  bool rememberMe = false;
  String get email => _email;
  String get password => _password;

  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  // 🔐 Store tokens securely
  Future<void> _saveTokens(String access, String refresh) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }

  // 👤 Setters
  void setFullName(String value) => _fullName = value;
  void setEmail(String value) => _email = value;
  void setPassword(String value) => _password = value;
  void setConfirmPassword(String value) => _confirmPassword = value;
  void setAgreeTerms(bool value) {
    _agreeTerms = value;
    notifyListeners();
  }

  // 🔄 Reset form state
  void resetForm() {
    _fullName = '';
    _email = '';
    _password = '';
    _confirmPassword = '';
    _agreeTerms = false;
    notifyListeners();
  }

  // ✅ Validation helpers
  bool get agreeTerms => _agreeTerms;
  bool get isLoad => isLoading;

  bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  bool get isSignUpValid {
    return _fullName.isNotEmpty &&
        isValidEmail(_email) &&
        isStrongPassword(_password) &&
        _confirmPassword == _password &&
        agreeTerms;
  }

  Future<void> signIn(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://your-api-url.com/login/'),
        body: {
          'email': _email,
          'password': _password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final access = data['access'];
        final refresh = data['refresh'];
        await _saveTokens(access, refresh);

        // Navigate to dashboard/home
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        _showErrorDialog(context, "Invalid credentials. Try again.");
      }
    } catch (e) {
      _showErrorDialog(context, "Something went wrong. Please try again.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // 📩 Sign Up + Navigate to OTP
  Future<void> signUp(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
            'https://your-api-url.com/register/'), // ⛳ Replace with actual API
        body: {
          'email': _email,
          'password': _password,
          'full_name': _fullName,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        await _saveTokens(accessToken, refreshToken);

        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(email: _email),
          ),
        );
      } else {
        debugPrint('Signup failed: ${response.body}');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Signup failed: ${data['detail'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      debugPrint("Signup exception: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
