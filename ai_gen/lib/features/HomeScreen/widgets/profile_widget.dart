
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/HomeScreen/cubit/dashboard_cubit/dash_board_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_cubit.dart';

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
            const InkWell(
              // onTap: () {
              //   context.read<ProfileCubit>().loadProfile();
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const ProfileScreen()),
              //   );
              // },
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF5F5F5),
                radius: 26,
                child: Icon(
                  Icons.person,
                  color: AppColors.primaryColor,
                  size: 35,
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
