// ignore_for_file: use_build_context_synchronously, prefer_final_fields, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ai_gen/core/data/cache/cache_helper.dart';
import 'package:ai_gen/core/data/cache/cahch_keys.dart';
import 'package:ai_gen/core/data/network/network_constants.dart';
import 'package:ai_gen/core/data/network/network_helper.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/HomeScreen/data/user_profile.dart';
import 'package:ai_gen/features/HomeScreen/screens/dashboard_screen.dart';
import 'package:ai_gen/features/auth/data/models/login_state_enum.dart';
import 'package:ai_gen/features/auth/data/models/register_response_model.dart';
import 'package:ai_gen/features/auth/presentation/OtpVerificationScreen/otp_verification_screen.dart';
import 'package:ai_gen/features/auth/presentation/auth_screens/sign_in_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
 // Timer? _connectionTimer;
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

  // final _storage = const FlutterSecureStorage();
  bool rememberMe = false;

  //  Getters and Setters
  // String get email => _email;
  // String get userName => _username;
  // String get firstName => _firstName;
  // String get lastName => _lastName;
  // String get fullName => _fullName;
  // String get password => _password;

  // void setUsername(String value) => _username = value;
  // void setFirstName(String value) => _firstName = value;
  // void setLastName(String value) => _lastName = value;
  // void setFullName(String value) => _fullName = value;
  //void setEmail(String value) => _email = value;
  // void setPassword(String value) => _password = value;
  void setConfirmPassword(String value) => _confirmPassword = value;
  void setAgreeTerms(bool value) {
    _agreeTerms = value;
    notifyListeners();
  }

  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  // Constructor to load stored profile details on startup
  // Update the constructor to load remember me state
  AuthProvider() {
    loadStoredProfile();
    _loadRememberMeState();
  }

  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  // void resetForm() {
  //   _username = '';
  //   _firstName = '';
  //   _lastName = '';
  //   _fullName = '';
  //   _email = '';
  //   _password = '';
  //   _confirmPassword = '';
  //   _agreeTerms = false;
  //   notifyListeners();
  // }

