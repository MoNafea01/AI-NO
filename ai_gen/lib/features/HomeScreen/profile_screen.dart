import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_state.dart';
import 'package:ai_gen/features/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/HomeScreen/widgets/build_profile_info.dart';
import 'package:ai_gen/features/HomeScreen/widgets/edit_profile_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ProfileLoaded) {
          final profile = state.profile;
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.appBackgroundColor,
              title: const Text('User Profile'),
              elevation: 2,
              centerTitle: false,
              actions: [
                Tooltip(
                  message: 'Edit Profile',
                  child: TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            EditProfileDialog(profile: profile),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Tooltip(
                  message: 'Back to Home',
                  child: TextButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    label: const Text('Back to Home'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header section with avatar placeholder
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                '${profile.firstName[0]}${profile.lastName[0]}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${profile.firstName} ${profile.lastName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  Text(
                                    '@${profile.username}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Profile details section
                        Text(
                          'Account Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        // Using a more structured grid for profile details
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          childAspectRatio: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            buildInfoTile(context, 'Email', profile.email),
                            buildInfoTile(
                                context, 'Username', profile.username),
                            buildInfoTile(
                                context, 'First Name', profile.firstName),
                            buildInfoTile(
                                context, 'Last Name', profile.lastName),
                          ],
                        ),
                      ],
                    ),
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
              onPressed: () {
                context.read<ProfileCubit>().loadProfile();
              },
              child: const Text('Load Profile'),
            ),
          ),
        );
      },
    );
  }
}
