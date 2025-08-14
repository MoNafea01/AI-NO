import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/cubit/docsScreen_state.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/widgets/build_empty_projects_list.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/widgets/build_project_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildSuccessState(AdvancedSearchSuccess state) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Results Header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.search_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              '${TranslationKeys.searchResults.tr} (${state.projects.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: AppConstants.appFontName,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Results List
      Expanded(
        child: state.projects.isEmpty
            ? buildEmptyProjectsList()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  return buildProjectCard(project, context);
                },
              ),
      ),
    ],
  );
}
