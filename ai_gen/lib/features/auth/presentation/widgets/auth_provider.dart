// ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_gen/core/network/network_constants.dart';
import 'package:ai_gen/core/network/network_helper.dart';
import 'package:ai_gen/features/HomeScreen/data/user_profile.dart';
import 'package:ai_gen/features/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/OtpVerificationScreen/otp_verification_screen.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


// Enum to track login states
enum LoginState {
  idle,
  validating,
  connecting,
  authenticating,
  success,
  failed
}

typedef LoginStateCallback = void Function(LoginState state);



class AuthProvider with ChangeNotifier {
  bool isLoggingOut = false;
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


  //  new properties for sign-in handling
  String? _emailError;
  String? _passwordError;
  String? _signInError;
  bool _isSigningIn = false;

  // Getters for error states
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get signInError => _signInError;
  bool get isSigningIn => _isSigningIn;



   // Login state
 // bool _isSigningIn = false;
  LoginState _loginState = LoginState.idle;
  String? _loginStatus;

  // Connection info
  Timer? _connectionTimer;
  final Connectivity _connectivity = Connectivity();

  // Success navigation delay
  bool _readyToNavigate = false;

  // Login listeners
  final List<LoginStateCallback> _loginListeners = [];


  // Getters
  
  
  LoginState get loginState => _loginState;
  String? get loginStatus => _loginStatus;

   // Add listener for login state changes
  void addLoginListener(LoginStateCallback callback) {
    _loginListeners.add(callback);
  }

  // Remove listener
  void removeLoginListener(LoginStateCallback callback) {
    _loginListeners.remove(callback);
  }

   // Notify all listeners of state change
  // ignore: unused_element
  void _notifyLoginListeners(LoginState state) {
    for (var callback in _loginListeners) {
      callback(state);
    }
  }

  // Setters with debounce for validation
  Timer? _emailDebounce;
  Timer? _passwordDebounce;


void setEmail(String email) {
    _email = email.trim();
    _emailError = null; // Clear error while typing

    // Debounce email validation
    if (_emailDebounce?.isActive ?? false) _emailDebounce!.cancel();
    _emailDebounce = Timer(const Duration(milliseconds: 500), () {
      validateEmail(_email);
    });

    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    _passwordError = null; // Clear error while typing

    // Debounce password validation
    if (_passwordDebounce?.isActive ?? false) _passwordDebounce!.cancel();
    _passwordDebounce = Timer(const Duration(milliseconds: 500), () {
      validatePassword(_password);
    });

    notifyListeners();
  }

  // void setRememberMe(bool value) {
  //   _rememberMe = value;
  //   notifyListeners();

  //   // Save to shared preferences
  //   _saveRememberMePreference(value);
  // }

  // Email validation with improved regex
  bool validateEmail(String email) {
    if (email.isEmpty) {
      _emailError = 'Email is required';
      notifyListeners();
      return false;
    }

    // More comprehensive email validation
    final emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

    if (!emailRegex.hasMatch(email)) {
      _emailError = 'Enter a valid email address';
      notifyListeners();
      return false;
    }

    _emailError = null;
    notifyListeners();
    return true;
  }

  // Password validation with strength indicator
  bool validatePassword(String password) {
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    _passwordError = null;
    notifyListeners();
    return true;
  }

  // Check network connectivity
  // ignore: unused_element
  Future<bool> _checkConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    // ignore: unrelated_type_equality_checks
    return connectivityResult != ConnectivityResult.none;
  }

    // Complete navigation after animation
  void completeNavigation(BuildContext context) {
    if (_readyToNavigate) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );

      // Reset state after navigation
      _readyToNavigate = false;
      _loginState = LoginState.idle;
      _loginStatus = null;
      notifyListeners();
    }
  }









   // Email validation for sign-in
  // bool validateEmail(String email) {
  //   if (email.isEmpty) {
  //     _emailError = 'Email is required';
  //     notifyListeners();
  //     return false;
  //   }
  //   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
  //     _emailError = 'Enter a valid email address';
  //     notifyListeners();
  //     return false;
  //   }
  //   _emailError = null;
  //   notifyListeners();
  //   return true;
  // }

