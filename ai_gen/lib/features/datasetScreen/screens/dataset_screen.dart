import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/datasetScreen/cubit/dataset_screen.dart';
import 'package:ai_gen/features/datasetScreen/cubit/dataset_screen_cubit.dart';
import 'package:ai_gen/features/datasetScreen/widgets/build_project_item.dart';
import 'package:ai_gen/features/datasetScreen/widgets/show_project_dialog.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
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
      backgroundColor: const Color(0xffF2F2F2),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 76.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 90),
            const Text(
              'Datasets',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontFamily: AppConstants.appFontName,
                color: Colors.black,
              ),
            ),
            // Header Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                'Discover and use high-quality datasets for training and\n fine-tuning machine learning models.',
                style: TextStyle(
                  fontFamily: AppConstants.appFontName,
                  fontSize: 14,
                  color: Color(0xff666666),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                        .read<DatasetsCubit>()
                                        .searchDatasets('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          context.read<DatasetsCubit>().searchDatasets(value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xffF2F2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xff999999)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        const Text(
                          'Filter',
                          style: TextStyle(
                              color: Color(0xff666666),
                              fontWeight: FontWeight.w600,
                              fontFamily: AppConstants.appFontName),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Your Datasets Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.dataset_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Datasets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConstants.appFontName,
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
                        fontFamily: AppConstants.appFontName,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Datasets Grid
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
                          Text('Error: ${state.errMsg}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<DatasetsCubit>().loadDatasets(),
                            child: const Text('Retry'),
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
                          Text('No results found for: "${state.query}"'),
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
                            Text('No datasets available'),
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
                          childAspectRatio:  4 / 1.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
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

class DatasetCard extends StatelessWidget {
  final String datasetName;
  final List<ProjectModel> projects;

  const DatasetCard({
    required this.datasetName, required this.projects, super.key,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dataset Name
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
                const SizedBox(height: 4),
 
                Text(
                  userProfile?.username ?? 'Guest',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff666666),
                  ),
                ),
                const SizedBox(height: 8),
                // Dataset Type/Category
                const Text(
                  'Dataset Collection',
                  style: TextStyle(
                    fontSize: 12,
                       color: Color(0xff666666),
                      fontFamily: AppConstants.appFontName
                  ),
                ),
                const SizedBox(height: 8),

                // Project count and variation info
                Text(
                  '${projects.length} Projects • ${getUniqueModelsCount(projects)} Models',
                  style: const TextStyle(
                    fontSize: 12,
                      color: Color(0xff666666),
                      fontFamily: AppConstants.appFontName
                  ),
                ),
                const SizedBox(height: 8),

                // Description (using first project's info or general description)
                Text(
                  projects.isNotEmpty && projects.first.description != null
                      ? projects.first.description!
                      : 'A comprehensive dataset for training and evaluation',
                  style: const TextStyle(
                    fontSize: 12,
                     color: Color(0xff666666),
                      fontFamily: AppConstants.appFontName
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const Spacer(),

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
                      const Icon(Icons.analytics_outlined,
                          size: 15.5,   color: Color(0xff666666),
                          ),
                      const SizedBox(width: 4),
                      Text(
                        '${projects.length }', 
                        style: const TextStyle(
                          fontSize: 12,
                             color: Color(0xff666666),
                            fontFamily: AppConstants.appFontName
                        ),
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
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.green[600],
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
