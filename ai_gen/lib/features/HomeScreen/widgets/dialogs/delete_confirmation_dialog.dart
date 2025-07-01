import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final List<int> projectIds;
  final List<String> projectNames;
  final Function(List<int>) onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.projectIds,
    required this.projectNames,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final projectCount = projectIds.length;
    final projectText = projectCount == 1 ? 'project' : 'projects';

    return AlertDialog(
      title: Text(
        'Delete ${projectCount == 1 ? 'Project' : '$projectCount Projects'}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete ${projectCount == 1 ? 'this' : 'these'} $projectText? This action cannot be undone.',
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
          if (projectCount <= 5) ...[
            const SizedBox(height: 12),
            const Text(
              'Projects to be deleted:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            ...projectNames
                .map((name) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm(projectIds);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
          child: Text('Delete ${projectCount == 1 ? '' : '($projectCount)'}'),
        ),
      ],
    );
  }
}