// // Password validation for sign-in
//   bool validatePassword(String password) {
//     if (password.isEmpty) {
//       _passwordError = 'Password is required';
//       notifyListeners();
//       return false;
//     }
//     if (password.length < 6) {
//       _passwordError = 'Password must be at least 6 characters';
//       notifyListeners();
//       return false;
//     }
//     _passwordError = null;
//     notifyListeners();
//     return true;
//   }





  final _storage = const FlutterSecureStorage();
  bool rememberMe = false;

  //  Getters and Setters
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
  //void setEmail(String value) => _email = value;
 // void setPassword(String value) => _password = value;
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

       // Enhanced signIn method
  Future<void> signIn(BuildContext context) async {
    // Clear previous errors
    _signInError = null;
    notifyListeners();

    // Validate inputs
    final isEmailValid = validateEmail(_email);
    final isPasswordValid = validatePassword(_password);

    if (!isEmailValid || !isPasswordValid) {
      return;
    }

    _isSigningIn = true;
    notifyListeners();

    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.post(
        Uri.parse('${NetworkConstants.apiAuthBaseUrl}/login/'),
        body: {
          'email': _email,
          'password': _password,
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('Login took ${stopwatch.elapsedMilliseconds}ms');

      final data = jsonDecode(response.body);
      debugPrint('Login response data: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveTokens(data['access'], data['refresh']);
        await getProfile();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        _signInError =
            data['detail'] ?? 'Invalid credentials. Please try again.';
        notifyListeners();
      }
    } on SocketException {
      _signInError = 'No internet connection. Please check your network.';
      notifyListeners();
    } on TimeoutException {
      _signInError = 'Connection timeout. Please try again.';
      notifyListeners();
    } catch (e) {
      debugPrint('Login error: $e');
      _signInError = "Something went wrong. Please try again.";
      notifyListeners();
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
  }

  // Future<void> signIn(BuildContext context) async {
  //   isLoading = true;
  //   notifyListeners();

  //   try {
  //     final response = await http.post(
  //       Uri.parse('${NetworkConstants.apiAuthBaseUrl}/login/'),
  //       body: {
  //         'email': _email,
  //         'password': _password,
  //       },
  //     );

  //     final data = jsonDecode(response.body);
  //     debugPrint('Login response data: $data');

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       await _saveTokens(data['access'], data['refresh']);
  //        await  getProfile();
  //       Navigator.push(context,
  //           MaterialPageRoute(builder: (_) => const DashboardScreen()));
  //     } else {
  //       _showErrorDialog(context, data['detail'] ?? 'Invalid credentials.');
  //     }
  //   } catch (_) {
  //     _showErrorDialog(context, "Something went wrong. Please try again.");
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

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
    if (isLoggingOut) return; // Prevent double logout

    isLoggingOut = true;
    notifyListeners();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

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

    // Clear tokens and user profile
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    _userProfile = null;
    notifyListeners();

    // Dismiss loader
    Navigator.of(context).pop();
 Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    // Navigate to login and remove all previous routes
  //  Navigator.of(context).pushNamedAndRemoveUntil('/signIn', (route) => false);
    

    isLoggingOut = false;
    notifyListeners();
  }




//profile endpoint
 Future<UserProfile> getProfile() async {
    final token = await _storage.read(key: 'accessToken');

    if (token == null) {
      throw Exception('No access token found');
    }

    final profileUrl = Uri.parse('${NetworkConstants.apiAuthBaseUrl}/profile/');

    http.Response response = await http.get(
      profileUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _userProfile = UserProfile.fromJson(data);

      // Save user details
      await _storage.write(key: 'username', value: _userProfile?.username);
      await _storage.write(key: 'firstName', value: _userProfile?.firstName);
      await _storage.write(key: 'lastName', value: _userProfile?.lastName);
      await _storage.write(key: 'email', value: _userProfile?.email);

      return _userProfile!;
    } else if (response.statusCode == 401) {
      // Token expired → refresh and retry
      try {
        await refreshAccessToken(); // make sure this updates 'accessToken' in storage

        final newToken = await _storage.read(key: 'accessToken');

        if (newToken == null) {
          throw Exception('Failed to refresh token');
        }

        // Retry profile request
        response = await http.get(
          profileUrl,
          headers: {
            'Authorization': 'Bearer $newToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _userProfile = UserProfile.fromJson(data);

          // Save user details
          await _storage.write(key: 'username', value: _userProfile?.username);
          await _storage.write(
              key: 'firstName', value: _userProfile?.firstName);
          await _storage.write(key: 'lastName', value: _userProfile?.lastName);
          await _storage.write(key: 'email', value: _userProfile?.email);

          return _userProfile!;
        } else {
          throw Exception(
              'Failed to fetch profile after refreshing token: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Unauthorized and failed to refresh token: $e');
      }
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

  //to update user data

Future<void> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.put(
      Uri.parse('${NetworkConstants.apiAuthBaseUrl}/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _userProfile = UserProfile.fromJson(data);

      // Update secure storage
      await _storage.write(key: 'username', value: _userProfile!.username);
      await _storage.write(key: 'firstName', value: _userProfile!.firstName);
      await _storage.write(key: 'lastName', value: _userProfile!.lastName);
      await _storage.write(key: 'email', value: _userProfile!.email);

      notifyListeners();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again.');
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }


// to handle get profile request 



Future<void> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');

    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final response = await http.post(
      Uri.parse('${NetworkConstants.apiAuthBaseUrl}/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'accessToken', value: data['access']);
      debugPrint('Access token refreshed.');
    } else {
      throw Exception('Failed to refresh access token');
    }
  }

//change password
Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      // Get current token
      String? token = await _storage.read(key: 'accessToken');

      if (token == null) {
        _showErrorDialog(context, 'Access token not found.');
        return false;
      }

      // Construct the request URL
      final changePasswordUrl =
          '${NetworkConstants.apiAuthBaseUrl}/change-password/';

      // Add confirm_password field as required by the backend
      final requestBody = {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': newPassword, // Add this field
      };

      debugPrint('Request body: $requestBody');

      // Make the request
      http.Response response = await http.post(
        Uri.parse(changePasswordUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // If unauthorized, try to refresh token and retry
      if (response.statusCode == 401) {
        token = await refreshAccessTokenIfNeeded();

        if (token != null) {
          // Retry with new token
          response = await http.post(
            Uri.parse(changePasswordUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          );
        } else {
          _showErrorDialog(context, 'Failed to refresh authentication token.');
          return false;
        }
      }

      // Handle response
      if (response.statusCode == 200) {
        return true;
      } else {
        // Try to parse error message from response
        Map<String, dynamic> data = {};
        try {
          data = jsonDecode(response.body);
          debugPrint('Error data: $data');
        } catch (e) {
          debugPrint('Could not parse error response: $e');
        }

        // Handle different error formats
        String errorMessage;
        if (data.containsKey('detail')) {
          errorMessage = data['detail'];
        } else if (data.isNotEmpty) {
          // Handle field-specific errors (like the confirm_password error)
          errorMessage = data.entries
              .map((e) =>
                  "${e.key}: ${e.value is List ? e.value.join(', ') : e.value}")
              .join('\n');
        } else {
          errorMessage =
              'Failed to change password (Status: ${response.statusCode})';
        }

        _showErrorDialog(context, errorMessage);
        return false;
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      _showErrorDialog(context, 'An error occurred: $e');
      return false;
    }
  }
//refresh token if needed
Future<String?> refreshAccessTokenIfNeeded() async {
    final refreshToken = await _storage.read(key: 'refreshToken');

    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('${NetworkConstants.apiAuthBaseUrl}/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['access'];

      if (newAccessToken != null) {
        await _storage.write(key: 'accessToken', value: newAccessToken);
        return newAccessToken;
      }
    }

    return null;
  }



// still not designed in backend yet
Future<void> verifyOtpForPassword(String email, String otp) async {
    final response = await authorizedPost(
      '${NetworkConstants.apiAuthBaseUrl}/verify-otp-for-password/',
      {'email': email, 'otp': otp},
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'OTP verification failed');
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final response = await authorizedPost(
      '${NetworkConstants.apiAuthBaseUrl}/reset-password/',
      {
        'email': email,
        'new_password': newPassword,
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Failed to reset password');
    }
  }










}
