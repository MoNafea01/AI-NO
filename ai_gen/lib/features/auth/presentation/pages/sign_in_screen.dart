import 'package:ai_gen/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_header.dart';
import 'package:ai_gen/features/auth/presentation/widgets/custom_button.dart';
import 'package:ai_gen/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void _onSignIn() async {
    setState(() => isLoading = true);

    // Call your login API here and handle tokens etc...

    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthHeader(
                title: "Welcome Back!",
                subtitle: "Please sign in to your account",
              ),
              CustomTextField(
                label: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: "Password",
                controller: passwordController,
                obscureText: true,
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Sign In",
                onPressed: _onSignIn,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()));
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
