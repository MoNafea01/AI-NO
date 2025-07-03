// Enhanced ProfileScreen with better error handling and user experience
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_state.dart';
import 'package:ai_gen/features/HomeScreen/screens/new_dashboard_screen.dart';
import 'package:ai_gen/features/HomeScreen/widgets/edit_profile_dialog.dart';

import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final fullNameFirstController = TextEditingController();
  final fullNameLastController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBioFromPrefs();

    // Load profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    fullNameFirstController.dispose();
    fullNameLastController.dispose();
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && !_isAppInForeground) {
      // App came back to foreground, refresh profile
      _isAppInForeground = true;
      context.read<ProfileCubit>().refreshProfile();
    } else if (state == AppLifecycleState.paused) {
      _isAppInForeground = false;
    }
  }

  Future<void> _loadBioFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBio = prefs.getString('user_bio') ?? '';
      if (mounted) {
        setState(() {
          bioController.text = savedBio;
        });
      }
    } catch (e) {
      debugPrint('Error loading bio: $e');
    }
  }

  Future<void> _saveBioToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_bio', bioController.text.trim());
    } catch (e) {
      debugPrint('Error saving bio: $e');
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationKeys.logout.tr),
        content: const Text(TranslationKeys.sessionExpiredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(TranslationKeys.cancel.tr),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(TranslationKeys.loginAgain.tr),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout(context);
    }
  }

  Widget _buildErrorWidget(String message) {
    final isAuthError = message.contains('session has expired') ||
        message.contains('log in again') ||
        message.contains('Authentication error');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAuthError ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: isAuthError ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isAuthError
                  ? TranslationKeys.sessionExpired.tr
                  : TranslationKeys.errorLoadingProfile.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isAuthError ? Colors.orange : Colors.red,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (isAuthError) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: _handleLogout,
                child: Text(TranslationKeys.loginAgain.tr),
              ),
            ] else ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.bluePrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      context.read<ProfileCubit>().retry();
                    },
                    child: Text(TranslationKeys.tryAgain.tr),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const DashboardScreen()),
                      );
                    },
                    child: Text(TranslationKeys.goToDashboard.tr),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          TranslationKeys.profile.tr,
          style: const TextStyle(color: Color(0xff666666)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xff666666)),
            onPressed: () {
              context.read<ProfileCubit>().refreshProfile();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            // Show snackbar for immediate feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: TranslationKeys.retry.tr,
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ProfileCubit>().retry();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.bluePrimaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(TranslationKeys.loadProfile.tr),
                ],
              ),
            );
          } else if (state is ProfileLoaded) {
            final profile = state.profile;

            // Update controllers with profile data
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                fullNameFirstController.text = profile.firstName;
                fullNameLastController.text = profile.lastName;
                usernameController.text = profile.username;
                emailController.text = profile.email;
              }
            });

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileCubit>().refreshProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(TranslationKeys.nameLabel.tr,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: fullNameFirstController,
                            hintText: TranslationKeys.firstName.tr,
                            icon: Icons.person,
                            onChanged: (value) {
                              // Optional: Auto-save on change
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: fullNameLastController,
                            hintText: TranslationKeys.lastName.tr,
                            icon: Icons.person,
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(TranslationKeys.username.tr,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: usernameController,
                      icon: Icons.person,
                      onChanged: (value) {
                        // Optional: Auto-save on change
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(TranslationKeys.emailAddress.tr,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: emailController,
                      icon: Icons.email,
                      onChanged: (value) {
                        // Optional: Auto-save on change
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(TranslationKeys.bioLabel.tr,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: TranslationKeys.writeAboutYourself.tr,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                              color: Color(0xff666666), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                              color: Color(0xff666666), width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        _saveBioToPrefs();
                      },
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bluePrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        onPressed: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => EditProfileDialog(
                              profile: profile,
                              currentBio: bioController.text,
                            ),
                          );

                          if (result == true && mounted) {
                            context.read<ProfileCubit>().loadProfile();
                            await _loadBioFromPrefs();
                          }
                        },
                        child: Text(TranslationKeys.saveChanges.tr,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProfileError) {
            return _buildErrorWidget(state.message);
          }

          // Initial state
          return Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () {
                context.read<ProfileCubit>().loadProfile();
              },
              child: Text(TranslationKeys.loadProfile.tr,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          );
        },
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;
  final Function(String)? onChanged;

  const CustomTextField({
    required this.controller,
    super.key,
    this.hintText,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText ?? controller.text,
        prefixIcon: icon != null ? Icon(icon, color: Color(0xff666666)) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xff666666), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xff666666), width: 1),
        ),
      ),
    );
  }
}
