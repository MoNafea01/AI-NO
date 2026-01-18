import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';


class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final Widget? testimonial;
  final Animation<Offset>? slideAnimation;

  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.form,
    super.key,
    this.testimonial,
    this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Blue Banner with Animation
          Expanded(
            flex: 3,
            child: slideAnimation != null
                ? SlideTransition(
                    position: slideAnimation!,
                    child: _buildLeftSide(),
                  )
                : _buildLeftSide(),
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

  Widget _buildLeftSide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bluePrimaryColor,
            AppColors.bluePrimaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (testimonial != null) const SizedBox(height: 48),
          if (testimonial != null) testimonial!,
        ],
      ),
    );
  }
}
