import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/HomeScreen/cubit/dashboard_cubit/dash_board_cubit.dart';
import 'package:ai_gen/features/auth/data/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

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
              // onTap: () {
              //   context.read<ProfileCubit>().loadProfile();
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const ProfileScreen()),
              //   );
              // },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  TranslationKeys.profile.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
                  color: AppColors.bluePrimaryColor,
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
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xff191D23),
                          fontFamily: AppConstants.appFontName,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email ?? 'example@email.com',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffA0ABBB),
                          fontFamily: AppConstants.appFontName,
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
