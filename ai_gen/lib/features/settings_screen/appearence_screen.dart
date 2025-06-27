import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/settings_screen/cubits/theme_cubit/theme_cubit.dart';
import 'package:ai_gen/features/settings_screen/cubits/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PreferenceModeSelector extends StatefulWidget {
  const PreferenceModeSelector({super.key});

  @override
  State<PreferenceModeSelector> createState() => _PreferenceModeSelectorState();
}

enum ThemeModePreference {
  // system,

  light,
  dark
}

class _PreferenceModeSelectorState extends State<PreferenceModeSelector> {
  ThemeModePreference selected = ThemeModePreference.light; // system

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preference mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  final isDarkMode = state.isDarkMode;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // _buildCard(
                      //   icon: Icons.desktop_windows,
                      //   label: 'System theme',
                      //   //  imageAsset: 'assets/system_theme.png',
                      //   value: ThemeModePreference.system,
                      // ),
                      const SizedBox(width: 16), // Spacing between cards
                      _buildCard(
                        icon: Icons.wb_sunny_outlined,
                        label: 'Light theme',
                        //  imageAsset: 'assets/light_theme.png',
                        value: ThemeModePreference.light,
                      ),
                      const SizedBox(width: 16), // Spacing between cards
                      _buildCard(
                        icon: Icons.nights_stay_outlined,
                        label: 'Dark theme',
                        //   imageAsset: 'assets/dark_theme.png',
                        value: ThemeModePreference.dark,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    // required String imageAsset,
    required ThemeModePreference value,
  }) {
    final isSelected = selected == value;
    //final themeCubit = context.read<ThemeCubit>();
    // if (isSelected) {
    //   switch (value) {
    //     // case ThemeModePreference.system:
    //     //   themeCubit.setSystemMode();
    //     //   break;
    //     case ThemeModePreference.light:
    //       themeCubit.setLightMode();
    //       break;
    //     case ThemeModePreference.dark:
    //       themeCubit.setDarkMode();
    //       break;
    //   }
    // }
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = value;
        });
      },
      child: Container(
        width: 200,
        height: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.bluePrimaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Image.asset(imageAsset, height: 80, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
