import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/datasetScreen/widgets/build_project_item.dart';
import 'package:flutter/material.dart';

void showProjectsDialog(
    BuildContext context, String datasetName, List<ProjectModel> projects) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF2F2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff999999)),
        ),
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    datasetName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff666666),
                      fontFamily: AppConstants.appFontName,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              '${projects.length} Projects • ${getUniqueModelsCount(projects)} Models',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff666666),
                fontFamily: AppConstants.appFontName,
              ),
            ),
            const SizedBox(height: 20),

            // Projects List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: projects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return buildProjectItem(context, project);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
int getUniqueModelsCount(List<ProjectModel> projects) {
  final Set<String> uniqueModels = {};
  for (final project in projects) {
    if (project.model != null && project.model!.isNotEmpty) {
      uniqueModels.add(project.model!);
    }
  }
  return uniqueModels.length;
}
