// ignore_for_file: deprecated_member_use

import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

Widget logoutButton(BuildContext context, bool isExpanded) {
  final authProvider = Provider.of<AuthProvider>(context);

  return InkWell(
    onTap:
        authProvider.isLoggingOut ? null : () => authProvider.logout(context),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: isExpanded
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  AssetsPaths.logOutIcon,
                  width: 40,
                  height: 40,
                  color: authProvider.isLoggingOut
                      ? Colors.grey
                      : const Color(0xffFF3333),
                ),
                
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authProvider.isLoggingOut
                        ? 'Logging out...'
                        : TranslationKeys.logOut.tr,
                    style: TextStyle(
                        color: authProvider.isLoggingOut
                            ? Colors.grey
                            : const Color(0xffFF3333),
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        fontFamily: AppConstants.appFontName),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            )
          : Center(
              child: Image.asset(
                AssetsPaths.logOutIcon,
                width: 90,
                height: 90,
                color: authProvider.isLoggingOut
                    ? Colors.grey
                    : const Color(0xffFF3333),
              ),
            ),
    ),
  );
}
