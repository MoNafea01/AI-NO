// ignore_for_file: avoid_print

import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ai_gen/features/auth/presentation/widgets/outlinedPrimaryButton.dart';
import 'package:ai_gen/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:ai_gen/features/auth/presentation/widgets/user_testimonal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  AuthLayout(
      title: TranslationKeys.joinModelCraftToday.tr,
      subtitle: TranslationKeys.createAccountAndStartBringing.tr,
      form: const SignupForm(),
      testimonial: const UserTestimonial(),
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
            onChanged: (value) => authProvider.setUsername(value),
          ),
          const SizedBox(height: 16),

          // First Name
          CustomTextField(
            hintText: TranslationKeys.firstName.tr,
            suffixIcon: Icons.person_outline,
            onChanged: (value) => authProvider.setFirstName(value),
          ),
          const SizedBox(height: 16),

          // Last Name
          CustomTextField(
            hintText: TranslationKeys.lastName.tr,
            suffixIcon: Icons.person_outline,
            onChanged: (value) => authProvider.setLastName(value),
          ),
          const SizedBox(height: 16),

          // Email Field
          CustomTextField(
            hintText: TranslationKeys.emailHintText.tr,
            suffixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => authProvider.setEmail(value),
          ),
          const SizedBox(height: 16),

          // Password Field
          CustomTextField(
            hintText: TranslationKeys.passwordHintText.tr,
            suffixIcon: Icons.lock_outline,
            isPassword: true,
            onChanged: (value) => authProvider.setPassword(value),
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          CustomTextField(
            hintText: TranslationKeys.confirmPassword.tr,
            suffixIcon: Icons.lock_outline,
            isPassword: true,
            onChanged: (value) => authProvider.setConfirmPassword(value),
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
                  text:  TextSpan(
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
          CustomPrimaryButton(
            buttonBackgroundColor: AppColors.bluePrimaryColor,
            buttonName: TranslationKeys.signUp.tr,
            textButtonColor: AppColors.appBackgroundColor,
            onPressed: () {
              print("email: ${authProvider.email}");
              print(
                  "isValidEmail: ${authProvider.isValidEmail(authProvider.email)}");
              print("password: ${authProvider.password}");
              print(
                  "password valid: ${authProvider.isStrongPassword(authProvider.password)}");

              print("agreeTerms: ${authProvider.agreeTerms}");
              print("isSignUpValid: ${authProvider.isSignUpValid}");
              authProvider.signUp(context);

              // if (authProvider.isSignUpValid && !authProvider.isLoading) {
              //   authProvider.signUp(context); // Pass context here
              // }
            },
          ),

          const SizedBox(height: 24),

          // Social Sign In
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialSignInButton(
                label: AssetsPaths.googleLogo,
              ),
              SizedBox(width: 8),
              SocialSignInButton(
                label: AssetsPaths.appleLogo,
              ),
              SizedBox(width: 8),
              SocialSignInButton(
                label: AssetsPaths.facebookLogo,
              ),
              SizedBox(width: 8),
              SocialSignInButton(
                label: AssetsPaths.githubLogo,
              ),
            ],
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
                child:  Text(
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
