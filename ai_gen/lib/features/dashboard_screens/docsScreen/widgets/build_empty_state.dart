import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/cubit/docsScreen_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildEmptyState(AdvancedSearchEmpty state) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          TranslationKeys.NoResultsFound.tr,
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
