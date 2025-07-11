// ignore_for_file: unused_field, prefer_final_fields, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:ai_gen/core/data/cache/cache_helper.dart';
import 'package:ai_gen/core/data/cache/cahch_keys.dart';
import 'package:ai_gen/core/data/network/network_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/auth/data/models/register_response_model.dart';
import 'package:ai_gen/features/auth/presentation/OtpVerificationScreen/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProviders with ChangeNotifier {

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
   String? _emailError;
  String? _passwordError;
  String? _signInError;
   String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get signInError => _signInError;
  bool get isSigningIn => _isSigningIn;
  // Setters with debounce for validation
  Timer? _emailDebounce;
  Timer? _passwordDebounce;

  bool _isSigningIn = false;
  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;
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
    bool get agreeTerms => _agreeTerms;
  bool get isLoad => isLoading;

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


  void setEmailError(String error) {
    _emailError = error;
    notifyListeners();
  }

  void setPasswordError(String error) {
    _passwordError = error;
    notifyListeners();
  }
}