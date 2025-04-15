import 'package:ai_gen/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreeToTerms = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void _onSignUp(BuildContext context) {
    if (_formKey.currentState!.validate() && agreeToTerms) {
      context.read<AuthCubit>().signUp(
            fullName: fullNameController.text,
            email: emailController.text,
            password: passwordController.text,
            confirmPassword: confirmPasswordController.text,
          );
    } else if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms & Conditions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, '/signin');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Sign Up",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            CustomTextField(
              controller: fullNameController,
              hintText: 'Full name',
              icon: Icons.person_outline,
              validator: (value) =>
                  value!.isEmpty ? 'Full name is required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: emailController,
              hintText: 'Email address',
              icon: Icons.email_outlined,
              validator: (value) =>
                  value!.contains('@') ? null : 'Enter a valid email',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: passwordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () =>
                    setState(() => obscurePassword = !obscurePassword),
              ),
              validator: (value) => value!.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () => setState(
                    () => obscureConfirmPassword = !obscureConfirmPassword),
              ),
              validator: (value) => value != passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  onChanged: (value) =>
                      setState(() => agreeToTerms = value ?? false),
                ),
                const Text("I agree with the "),
                GestureDetector(
                  onTap: () {
                    // open terms URL or show dialog
                  },
                  child: const Text(
                    "Terms & Conditions",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onSignUp(context),
                child: const Text("Sign Up"),
              ),
            ),
            const SizedBox(height: 24),

            // Socials (can be expanded later)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialIconButton(icon: Icons.g_mobiledata),
                SizedBox(width: 12),
                SocialIconButton(icon: Icons.apple),
                SizedBox(width: 12),
                SocialIconButton(icon: Icons.facebook),
                SizedBox(width: 12),
                SocialIconButton(icon: Icons.code), // GitHub
              ],
            ),
            const SizedBox(height: 24),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/signin'),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.blue),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
