import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';

Widget buildProjectItem(BuildContext context, ProjectModel project) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // Close dialog first
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NodeView(projectModel: project),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name ?? 'Unnamed Project',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (project.description != null) ...[
              const SizedBox(height: 8),
              Text(
                project.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (project.dataset != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.dataset_outlined,
                      size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Dataset: ${project.dataset}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ],
            if (project.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Created: ${project.createdAt!.toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
