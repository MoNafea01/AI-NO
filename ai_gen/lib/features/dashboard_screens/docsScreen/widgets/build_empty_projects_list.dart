import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildEmptyProjectsList() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          TranslationKeys.noProjectsFound.tr,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontFamily: AppConstants.appFontName,
          ),
        ),
      ],
    ),
  );
}
