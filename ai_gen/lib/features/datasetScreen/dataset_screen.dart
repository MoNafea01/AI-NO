import 'package:ai_gen/features/datasetScreen/cubit/dataset_screen.dart';
import 'package:ai_gen/features/datasetScreen/cubit/dataset_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_gen/core/models/project_model.dart';


class DatasetsScreen extends StatelessWidget {
  const DatasetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DatasetsCubit()..loadDatasets(),
      child: const DatasetsView(),
    );
  }
}

class DatasetsView extends StatefulWidget {
  const DatasetsView({Key? key}) : super(key: key);

  @override
  State<DatasetsView> createState() => _DatasetsViewState();
}

class _DatasetsViewState extends State<DatasetsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البيانات المتاحة'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث في البيانات والمشاريع...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<DatasetsCubit>().searchDatasets('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                context.read<DatasetsCubit>().searchDatasets(value);
              },
            ),
          ),
          // Datasets List
          Expanded(
            child: BlocBuilder<DatasetsCubit, DatasetsState>(
              builder: (context, state) {
                if (state is DatasetsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DatasetsFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('خطأ: ${state.errMsg}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<DatasetsCubit>().loadDatasets(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                } else if (state is DatasetsSearchEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('لا توجد نتائج للبحث: "${state.query}"'),
                      ],
                    ),
                  );
                } else if (state is DatasetsSuccess) {
                  final datasetsWithProjects = state.datasetsWithProjects;

                  if (datasetsWithProjects.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.dataset, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('لا توجد بيانات متاحة'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: datasetsWithProjects.length,
                    itemBuilder: (context, index) {
                      final datasetName =
                          datasetsWithProjects.keys.elementAt(index);
                      final projects = datasetsWithProjects[datasetName]!;

                      return DatasetCard(
                        datasetName: datasetName,
                        projects: projects,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DatasetCard extends StatefulWidget {
  final String datasetName;
  final List<ProjectModel> projects;

  const DatasetCard({
    Key? key,
    required this.datasetName,
    required this.projects,
  }) : super(key: key);

  @override
  State<DatasetCard> createState() => _DatasetCardState();
}

class _DatasetCardState extends State<DatasetCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: const Icon(Icons.dataset, color: Colors.white),
            ),
            title: Text(
              widget.datasetName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${widget.projects.length} مشروع'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon:
                      Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                PopupMenuButton<ProjectModel>(
                  icon: const Icon(Icons.arrow_drop_down),
                  tooltip: 'اختر مشروع',
                  onSelected: (project) {
                    _showProjectDetails(context, project);
                  },
                  itemBuilder: (context) {
                    return widget.projects.map((project) {
                      return PopupMenuItem<ProjectModel>(
                        value: project,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(project.name ?? 'مشروع بدون اسم'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (project.description != null)
                                Text(
                                  project.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (project.model != null)
                                Text(
                                  'النموذج: ${project.model}',
                                  style: TextStyle(
                                    color: Colors.blue[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المشاريع المرتبطة:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...widget.projects.map((project) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name ?? 'مشروع بدون اسم',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                if (project.description != null)
                                  Text(
                                    project.description!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (project.model != null)
                                  Text(
                                    'النموذج: ${project.model}',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () =>
                                _showProjectDetails(context, project),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showProjectDetails(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name ?? 'تفاصيل المشروع'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (project.description != null) ...[
                const Text('الوصف:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(project.description!),
                const SizedBox(height: 12),
              ],
              if (project.model != null) ...[
                const Text('النموذج:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(project.model!),
                const SizedBox(height: 12),
              ],
              if (project.dataset != null) ...[
                const Text('البيانات:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(project.dataset!),
                const SizedBox(height: 12),
              ],
              if (project.createdAt != null) ...[
                const Text('تاريخ الإنشاء:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(project.createdAt!.toString().split('.')[0]),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