// Update the _saveTokens method to respect rememberMe setting
  Future<void> _saveTokens(String access, String refresh) async {
    if (rememberMe) {
      await CacheHelper.saveData(
        key: CacheKeys.accessToken,
        value: access,
      );
      await CacheHelper.saveData(
        key: CacheKeys.refreshToken,
        value: refresh,
      );
      await CacheHelper.saveData(
        key: CacheKeys.rememberMe,
        value: true,
      );
      // Save tokens permanently if remember me is checked
      // await _storage.write(key: 'accessToken', value: access);
      // await _storage.write(key: 'refreshToken', value: refresh);
      // await _storage.write(key: 'rememberMe', value: 'true');
    } else {
      // Save tokens temporarily (only in memory or with session flag)
      await CacheHelper.saveData(
        key: CacheKeys.accessToken,
        value: access,
      );
      await CacheHelper.saveData(
        key: CacheKeys.refreshToken,
        value: refresh,
      );
      await CacheHelper.saveData(
        key: CacheKeys.rememberMe,
        value: true,
      );
      // await _storage.write(key: 'sessionAccessToken', value: access);
      // await _storage.write(key: 'sessionRefreshToken', value: refresh);
      //await _storage.write(key: 'rememberMe', value: 'false');
    }
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
  Future signIn(BuildContext context) async {
    // Clear previous errors
    _signInError = null;
    _emailError = null;
    _passwordError = null;
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
        Uri.parse('${NetworkConstants.remoteBaseUrl}/login/'),
        body: {
          'email': _email,
          'password': _password,
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('Login took ${stopwatch.elapsedMilliseconds}ms');

      final data = jsonDecode(response.body);
      debugPrint('Login response data: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save tokens based on remember me setting
        await _saveTokens(data['access'], data['refresh']);
        await getProfile();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        // Handle field-specific errors for credentials
        final errorMessage =
            data['detail'] ?? 'Invalid credentials. Please try again.';

        if (errorMessage.toLowerCase().contains('credential') ||
            errorMessage.toLowerCase().contains('active account')) {
          // Set errors for both email and password fields
          _emailError = 'Invalid email or password';
          _passwordError = 'Invalid email or password';
        } else {
          // For other errors, set a general sign-in error
          _signInError = errorMessage;
        }
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


  void setFieldError(String field, String error) {
    _fieldErrors[field] = error;
    notifyListeners();
  }

  void clearFieldErrors() {
    _fieldErrors.clear();
    notifyListeners();
  }

  void clearFieldError(String field) {
    _fieldErrors.remove(field);
  }
  // Add these methods to your AuthProvider class

  void clearEmailError() {
    _emailError = null;
    notifyListeners();
  }

  void clearPasswordError() {
    _passwordError = null;
    notifyListeners();
  }

  void clearSignInError() {
    _signInError = null;
    notifyListeners();
  }

// You might also want to add these if they don't exist
  void setEmailError(String error) {
    _emailError = error;
    notifyListeners();
  }

  void setPasswordError(String error) {
    _passwordError = error;
    notifyListeners();
  }

  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  Future<void> signUp(BuildContext context) async {
    isLoading = true;
    clearFieldErrors(); // Clear previous errors
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${NetworkConstants.remoteBaseUrl}/register/'),
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
      debugPrint('Sign Up response data: $data');
      RegisterResponseModel registerResponseModel =
          RegisterResponseModel.fromJson(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        //show snackbar to tell user his account should be verified
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: AppColors.black,
          ),
        );

        await CacheHelper.saveData(
          key: CacheKeys.accessToken,
          value: registerResponseModel.access,
        );
        await CacheHelper.saveData(
          key: CacheKeys.refreshToken,
          value: registerResponseModel.refresh,
        );
        // await _saveTokens(data['access'], data['refresh']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(email: _email),
          ),
        );
      } else {
        // Parse field-specific errors for inline display
        Map<String, String> fieldErrors = _parseFieldErrors(data);

        // Set field errors for inline display
        fieldErrors.forEach((field, error) {
          setFieldError(field, error);
        });

        // Also show a general error dialog
        String dialogMessage = _parseErrorMessage(data);
        _showErrorDialog(context, dialogMessage);
      }
    } catch (e) {
      _showErrorDialog(context,
          'Network error: Please check your connection and try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

// Parse field-specific errors for inline display
  Map<String, String> _parseFieldErrors(Map<String, dynamic> data) {
    Map<String, String> fieldErrors = {};

    if (data.containsKey('email') && data['email'] is List) {
      List<String> emailErrors = List<String>.from(data['email']);
      if (emailErrors.isNotEmpty) {
        String error = emailErrors.first;
        if (error.toLowerCase().contains('already exists')) {
          fieldErrors['email'] = 'This email is already registered';
        } else if (error.toLowerCase().contains('invalid')) {
          fieldErrors['email'] = 'Please enter a valid email';
        } else {
          fieldErrors['email'] = error;
        }
      }
    }

    if (data.containsKey('username') && data['username'] is List) {
      List<String> usernameErrors = List<String>.from(data['username']);
      if (usernameErrors.isNotEmpty) {
        String error = usernameErrors.first;
        if (error.toLowerCase().contains('already exists')) {
          fieldErrors['username'] = 'This username is already taken';
        } else {
          fieldErrors['username'] = error;
        }
      }
    }

    if (data.containsKey('password') && data['password'] is List) {
      List<String> passwordErrors = List<String>.from(data['password']);
      if (passwordErrors.isNotEmpty) {
        String error = passwordErrors.first;
        if (error.toLowerCase().contains('too weak') ||
            error.toLowerCase().contains('common')) {
          fieldErrors['password'] = 'Password is too weak';
        } else if (error.toLowerCase().contains('too short')) {
          fieldErrors['password'] = 'Password is too short';
        } else if (error.toLowerCase().contains('numeric')) {
          fieldErrors['password'] = 'Password cannot be entirely numeric';
        } else {
          fieldErrors['password'] = error;
        }
      }
    }

    if (data.containsKey('password2') && data['password2'] is List) {
      List<String> password2Errors = List<String>.from(data['password2']);
      if (password2Errors.isNotEmpty) {
        fieldErrors['password2'] = 'Passwords do not match';
      }
    }

    if (data.containsKey('first_name') && data['first_name'] is List) {
      List<String> firstNameErrors = List<String>.from(data['first_name']);
      if (firstNameErrors.isNotEmpty) {
        fieldErrors['first_name'] = firstNameErrors.first;
      }
    }

    if (data.containsKey('last_name') && data['last_name'] is List) {
      List<String> lastNameErrors = List<String>.from(data['last_name']);
      if (lastNameErrors.isNotEmpty) {
        fieldErrors['last_name'] = lastNameErrors.first;
      }
    }

    return fieldErrors;
  }

// Parse error message for dialog display
  String _parseErrorMessage(Map<String, dynamic> data) {
    List<String> errors = [];

    // Check for field-specific errors
    if (data.containsKey('email') && data['email'] is List) {
      List<String> emailErrors = List<String>.from(data['email']);
      for (String error in emailErrors) {
        if (error.toLowerCase().contains('already exists')) {
          errors.add(
              '• This email is already registered. Please use a different email.');
        } else if (error.toLowerCase().contains('invalid')) {
          errors.add('• Please enter a valid email address.');
        } else {
          errors.add('• Email: $error');
        }
      }
    }

    if (data.containsKey('username') && data['username'] is List) {
      List<String> usernameErrors = List<String>.from(data['username']);
      for (String error in usernameErrors) {
        if (error.toLowerCase().contains('already exists')) {
          errors.add(
              '• This username is already taken. Please choose a different username.');
        } else if (error.toLowerCase().contains('invalid')) {
          errors.add('• Please enter a valid username.');
        } else {
          errors.add('• Username: $error');
        }
      }
    }

    if (data.containsKey('password') && data['password'] is List) {
      List<String> passwordErrors = List<String>.from(data['password']);
      for (String error in passwordErrors) {
        if (error.toLowerCase().contains('too weak') ||
            error.toLowerCase().contains('common')) {
          errors.add(
              '• Password is too weak. Please use a stronger password with at least 8 characters.');
        } else if (error.toLowerCase().contains('too short')) {
          errors.add(
              '• Password is too short. Please use at least 8 characters.');
        } else if (error.toLowerCase().contains('numeric')) {
          errors.add('• Password cannot be entirely numeric.');
        } else {
          errors.add('• Password: $error');
        }
      }
    }

    if (data.containsKey('password2') && data['password2'] is List) {
      List<String> password2Errors = List<String>.from(data['password2']);
      for (String error in password2Errors) {
        if (error.toLowerCase().contains('match')) {
          errors.add(
              '• Passwords do not match. Please make sure both passwords are the same.');
        } else {
          errors.add('• Confirm Password: $error');
        }
      }
    }

    if (data.containsKey('first_name') && data['first_name'] is List) {
      List<String> firstNameErrors = List<String>.from(data['first_name']);
      for (String error in firstNameErrors) {
        errors.add('• First Name: $error');
      }
    }

    if (data.containsKey('last_name') && data['last_name'] is List) {
      List<String> lastNameErrors = List<String>.from(data['last_name']);
      for (String error in lastNameErrors) {
        errors.add('• Last Name: $error');
      }
    }

    // Check for non-field errors
    if (data.containsKey('non_field_errors') &&
        data['non_field_errors'] is List) {
      List<String> nonFieldErrors = List<String>.from(data['non_field_errors']);
      errors.addAll(nonFieldErrors.map((e) => '• $e'));
    }

    // Check for general detail message
    if (data.containsKey('detail') && data['detail'] is String) {
      errors.add('• ${data['detail']}');
    }

    // If no specific errors found, return a generic message
    if (errors.isEmpty) {
      return 'Sign up failed. Please check your information and try again.';
    }

    // Join all errors with line breaks
    return errors.join('\n\n');
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sign Up Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300,
              maxWidth: 350,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please fix the following issues:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.bluePrimaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }

  void setOtp(String value) => _otp = value;

  Future<void> verifyOtp(BuildContext context, String email) async {
    try {
      final response = await authorizedPost(
        '${NetworkConstants.remoteBaseUrl}/verify-email/',
        {
          // 'email': email,
          'otp': _otp
        },
      );

      final data = jsonDecode(response.body);
      debugPrint('OTP verification response data: $data');
      if (response.statusCode == 200) {
        // show message that account is verified
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Account verified successfully!'),
            backgroundColor: AppColors.black,
          ),
        );
        await CacheHelper.saveData(
          key: CacheKeys.accessToken,
          value: data['access'],
        );
        await CacheHelper.saveData(
          key: CacheKeys.refreshToken,
          value: data['refresh'],
        );
        //await _saveTokens(data['access'], data['refresh']);
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
        '${NetworkConstants.remoteBaseUrl}/request-otp/',
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

// Enhanced logout with proper cleanup
  Future<void> logout(BuildContext context) async {
    if (isLoggingOut) return;

    isLoggingOut = true;
    notifyListeners();

    // Cancel any ongoing token refresh
    _tokenExpiryTimer?.cancel();

    // Clear any pending refresh completers
    _completeRefreshCompleters(null);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(
        color: AppColors.bluePrimaryColor,
      )),
    );

    // Get the appropriate refresh token
    String? refreshToken;
    if (rememberMe) {
      refreshToken = await CacheHelper.getData(key: CacheKeys.refreshToken);

      // refreshToken = await _storage.read(key: 'refreshToken');
    } else {
      refreshToken = await CacheHelper.getData(key: CacheKeys.refreshToken);
      //   refreshToken = await _storage.read(key: 'sessionRefreshToken');
    }

    if (refreshToken != null) {
      try {
        await http
            .post(
              Uri.parse('${NetworkConstants.remoteBaseUrl}/token/blacklist/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refresh': refreshToken}),
            )
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Logout error: $e');
      }
    }

    // Clear all data
    await _clearTokens();

    // Reset remember me to false
    rememberMe = false;

    // Dismiss loader
    if (context.mounted) {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }

    isLoggingOut = false;
    notifyListeners();
  }

  bool _isRefreshingToken = false;
  List<Completer<String?>> _refreshCompleters = [];
  Timer? _tokenExpiryTimer;

