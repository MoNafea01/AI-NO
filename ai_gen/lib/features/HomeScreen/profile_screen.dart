import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_state.dart';
import 'package:ai_gen/features/HomeScreen/new_dashboard_screen.dart';

import 'package:ai_gen/features/HomeScreen/widgets/edit_profile_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fullNameFirstController = TextEditingController();
    final fullNameLastController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();

    final bioController = TextEditingController();
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.bluePrimaryColor,
              ),
            ),
          );
        } else if (state is ProfileLoaded) {
          final profile = state.profile;
          fullNameFirstController.text = profile.firstName;
          fullNameLastController.text = profile.lastName;
          usernameController.text = profile.username;
          emailController.text = profile.email;
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            // appBar: AppBar(
            //   automaticallyImplyLeading: false,
            //   backgroundColor: AppColors.appBackgroundColor,
            //   title: const Text('User Profile'),
            //   elevation: 2,
            //   centerTitle: false,
            //   actions: [
            //     Tooltip(
            //       message: 'Edit Profile',
            //       child: TextButton.icon(
            //         icon: const Icon(Icons.edit),
            //         label: const Text('Edit Profile'),
            //         onPressed: () {
            //           showDialog(
            //             context: context,
            //             builder: (context) =>
            //                 EditProfileDialog(profile: profile),
            //           );
            //         },
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     Tooltip(
            //       message: 'Back to Home',
            //       child: TextButton.icon(
            //         icon: const Icon(Icons.arrow_back_ios_new_outlined),
            //         label: const Text('Back to Home'),
            //         onPressed: () {
            //           Navigator.pushReplacement(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => const DashboardScreen(),
            //             ),
            //           );
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text("Name:", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: fullNameFirstController,
                              hintText: 'First name',
                              icon: Icons.person,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomTextField(
                              controller: fullNameLastController,
                              hintText: 'Last name',
                              icon: Icons.person,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text("Username:", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: usernameController,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 20),
                      const Text("Email Address:",
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: emailController,
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 20),
                      const Text("Bio:", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: bioController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write about yourself',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  EditProfileDialog(profile: profile),
                            );
                          },
                          child: const Text("Save changes",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state is ProfileError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileCubit>().loadProfile();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: Center(
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
              child: const Text('Load Profile',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;

  const CustomTextField({
    required this.controller,
    super.key,
    this.hintText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText ?? controller.text,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
