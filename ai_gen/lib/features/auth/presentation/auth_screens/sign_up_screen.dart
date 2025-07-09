// ignore_for_file: avoid_print
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';

import 'package:ai_gen/features/auth/presentation/auth_screens/sign_in_screen.dart';
import 'package:ai_gen/features/auth/data/auth_provider.dart';
import 'package:ai_gen/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_layout.dart';
import 'package:ai_gen/features/auth/presentation/widgets/user_testimonal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize slide animation for left side
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom
      end: Offset.zero, // End at original position
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: TranslationKeys.joinModelCraftToday.tr,
      subtitle: TranslationKeys.createAccountAndStartBringing.tr,
      form: const SignupForm(),
      testimonial: const UserTestimonial(),
      slideAnimation: _slideAnimation,
    );
  }
}

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TranslationKeys.signUp.tr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Username
          CustomTextField(
            hintText: TranslationKeys.username.tr,
            suffixIcon: Icons.person_2_outlined,
            fieldKey: 'username',
            errorText: authProvider.fieldErrors['username'],
            onChanged: (value) {
              authProvider.setUsername(value);
              // Clear error when user starts typing
              if (authProvider.fieldErrors.containsKey('username')) {
                authProvider.clearFieldErrors();
              }
            },
          ),
          const SizedBox(height: 16),

          // First Name
          CustomTextField(
            hintText: TranslationKeys.firstName.tr,
            suffixIcon: Icons.person_outline,
            fieldKey: 'first_name',
            errorText: authProvider.fieldErrors['first_name'],
            onChanged: (value) {
              authProvider.setFirstName(value);
              if (authProvider.fieldErrors.containsKey('first_name')) {
                authProvider.clearFieldErrors();
              }
            },
          ),
          const SizedBox(height: 16),

          // Last Name
          CustomTextField(
            hintText: TranslationKeys.lastName.tr,
            suffixIcon: Icons.person_outline,
            fieldKey: 'last_name',
            errorText: authProvider.fieldErrors['last_name'],
            onChanged: (value) {
              authProvider.setLastName(value);
              if (authProvider.fieldErrors.containsKey('last_name')) {
                authProvider.clearFieldErrors();
              }
            },
          ),
          const SizedBox(height: 16),

          // Email Field
          CustomTextField(
            hintText: TranslationKeys.emailHintText.tr,
            suffixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            fieldKey: 'email',
            errorText: authProvider.fieldErrors['email'],
            onChanged: (value) {
              authProvider.setEmail(value);
              if (authProvider.fieldErrors.containsKey('email')) {
                authProvider.clearFieldErrors();
              }
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          CustomTextField(
            hintText: TranslationKeys.passwordHintText.tr,
            suffixIcon: Icons.lock_outline,
            isPassword: true,
            fieldKey: 'password',
            errorText: authProvider.fieldErrors['password'],
            onChanged: (value) {
              authProvider.setPassword(value);
              if (authProvider.fieldErrors.containsKey('password')) {
                authProvider.clearFieldErrors();
              }
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          CustomTextField(
            hintText: TranslationKeys.confirmPassword.tr,
            suffixIcon: Icons.lock_outline,
            isPassword: true,
            fieldKey: 'password2',
            errorText: authProvider.fieldErrors['password2'],
            onChanged: (value) {
              authProvider.setConfirmPassword(value);
              if (authProvider.fieldErrors.containsKey('password2')) {
                authProvider.clearFieldErrors();
              }
            },
          ),
          const SizedBox(height: 16),

          // Terms and Conditions
          Row(
            children: [
              Checkbox(
                value: authProvider.agreeTerms,
                onChanged: (value) =>
                    authProvider.setAgreeTerms(value ?? false),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: TranslationKeys.iAgreeWithThe.tr),
                      TextSpan(
                        text: TranslationKeys.termsAndConditions.tr,
                        style: const TextStyle(color: Color(0xFF1E88E5)),
                      ),
                      TextSpan(text: TranslationKeys.ofClarity.tr),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Updated Sign Up Button with Loading State
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () {
                      // Clear any existing errors before attempting signup
                      authProvider.clearFieldErrors();

                      print("email: ${authProvider.email}");
                      print(
                          "isValidEmail: ${authProvider.isValidEmail(authProvider.email)}");
                      print("password: ${authProvider.password}");
                      print(
                          "password valid: ${authProvider.isStrongPassword(authProvider.password)}");
                      print("agreeTerms: ${authProvider.agreeTerms}");
                      print("isSignUpValid: ${authProvider.isSignUpValid}");
                      authProvider.signUp(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimaryColor,
                disabledBackgroundColor:
                    AppColors.bluePrimaryColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      TranslationKeys.signUp.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Sign In Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(TranslationKeys.dontHaveAnAccount.tr),
              TextButton(
                onPressed: () {
                  authProvider.resetForm();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: Text(
                  TranslationKeys.login.tr,
                  style: const TextStyle(color: AppColors.bluePrimaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
