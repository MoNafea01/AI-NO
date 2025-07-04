

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:ai_gen/features/auth/presentation/widgets/outlinedPrimaryButton.dart';
import 'package:ai_gen/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:ai_gen/features/request_otp_screen/presentation/pages/request_otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set preferred orientation to portrait for better UX on mobile
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout logic
        final isTabletOrLarger = constraints.maxWidth > 600;

        return Scaffold(
          body: isTabletOrLarger
              ? _buildTabletLayout(context)
              : _buildMobileLayout(context),
        );
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Left Side - Blue Banner
        Expanded(
          flex: 2,
          child: Container(
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
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Sign in to continue designing and refining your models.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
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
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Mobile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.bluePrimaryColor,
                      AppColors.bluePrimaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Form
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: const LoginForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _formOpacity;
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  bool _isFormVisible = true;
  bool _showSuccessAnimation = false;
  late AuthProvider authProvider;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    // Add listeners to focus nodes to trigger animations or validations
    emailFocusNode.addListener(_onFocusChange);
    passwordFocusNode.addListener(_onFocusChange);

    // Delay to ensure the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.addLoginListener(_onLoginStateChanged);
    });
  }

  void _onFocusChange() {
  
    setState(() {});
  }

  void _onLoginStateChanged(LoginState state) {
    if (state == LoginState.success) {
      setState(() {
        _isFormVisible = false;
        _showSuccessAnimation = true;
      });

      // Wait for success animation before navigation
      Future.delayed(const Duration(milliseconds: 1500), () {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.completeNavigation(context);
      });
    }
  }
@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }




  @override
  void dispose() {

    _animationController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    // Remove listener on dispose
   //authProvider.removeLoginListener(_onLoginStateChanged); 
    authProvider.removeLoginListener(_onLoginStateChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AnimatedOpacity(
      opacity: _isFormVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: _formOpacity,
            child: _showSuccessAnimation
                ? _buildSuccessAnimation()
                : _buildLoginForm(authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 80,
        ),
        const SizedBox(height: 16),
        Text(
          TranslationKeys.loginSuccessful.tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          TranslationKeys.redirectingToDashboard.tr,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           Text(
            TranslationKeys.welcomeBack.tr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Email Field
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              boxShadow: emailFocusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: AppColors.bluePrimaryColor.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: CustomTextField(
              hintText: TranslationKeys.emailHintText.tr,
              suffixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              focusNode: emailFocusNode,
              onChanged: (value) {
                authProvider.setEmail(value);
                // Only validate when user stops typing
                Future.delayed(const Duration(milliseconds: 500), () {
                  authProvider.validateEmail(value);
                });
              },
              errorText: authProvider.emailError,
              showError: authProvider.emailError != null,
              prefixIcon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 16),

          // Password Field
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              boxShadow: passwordFocusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: AppColors.bluePrimaryColor.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: CustomTextField(
              hintText: TranslationKeys.passwordHintText.tr,
              suffixIcon: Icons.visibility_outlined,
              focusNode: passwordFocusNode,
              isPassword: true,
              onChanged: (value) {
                authProvider.setPassword(value);
                // Only validate when user stops typing
                Future.delayed(const Duration(milliseconds: 500), () {
                  authProvider.validatePassword(value);
                });
              },
              errorText: authProvider.passwordError,
              showError: authProvider.passwordError != null,
              prefixIcon: Icons.lock_outline,
            ),
          ),
          const SizedBox(height: 8),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: authProvider.rememberMe,
                      onChanged: (value) =>
                          authProvider.setRememberMe(value ?? false),
                      activeColor: AppColors.bluePrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                   Text(
                    TranslationKeys.rememberMe.tr,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to forgot password screen
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RequestOtpScreen()),
                  );
                },
                child:  Text(
                 TranslationKeys.forgotPassword.tr,
                  style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Sign In Error Message
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: authProvider.signInError != null ? 50 : 0,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: authProvider.signInError != null
                ? Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.signInError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),

          const SizedBox(height: 24),

          // Login status message
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: authProvider.loginStatus != null ? 30 : 0,
            child: authProvider.loginStatus != null
                ? Center(
                    child: Text(
                      authProvider.loginStatus!,
                      style: const TextStyle(
                        color: AppColors.bluePrimaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 8),

          // Sign In Button
          CustomPrimaryButton(
            buttonBackgroundColor: AppColors.bluePrimaryColor,
            buttonName: TranslationKeys.signIn.tr,
            textButtonColor: AppColors.appBackgroundColor,
            onPressed: () => authProvider.signIn(context),
            isLoading: authProvider.isSigningIn,
          ),
          const SizedBox(height: 24),

          // Social Sign In
           Text(
           TranslationKeys.orSignInWith.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
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
               Text(
                TranslationKeys.dontHaveAnAccount.tr,
                style: const TextStyle(color: Colors.black54),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const SignupScreen(),
                      transitionDuration: const Duration(milliseconds: 500),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child:  Text(
                  TranslationKeys.createFreeAccount.tr,
                  style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
