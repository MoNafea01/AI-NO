// ignore_for_file: avoid_print

import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/asset_paths.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ai_gen/features/auth/presentation/widgets/outlinedPrimaryButton.dart';
import 'package:ai_gen/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:ai_gen/features/auth/presentation/widgets/user_testimonal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthLayout(
      title: 'Join Model Craft\nToday',
      subtitle: 'Create an account and start bringing your models to life.',
      form: SignupForm(),
      testimonial: UserTestimonial(),
    );
  }
}

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Username
        CustomTextField(
          hintText: 'Username',
          suffixIcon: Icons.person_2_outlined,
          onChanged: (value) => authProvider.setUsername(value),
        ),
        const SizedBox(height: 16),

// First Name
        CustomTextField(
          hintText: 'First name',
          suffixIcon: Icons.person_outline,
          onChanged: (value) => authProvider.setFirstName(value),
        ),
        const SizedBox(height: 16),

// Last Name
        CustomTextField(
          hintText: 'Last name',
          suffixIcon: Icons.person_outline,
          onChanged: (value) => authProvider.setLastName(value),
        ),
        const SizedBox(height: 16),

        // Email Field
        CustomTextField(
          hintText: 'Email address',
          suffixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => authProvider.setEmail(value),
        ),
        const SizedBox(height: 16),

        // Password Field
        CustomTextField(
          hintText: 'Password',
          suffixIcon: Icons.lock_outline,
          isPassword: true,
          onChanged: (value) => authProvider.setPassword(value),
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        CustomTextField(
          hintText: 'Confirm Password',
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
              onChanged: (value) => authProvider.setAgreeTerms(value ?? false),
            ),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: 'I agree with the '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(color: Color(0xFF1E88E5)),
                    ),
                    TextSpan(text: ' of Clarity'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CustomPrimaryButton(
          buttonBackgroundColor: AppColors.bluePrimaryColor,
          buttonName: 'Sign up',
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
            const Text("Don't have an account?"),
            TextButton(
              onPressed: () {
                authProvider.resetForm();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              child: const Text(
                'Sign in',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
