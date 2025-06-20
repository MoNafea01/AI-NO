import 'package:ai_gen/features/settings_screen/cubits/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildTab(
      BuildContext context, String title, int index, int currentTab) {
    final isSelected = currentTab == index;

    return GestureDetector(
      onTap: () {
        context.read<SettingsCubit>().setCurrentTab(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
