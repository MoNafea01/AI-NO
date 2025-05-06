// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:ai_gen/core/network/network_constants.dart';
import 'package:ai_gen/core/network/network_helper.dart';
import 'package:ai_gen/features/HomeScreen/data/user_profile.dart';
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

  final _storage = const FlutterSecureStorage();
  bool rememberMe = false;

  // 🔐 Getters and Setters
  String get email => _email;
  String get userName => _username;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get fullName => _fullName;
  String get password => _password;

  void setUsername(String value) => _username = value;
  void setFirstName(String value) => _firstName = value;
  void setLastName(String value) => _lastName = value;
  void setFullName(String value) => _fullName = value;
  void setEmail(String value) => _email = value;
  void setPassword(String value) => _password = value;
  void setConfirmPassword(String value) => _confirmPassword = value;
  void setAgreeTerms(bool value) {
    _agreeTerms = value;
    notifyListeners();
  }
  UserProfile? _userProfile; // Add this to your provider class

  UserProfile? get userProfile => _userProfile;

  // Constructor to load stored profile details on startup
  AuthProvider() {
    loadStoredProfile();
  }

  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

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

  Future<void> _saveTokens(String access, String refresh) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }

  bool get agreeTerms => _agreeTerms;
  bool get isLoad => isLoading;

  bool isValidEmail(String email) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);

  bool isStrongPassword(String password) =>
      password.length >= 8 &&
      RegExp(r'[A-Za-z]').hasMatch(password) &&
      RegExp(r'[0-9]').hasMatch(password);

  bool get isSignUpValid =>
      _username.isNotEmpty &&
      _firstName.isNotEmpty &&
      _lastName.isNotEmpty &&
      isValidEmail(_email) &&
      isStrongPassword(_password) &&
      _confirmPassword == _password &&
      agreeTerms;

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
      debugPrint('Login response data: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveTokens(data['access'], data['refresh']);
         await  getProfile();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        _showErrorDialog(context, data['detail'] ?? 'Invalid credentials.');
      }
    } catch (_) {
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
        title: const Text('Error'),
        content: Text(message, style: const TextStyle(color: Colors.red)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

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
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveTokens(data['access'], data['refresh']);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => OTPVerificationScreen(email: _email)),
        );
      } else {
        _showErrorDialog(context, data['detail'] ?? 'Sign up failed.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Signup error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setOtp(String value) => _otp = value;

  Future<void> verifyOtp(BuildContext context, String email) async {
    try {
      final response = await authorizedPost(
        '${NetworkConstants.apiAuthBaseUrl}/verify-email/',
        {'email': email, 'otp': _otp},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _saveTokens(data['access'], data['refresh']);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        _showErrorDialog(context, data['detail'] ?? 'OTP verification failed.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error verifying OTP: $e');
    }
  }

  Future<void> requestOtpAgain(String email) async {
    try {
      final response = await authorizedPost(
        '${NetworkConstants.apiAuthBaseUrl}/request-otp/',
        {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('OTP resent successfully');
      } else {
        debugPrint('Failed to resend OTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error requesting OTP: $e');
    }
  }



Future<void> logout(BuildContext context) async {
    final refreshToken = await _storage.read(key: 'refreshToken');

    if (refreshToken != null) {
      try {
        final response = await http.post(
          Uri.parse('${NetworkConstants.apiAuthBaseUrl}/token/blacklist/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': refreshToken}),
        );

        debugPrint('Logout Status Code: ${response.statusCode}');
        debugPrint('Logout Response: ${response.body}');
      } catch (e) {
        debugPrint('Logout error: $e');
      }
    } else {
      debugPrint('No refresh token found.');
    }

    // ✅ IMPORTANT: clear stored tokens no matter what
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');

    debugPrint('Tokens cleared from storage.');
    Navigator.pop(context); // Close the current screen

    // Navigate back to login or home
   // navigatorKey.currentState?.pushReplacementNamed('/login');
  }



//profile endpoint
  Future<UserProfile> getProfile() async {
     //final _secureStorage = const FlutterSecureStorage();
   final token = await _storage.read(key: 'accessToken');


    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('${NetworkConstants.apiAuthBaseUrl}/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _userProfile = UserProfile.fromJson(data);
      await _storage.write(key: 'username', value: _userProfile?.username);
      await _storage.write(key: 'firstName', value: _userProfile?.firstName);
      await _storage.write(key: 'lastName', value: _userProfile?.lastName);
      await _storage.write(key: 'email', value: _userProfile?.email);

      return UserProfile.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }
  }


//to get user data when reopen the app
Future<void> loadStoredProfile() async {
    final username = await _storage.read(key: 'username');
    final firstName = await _storage.read(key: 'firstName');
    final lastName = await _storage.read(key: 'lastName');
    final email = await _storage.read(key: 'email');

    if (username != null && email != null) {
      _userProfile = UserProfile(
        username: username,
        firstName: firstName!,
        lastName: lastName!,
        email: email,
      );
      notifyListeners();
    }
  }















}
