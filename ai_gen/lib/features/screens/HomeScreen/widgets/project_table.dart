// Projects Table Widget
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsTable extends StatelessWidget {
  const ProjectsTable({super.key});

  @override
  Widget build(BuildContext context) {
    HomeSuccess homeState = context.watch<HomeCubit>().state as HomeSuccess;

    if (homeState.projects.isEmpty) {
      return const Center(
        child: Text(
          "No Projects Found",
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columnSpacing: 20,
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 60,
                  columns: const [
                    DataColumn(
                      label: Expanded(
                        child:
                            Text("Project Name", textAlign: TextAlign.center),
                      ),
                    ),
                    DataColumn(
                        label: Expanded(
                            child: Text("Created At",
                                textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child: Text("Last Update",
                                textAlign: TextAlign.center))),
                    DataColumn(
                        label: Expanded(
                            child: Text("Description",
                                textAlign: TextAlign.center))),
                  ],
                  rows: homeState.projects
                      .map(
                        (project) => DataRow(
                          cells: [
                            DataCell(
                              Center(child: _projectName(context, project)),
                            ),
                            DataCell(
                              Center(child: Text(project.createdAt.toString())),
                            ),
                            DataCell(
                              Center(child: Text(project.updatedAt.toString())),
                            ),
                            DataCell(
                              Center(child: Text(project.description ?? "")),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  TextButton _projectName(BuildContext context, ProjectModel project) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.bluePrimaryColor,
        minimumSize: const Size(100, 50),
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NodeView(projectModel: project),
          ),
        );
      },
      child: Text(project.name ?? "Project Name"),
    );
  }
}
