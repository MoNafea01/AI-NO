// ignore_for_file: deprecated_member_use

import 'package:ai_gen/core/themes/asset_paths.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

Widget logoutButton(BuildContext context, bool isExpanded) {
  final authProvider = Provider.of<AuthProvider>(context);

  return InkWell(
    onTap:
        authProvider.isLoggingOut ? null : () => authProvider.logout(context),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            AssetsPaths.logOutIcon,
            width: 20,
            height: 20,
            color: authProvider.isLoggingOut ? Colors.grey : Colors.red,
          ),
          if (isExpanded) const SizedBox(width: 12),
          if (isExpanded)
            Text(
              authProvider.isLoggingOut ? 'Logging out...' : 'Log out',
              style: TextStyle(
                color: authProvider.isLoggingOut ? Colors.grey : Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
        ],
      ),
    ),
  );
}
