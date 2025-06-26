import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SocialSignInButton extends StatelessWidget {
  final String label;

  const SocialSignInButton({
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          label,
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final Widget? testimonial;

  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.form,
    super.key,
    this.testimonial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Blue Banner
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.bluePrimaryColor,
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (testimonial != null) const SizedBox(height: 48),
                  if (testimonial != null) testimonial!,
                ],
              ),
            ),
          ),

          // Right Side - Form
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: form,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
