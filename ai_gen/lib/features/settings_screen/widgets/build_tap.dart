import 'package:ai_gen/features/settings_screen/cubits/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildTab(BuildContext context, String title, int index, int currentTab) {
  final isSelected = currentTab == index;

  return GestureDetector(
    onTap: () {
      context.read<SettingsCubit>().setCurrentTab(index);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
       // color: const Color(0xffCCCCCC),
        border: Border(
          bottom: BorderSide(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          //color: isSelected ? Colors.blue : Colors.grey[700],
          //  color: isSelected ? const Color(0xff000000) : const Color(0xff666666),
          color: const Color(0xff000000),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    ),
  );
}
