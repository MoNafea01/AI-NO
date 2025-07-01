import 'package:ai_gen/features/modelScreen/cubit/model_screen_cubit.dart';
import 'package:ai_gen/features/modelScreen/cubit/model_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_gen/core/models/project_model.dart';


class ModelsScreen extends StatelessWidget {
  const ModelsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ModelsCubit()..loadModels(),
      child: const ModelsView(),
    );
  }
}

class ModelsView extends StatefulWidget {
  const ModelsView({Key? key}) : super(key: key);

  @override
  State<ModelsView> createState() => _ModelsViewState();
}

class _ModelsViewState extends State<ModelsView> {
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
        title: const Text('النماذج المتاحة'),
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
                hintText: 'البحث في النماذج والمشاريع...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ModelsCubit>().searchModels('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                context.read<ModelsCubit>().searchModels(value);
              },
            ),
          ),
          // Models List
          Expanded(
            child: BlocBuilder<ModelsCubit, ModelsState>(
              builder: (context, state) {
                if (state is ModelsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ModelsFailure) {
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
                              context.read<ModelsCubit>().loadModels(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ModelsSearchEmpty) {
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
                } else if (state is ModelsSuccess) {
                  final modelsWithProjects = state.modelsWithProjects;

                  if (modelsWithProjects.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.model_training,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('لا توجد نماذج متاحة'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: modelsWithProjects.length,
                    itemBuilder: (context, index) {
                      final modelName =
                          modelsWithProjects.keys.elementAt(index);
                      final projects = modelsWithProjects[modelName]!;

                      return ModelCard(
                        modelName: modelName,
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

class ModelCard extends StatefulWidget {
  final String modelName;
  final List<ProjectModel> projects;

  const ModelCard({
    Key? key,
    required this.modelName,
    required this.projects,
  }) : super(key: key);

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.model_training, color: Colors.white),
            ),
            title: Text(
              widget.modelName,
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
                          subtitle: project.description != null
                              ? Text(
                                  project.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
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
                                if (project.dataset != null)
                                  Text(
                                    'البيانات: ${project.dataset}',
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
