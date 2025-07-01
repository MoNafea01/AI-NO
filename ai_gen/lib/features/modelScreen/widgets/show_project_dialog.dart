import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/modelScreen/widgets/build_project_item.dart';
import 'package:flutter/material.dart';

void showProjectsDialog(
    BuildContext context, String modelName, List<ProjectModel> projects) {
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
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.5,
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
                    modelName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
              '${projects.length} Projects',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff666666),
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
