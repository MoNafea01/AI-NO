import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit.dart';
import 'package:ai_gen/features/HomeScreen/new_dashboard_screen.dart';
import 'package:ai_gen/features/HomeScreen/profile_screen.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<AuthProvider>().userProfile;
    final userName = userProfile?.username;
    final email = userProfile?.email;
    final isExpanded = context.watch<DashboardCubit>().state.isExpanded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExpanded)
            InkWell(
              onTap: () {
                context.read<ProfileCubit>().loadProfile();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 16,
                child: Text(
                  userName?.isNotEmpty == true
                      ? userName![0].toUpperCase()
                      : '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isExpanded) const SizedBox(width: 8),
              if (isExpanded)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName ?? 'Username',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email ?? 'example@email.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
