

import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/asset_paths.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ai_gen/features/auth/presentation/widgets/outlinedPrimaryButton.dart';
import 'package:ai_gen/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Blue Banner
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFF1E88E5),
              padding: const EdgeInsets.all(32.0),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back to\nModel Craft!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sign in to continue designing and refining your models.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side - Login Form
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: const LoginForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomTextField(
            hintText: 'Email address',
            suffixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: authProvider.setEmail,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: 'Password',
            suffixIcon: Icons.lock_outline,
            isPassword: true,
            onChanged: authProvider.setPassword,
          ),
          const SizedBox(height: 8),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: authProvider.rememberMe,
                    onChanged: (value) =>
                        authProvider.setRememberMe(value ?? false),
                  ),
                  const Text('Remember me'),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: Color(0xFF1E88E5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          CustomPrimaryButton(
            buttonBackgroundColor: AppColors.bluePrimaryColor,
            buttonName: 'Sign in',
            textButtonColor: AppColors.appBackgroundColor,
            onPressed: () {
              authProvider.signIn(context);
              // if (authProvider.isValidEmail(authProvider.email) &&
              //     authProvider.password.isNotEmpty) {
              //   authProvider.signIn(context);
              // } else {
              //   _showErrorDialog(context, 'Please enter valid credentials.');
              // }
            },
          ),
          const SizedBox(height: 24),

          // Social Sign In
          const Text(
            'Or sign in with',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialSignInButton(label: AssetsPaths.googleLogo),
              SizedBox(width: 8),
              SocialSignInButton(label: AssetsPaths.appleLogo),
              SizedBox(width: 8),
              SocialSignInButton(label: AssetsPaths.facebookLogo),
              SizedBox(width: 8),
              SocialSignInButton(label: AssetsPaths.githubLogo),
            ],
          ),
          const SizedBox(height: 24),

          // Create Account
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignupScreen()),
                  );

                 // Navigator.pop(context);
                },
                child: const Text(
                  'Create free account',
                  style: TextStyle(color: Color(0xFF1E88E5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
