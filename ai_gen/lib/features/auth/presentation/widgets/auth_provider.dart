// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:ai_gen/core/network/network_constants.dart';
import 'package:ai_gen/features/HomeScreen/home_screen.dart';
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
  String _username = '';

  String _firstName = '';
  String _lastName = '';
  String _otp = '';

  void setUsername(String value) {
    print("username set to $value");
    _username = value;
  }

  void setFirstName(String value) => _firstName = value;
  void setLastName(String value) => _lastName = value;

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
    _username = '';
    _firstName = '';
    _lastName = '';

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
    return _username.isNotEmpty &&
        _firstName.isNotEmpty &&
        _lastName.isNotEmpty &&
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
        Uri.parse('${NetworkConstants.apiAuthBaseUrl}/login/'),
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
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const DashboardScreen(), // adjust screen as needed
            ));
        // Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        print(data);
        print("Error: ${data['detail'] ?? data}");
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
        content: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
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
        Uri.parse('${NetworkConstants.apiAuthBaseUrl}/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'username': _username,
          'first_name': _firstName,
          'last_name': _lastName,
          'password': _password,
          'password2': _confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);
      print('STATUS CODE: ${response.statusCode}');
      print('BODY: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final access = data['access'];
        final refresh = data['refresh'];
        await _saveTokens(access, refresh); // ✅ Save right after signup

        // 🔁 Now navigate to OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(email: _email),
          ),
        );
      } else {
        print("Error: ${data['detail'] ?? data}");
      }
    } catch (e) {
      print("Signup error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  void setOtp(String value) => _otp = value;
Future<void> verifyOtp(BuildContext context, String email) async {
    final accessToken = await _storage.read(key: 'accessToken');
    print('Token retrieved for verification: $accessToken');

    if (accessToken == null) {
      _showErrorDialog(context, 'No access token found.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${NetworkConstants.apiAuthBaseUrl}/verify-email/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'email': email, 'otp': _otp}),
      );

      final data = jsonDecode(response.body);
      print("VERIFY OTP RESPONSE: $data");

      if (response.statusCode == 200) {
        final newAccess = data['access'];
        final newRefresh = data['refresh'];

        await _saveTokens(newAccess, newRefresh); // 🔁 replace old token

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        _showErrorDialog(context, data['detail'] ?? 'OTP verification failed.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error verifying OTP: $e');
    }
  }


 Future<void> requestOtpAgain(String email) async {
    final token = await _storage.read(key: 'accessToken');
    print("Using access token: $token");

    try {
      final response = await http.post(
        Uri.parse('${NetworkConstants.apiAuthBaseUrl}/request-otp/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Required header
        },
        body: jsonEncode({'email': email}),
      );

      print('Request OTP Status Code: ${response.statusCode}');
      print('Request OTP Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optionally show confirmation
        debugPrint('OTP resent successfully');
      } else {
        // Optionally handle specific errors
        debugPrint('Failed to resend OTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error requesting OTP: $e');
    }
  }

}
