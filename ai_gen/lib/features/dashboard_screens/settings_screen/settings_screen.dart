import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/HomeScreen/screens/profile_screen.dart';
import 'package:ai_gen/features/auth/presentation/change_password_screen/presntation/pages/change_password_screen.dart';
import 'package:ai_gen/features/dashboard_screens/settings_screen/cubits/settings_cubit.dart';
import 'package:ai_gen/features/dashboard_screens/settings_screen/language_screen.dart';
import 'package:ai_gen/features/dashboard_screens/settings_screen/widgets/build_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 90),
              Text(
                TranslationKeys.settings.tr,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppConstants.appFontName,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                TranslationKeys.settingsDescription.tr,
                style: const TextStyle(
                  fontFamily: AppConstants.appFontName,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff666666),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // BLoC Tabs and Content
              BlocBuilder<SettingsCubit, int>(
                builder: (context, currentTab) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tabs
                        Container(
                          color: Colors.grey.shade200,
                          // decoration: BoxDecoration(

                          //   border: Border(
                          //     bottom: BorderSide(
                          //       color: Colors.grey.shade300,
                          //       width: 1,
                          //     ),
                          //   ),
                          // ),
                          child: Row(
                            children: [
                              buildTab(context, TranslationKeys.profile.tr, 0,
                                  currentTab),
                              buildTab(context, TranslationKeys.account.tr, 1,
                                  currentTab),
                              // buildTab(context, TranslationKeys.appearance.tr,
                              //     2, currentTab),
                              buildTab(context, TranslationKeys.language.tr, 2,
                                  currentTab),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 1,
                          color: Colors.transparent,
                        ),
                        const SizedBox(height: 32),

                        // Tab Content
                        Expanded(
                          child: IndexedStack(
                            index: currentTab,
                            children: const [
                              ProfileScreen(),
                              ChangePasswordScreen(),
                              //  PreferenceModeSelector(),
                              LanguageView()
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
