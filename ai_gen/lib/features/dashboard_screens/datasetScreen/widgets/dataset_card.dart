import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/dashboard_screens/datasetScreen/widgets/show_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DatasetCard extends StatelessWidget {
  final String datasetName;
  final List<ProjectModel> projects;

  const DatasetCard({
    required this.datasetName,
    required this.projects,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<AuthProvider>().userProfile;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff999999)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dataset Name
                Row(
                  children: [
                    Image.asset(
                      AssetsPaths.dataSetsIcon,
                      color: AppColors.bluePrimaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      datasetName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppConstants.appFontName,
                        color: Color(0xff666666),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  userProfile?.username ?? TranslationKeys.guest.tr,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff666666),
                  ),
                ),
                const SizedBox(height: 8),
                // Dataset Type/Category
                Text(
                  TranslationKeys.datasetCollection.tr,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff666666),
                      fontFamily: AppConstants.appFontName),
                ),
                const SizedBox(height: 8),

                // Project count and variation info
                Text(
                  '${projects.length} ${TranslationKeys.projectsCount}${getUniqueModelsCount(projects)} ${TranslationKeys.modelsCount}  ',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff666666),
                      fontFamily: AppConstants.appFontName),
                ),
                const SizedBox(height: 8),

                // Description (using first project's info or general description)
                Text(
                  "${TranslationKeys.modelDescriptionPrefix.tr}${projects.isNotEmpty && projects.first.description != null ? projects.first.description! : TranslationKeys.comprehensiveDatasetDescription.tr}",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff666666),
                      fontFamily: AppConstants.appFontName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const Divider(
            color: Color(0xff999999),
            height: 1,
          ),

          // Bottom section with icons
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Usage count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 15.5,
                        color: Color(0xff666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${projects.length}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff666666),
                            fontFamily: AppConstants.appFontName),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action buttons
                Row(
                  children: [
                    // Profile/User icon
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: AppColors.bluePrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Arrow/Menu button
                    InkWell(
                      onTap: () =>
                          showProjectsDialog(context, datasetName, projects),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_right,
                          size: 18,
                          color: Color(0xff666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