//profile endpoint
  // Enhanced getProfile with better error handling
  Future<UserProfile> getProfile() async {
    try {
      String? token = await _getValidToken();

      if (token == null) {
        throw Exception('No valid access token available');
      }

      final profileUrl =
          Uri.parse('${NetworkConstants.remoteBaseUrl}/profile/');

      final response = await http.get(
        profileUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userProfile = UserProfile.fromJson(data);

        // Save user details
        await _saveUserProfile(_userProfile!);

        notifyListeners();
        return _userProfile!;
      } else if (response.statusCode == 401) {
        // Token is invalid, try to refresh one more time
        token = await _forceRefreshToken();

        if (token != null) {
          return await _retryGetProfile(token);
        } else {
          throw Exception('Authentication failed. Please log in again.');
        }
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Connection timeout. Please try again.');
    } catch (e) {
      debugPrint('Error in getProfile: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  //to get user data when reopen the app
  Future<void> loadStoredProfile() async {
    final username = await CacheHelper.getData(key: CacheKeys.userName);
    final firstName = await CacheHelper.getData(key: CacheKeys.firstName);
    final lastName = await CacheHelper.getData(key: CacheKeys.lastName);
    final email = await CacheHelper.getData(key: CacheKeys.email);
    final bio = await CacheHelper.getData(key: CacheKeys.bio);
    // final username = await _storage.read(key: 'username');
    // final firstName = await _storage.read(key: 'firstName');
    // final lastName = await _storage.read(key: 'lastName');
    // final email = await _storage.read(key: 'email');
    // final bio = await _storage.read(key: 'bio');

    if (username != null && email != null) {
      _userProfile = UserProfile(
        username: username,
        firstName: firstName!,
        lastName: lastName!,
        email: email,
        bio: bio ?? "",
      );
      notifyListeners();
    }
  }

  // Get valid token with automatic refresh

  //to update user data

  Future<void> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String bio,
  }) async {
    late final String? token;
    final String? accessToken = await CacheHelper.getData(
      key: CacheKeys.accessToken,
    );
    
    if (rememberMe) {
      token = await CacheHelper.getData(key: CacheKeys.accessToken);
      //  token = await _storage.read(key: 'accessToken');
    } else {
      token = await CacheHelper.getData(key: CacheKeys.accessToken);
      //  token = await _storage.read(key: 'sessionAccessToken');
    }

    if (token == null) {
      throw Exception('No access token found');
    }

    final body = {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      "profile": {
        'bio': bio,
      }
    };

    final response = await http.put(
      Uri.parse('${NetworkConstants.remoteBaseUrl}/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _userProfile = UserProfile.fromJson(data);
      //username
      await CacheHelper.saveData(
        key: CacheKeys.userName,
        value: _userProfile!.username,
      );
      //first name
      await CacheHelper.saveData(
        key: CacheKeys.userName,
        value: _userProfile!.firstName,
      );

      //last name
      await CacheHelper.saveData(
        key: CacheKeys.userName,
        value: _userProfile!.lastName,
      );

      //email
      await CacheHelper.saveData(
        key: CacheKeys.userName,
        value: _userProfile!.email,
      );

      //bio
      await CacheHelper.saveData(
        key: CacheKeys.userName,
        value: _userProfile!.bio,
      );

      // Update secure storage
      // await _storage.write(key: 'username', value: _userProfile!.username);
      // await _storage.write(key: 'firstName', value: _userProfile!.firstName);
      // await _storage.write(key: 'lastName', value: _userProfile!.lastName);
      // await _storage.write(key: 'email', value: _userProfile!.email);
      // await _storage.write(key: 'bio', value: _userProfile!.bio);

      notifyListeners();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again.');
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

// to handle get profile request

// Enhanced token refresh with race condition handling
  // Update the refreshAccessToken method
  Future<String?> refreshAccessToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshingToken) {
      debugPrint('Token refresh already in progress, waiting...');
      final completer = Completer<String?>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshingToken = true;

    try {
      String? refreshToken;

      if (rememberMe) {
        refreshToken = await CacheHelper.getData(key: CacheKeys.refreshToken);
        // refreshToken = await _storage.read(key: 'refreshToken');
      } else {
        refreshToken = await CacheHelper.getData(key: CacheKeys.refreshToken);
        // refreshToken = await _storage.read(key: 'sessionRefreshToken');
      }

      if (refreshToken == null) {
        debugPrint('No refresh token found');
        _completeRefreshCompleters(null);
        return null;
      }

      final response = await http
          .post(
            Uri.parse('${NetworkConstants.remoteBaseUrl}/token/refresh/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];

        if (newAccessToken != null) {
          // Save new token based on remember me setting
          if (rememberMe) {
            await CacheHelper.saveData(
              key: CacheKeys.accessToken,
              value: newAccessToken,
            );
            //   await _storage.write(key: 'accessToken', value: newAccessToken);
          } else {
            await CacheHelper.saveData(
              key: CacheKeys.accessToken,
              value: newAccessToken,
            );
            // await _storage.write(
            //     key: 'sessionAccessToken', value: newAccessToken);
          }

          debugPrint('Access token refreshed successfully');
          _scheduleTokenRefresh();
          _completeRefreshCompleters(newAccessToken);
          return newAccessToken;
        }
      } else if (response.statusCode == 401) {
        debugPrint('Refresh token is invalid or expired');
        await _clearTokens();
        _completeRefreshCompleters(null);
        return null;
      } else {
        debugPrint('Failed to refresh token: ${response.statusCode}');
        _completeRefreshCompleters(null);
        return null;
      }
    } on SocketException {
      debugPrint('Network error during token refresh');
      _completeRefreshCompleters(null);
      return null;
    } on TimeoutException {
      debugPrint('Timeout during token refresh');
      _completeRefreshCompleters(null);
      return null;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      _completeRefreshCompleters(null);
      return null;
    } finally {
      _isRefreshingToken = false;
    }

    _completeRefreshCompleters(null);
    return null;
  }

  // Force refresh token (when we know current token is invalid)
  Future<String?> _forceRefreshToken() async {
    debugPrint('Force refreshing token...');
    return await refreshAccessToken();
  }

  // Complete all waiting refresh requests
  void _completeRefreshCompleters(String? token) {
    for (final completer in _refreshCompleters) {
      if (!completer.isCompleted) {
        completer.complete(token);
      }
    }
    _refreshCompleters.clear();
  }

  // Retry profile request with new token
  Future<UserProfile> _retryGetProfile(String token) async {
    final profileUrl = Uri.parse('${NetworkConstants.remoteBaseUrl}/profile/');

    final response = await http.get(
      profileUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _userProfile = UserProfile.fromJson(data);
      await _saveUserProfile(_userProfile!);
      notifyListeners();
      return _userProfile!;
    } else {
      throw Exception(
          'Failed to fetch profile after token refresh: ${response.statusCode}');
    }
  }

  // Save user profile to secure storage
  Future<void> _saveUserProfile(UserProfile profile) async {
    await CacheHelper.saveData(
      key: CacheKeys.userName,
      value: profile.username,
    );
    await CacheHelper.saveData(
      key: CacheKeys.firstName,
      value: profile.firstName,
    );
    await CacheHelper.saveData(
      key: CacheKeys.lastName,
      value: profile.lastName,
    );
    await CacheHelper.saveData(
      key: CacheKeys.email,
      value: profile.email,
    );
    await CacheHelper.saveData(
      key: CacheKeys.bio,
      value: profile.bio,
    );
    // await _storage.write(key: 'username', value: profile.username);
    // await _storage.write(key: 'firstName', value: profile.firstName);
    // await _storage.write(key: 'lastName', value: profile.lastName);
    // await _storage.write(key: 'email', value: profile.email);
  }

  // Clear all tokens

  Future<void> _clearTokens() async {
    await CacheHelper.removeData(key: CacheKeys.accessToken);
    await CacheHelper.removeData(key: CacheKeys.refreshToken);

    await CacheHelper.removeData(key: CacheKeys.rememberMe);
    // await _storage.delete(key: 'accessToken');
    // await _storage.delete(key: 'refreshToken');
    // await _storage.delete(key: 'sessionAccessToken');
    // await _storage.delete(key: 'sessionRefreshToken');
    // await _storage.delete(key: 'rememberMe');
    _userProfile = null;
    notifyListeners();
  }

  // Optional: Schedule proactive token refresh
  void _scheduleTokenRefresh() {
    _tokenExpiryTimer?.cancel();
    // Refresh token 5 minutes before it expires (adjust as needed)
    _tokenExpiryTimer = Timer(const Duration(minutes: 25), () {
      refreshAccessToken();
    });
  }

  // Check if user is authenticated
  // Update the isAuthenticated method
  Future<bool> isAuthenticated() async {
    String? accessToken;
    String? refreshToken;

    //final rememberMeValue = await _storage.read(key: 'rememberMe');
    final rememberMeValue =
        await CacheHelper.getData(key: CacheKeys.rememberMe);
    final isRemembered = rememberMeValue == 'true';

    if (isRemembered) {
      accessToken = await CacheHelper.getData(key: CacheKeys.accessToken);
      refreshToken = await CacheHelper.getData(key: CacheKeys.refreshToken);

      // accessToken = await _storage.read(key: 'accessToken');
      // refreshToken = await _storage.read(key: 'refreshToken');
    } else {
      accessToken = await CacheHelper.getData(key: CacheKeys.accessToken);
      refreshToken = await CacheHelper.getData(key: CacheKeys.refreshToken);
      // accessToken = await _storage.read(key: 'sessionAccessToken');
      // refreshToken = await _storage.read(key: 'sessionRefreshToken');
    }

    if (accessToken == null || refreshToken == null) {
      return false;
    }

    // Update rememberMe state
    rememberMe = isRemembered;

    return true;
  }

//change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      // Get current token
      String? token = await CacheHelper.getData(key: CacheKeys.accessToken);
// String? token = await _storage.read(key: 'accessToken');
      if (token == null) {
        _showErrorDialog(context, 'Access token not found.');
        return false;
      }

      // Construct the request URL
      final changePasswordUrl =
          '${NetworkConstants.remoteBaseUrl}/change-password/';

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
    final refreshToken = await CacheHelper.getData(key: CacheKeys.refreshToken);
    //final refreshToken = await _storage.read(key: 'refreshToken');

    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('${NetworkConstants.remoteBaseUrl}/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['access'];

      if (newAccessToken != null) {
        await CacheHelper.saveData(
          key: CacheKeys.accessToken,
          value: newAccessToken,
        );
        // await _storage.write(key: 'accessToken', value: newAccessToken);
        return newAccessToken;
      }
    }

    return null;
  }

// still not designed in backend yet
  Future<void> verifyOtpForPassword(String email, String otp) async {
    final response = await authorizedPost(
      '${NetworkConstants.remoteBaseUrl}/verify-otp-for-password/',
      {'email': email, 'otp': otp},
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'OTP verification failed');
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final response = await authorizedPost(
      '${NetworkConstants.remoteBaseUrl}/reset-password/',
      {
        // 'email': email,
        'new_password': newPassword,
        'confirm_password': newPassword
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Failed to reset password');
    }
  }

  // Add method to load remember me state
  Future<void> _loadRememberMeState() async {
    // final rememberMeValue = await _storage.read(key: 'rememberMe');
    final rememberMeValue =
        await CacheHelper.getData(key: CacheKeys.rememberMe);
    rememberMe = rememberMeValue == 'true';
    notifyListeners();
  }

// Update the _getValidToken method to check remember me setting
  Future<String?> _getValidToken() async {
    String? token;

    if (rememberMe) {
      // Get permanent token
      token = await CacheHelper.getData(key: CacheKeys.accessToken);
    } else {
      // Get session token
      token = await CacheHelper.getData(key: CacheKeys.accessToken);
      // token = await _storage.read(key: 'sessionAccessToken');
    }

    if (token == null) {
      debugPrint('No access token found');
      return null;
    }

    return token;
  }

  Future<bool> checkAutoLogin() async {
    final rememberMeValue =
        await CacheHelper.getData(key: CacheKeys.rememberMe);
    //  final rememberMeValue = await _storage.read(key: 'rememberMe');
    if (rememberMeValue != 'true') {
      // If remember me is not checked, clear any existing tokens
      await _clearTokens();
      return false;
    }

    // If remember me is checked, check if tokens exist
    final accessToken = await CacheHelper.getData(key: CacheKeys.accessToken);
    final refreshToken = await CacheHelper.getData(key: CacheKeys.refreshToken);
    // final accessToken = await _storage.read(key: 'accessToken');
    // final refreshToken = await _storage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      rememberMe = true;
      return true;
    }

    return false;
  }
}
