import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/modelScreen/cubit/model_screen_cubit.dart';
import 'package:ai_gen/features/modelScreen/cubit/model_screen_state.dart';
import 'package:ai_gen/features/modelScreen/widgets/model_card.dart';

import 'package:ai_gen/features/node_view/presentation/node_view.dart';
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
      backgroundColor: const Color(0xffF2F2F2),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 76.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 90),
            const Text(
              'Models',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // Header Text
            const Text(
              'Discover and use thousands of machine learning models, including the most popular \ndiffusion models and LLMs.',
              style: TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14,
                color: Color(0xff666666),
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xff999999), width: 1.4),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xffF2F2F2),
                          hintText: 'Search',
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.appFontName,
                            fontSize: 16,
                            color: Color(0xff666666),
                          ),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xff666666)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Color(0xff666666)),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<ModelsCubit>()
                                        .searchModels('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          context.read<ModelsCubit>().searchModels(value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Your Models Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Models',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: Color(0xff666666),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Models Grid
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
                          Text('Error: ${state.errMsg}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<ModelsCubit>().loadModels(),
                            child: const Text('Retry'),
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
                              size: 64, color: Color(0xff666666)),
                          const SizedBox(height: 16),
                          Text('No results found for: "${state.query}"'),
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
                                size: 64, color: Color(0xff666666)),
                            SizedBox(height: 16),
                            Text('No models found '
                                'You can add models from the AI Model Store.'),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        childAspectRatio: 4 / 1.8, // details width to height ratio
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
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
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



 

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

