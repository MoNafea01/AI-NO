import 'package:ai_gen/features/datasetScreen/cubit/dataset_screen.dart';
import 'package:ai_gen/features/datasetScreen/cubit/dataset_screen_cubit.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_gen/core/models/project_model.dart';


// class DatasetsScreen extends StatelessWidget {
//   const DatasetsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => DatasetsCubit()..loadDatasets(),
//       child: const DatasetsView(),
//     );
//   }
// }

// class DatasetsView extends StatefulWidget {
//   const DatasetsView({Key? key}) : super(key: key);

//   @override
//   State<DatasetsView> createState() => _DatasetsViewState();
// }

// class _DatasetsViewState extends State<DatasetsView> {
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('البيانات المتاحة'),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'البحث في البيانات والمشاريع...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           context.read<DatasetsCubit>().searchDatasets('');
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: (value) {
//                 context.read<DatasetsCubit>().searchDatasets(value);
//               },
//             ),
//           ),
//           // Datasets List
//           Expanded(
//             child: BlocBuilder<DatasetsCubit, DatasetsState>(
//               builder: (context, state) {
//                 if (state is DatasetsLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state is DatasetsFailure) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.error_outline,
//                             size: 64, color: Colors.red),
//                         const SizedBox(height: 16),
//                         Text('خطأ: ${state.errMsg}'),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () =>
//                               context.read<DatasetsCubit>().loadDatasets(),
//                           child: const Text('إعادة المحاولة'),
//                         ),
//                       ],
//                     ),
//                   );
//                 } else if (state is DatasetsSearchEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.search_off,
//                             size: 64, color: Colors.grey),
//                         const SizedBox(height: 16),
//                         Text('لا توجد نتائج للبحث: "${state.query}"'),
//                       ],
//                     ),
//                   );
//                 } else if (state is DatasetsSuccess) {
//                   final datasetsWithProjects = state.datasetsWithProjects;

//                   if (datasetsWithProjects.isEmpty) {
//                     return const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.dataset, size: 64, color: Colors.grey),
//                           SizedBox(height: 16),
//                           Text('لا توجد بيانات متاحة'),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: datasetsWithProjects.length,
//                     itemBuilder: (context, index) {
//                       final datasetName =
//                           datasetsWithProjects.keys.elementAt(index);
//                       final projects = datasetsWithProjects[datasetName]!;

//                       return DatasetCard(
//                         datasetName: datasetName,
//                         projects: projects,
//                       );
//                     },
//                   );
//                 }

//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DatasetCard extends StatefulWidget {
//   final String datasetName;
//   final List<ProjectModel> projects;

//   const DatasetCard({
//     Key? key,
//     required this.datasetName,
//     required this.projects,
//   }) : super(key: key);

//   @override
//   State<DatasetCard> createState() => _DatasetCardState();
// }

// class _DatasetCardState extends State<DatasetCard> {
//   bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.green,
//               child: const Icon(Icons.dataset, color: Colors.white),
//             ),
//             title: Text(
//               widget.datasetName,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text('${widget.projects.length} مشروع'),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon:
//                       Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
//                   onPressed: () {
//                     setState(() {
//                       _isExpanded = !_isExpanded;
//                     });
//                   },
//                 ),
//                 PopupMenuButton<ProjectModel>(
//                   icon: const Icon(Icons.arrow_drop_down),
//                   tooltip: 'اختر مشروع',
//                   onSelected: (project) {
//                     _showProjectDetails(context, project);
//                   },
//                   itemBuilder: (context) {
//                     return widget.projects.map((project) {
//                       return PopupMenuItem<ProjectModel>(
//                         value: project,
//                         child: ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           title: Text(project.name ?? 'مشروع بدون اسم'),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (project.description != null)
//                                 Text(
//                                   project.description!,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               if (project.model != null)
//                                 Text(
//                                   'النموذج: ${project.model}',
//                                   style: TextStyle(
//                                     color: Colors.blue[600],
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList();
//                   },
//                 ),
//               ],
//             ),
//           ),
//           if (_isExpanded)
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'المشاريع المرتبطة:',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   ...widget.projects.map((project) {
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   project.name ?? 'مشروع بدون اسم',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                                 if (project.description != null)
//                                   Text(
//                                     project.description!,
//                                     style: TextStyle(
//                                       color: Colors.grey[600],
//                                       fontSize: 12,
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 if (project.model != null)
//                                   Text(
//                                     'النموذج: ${project.model}',
//                                     style: TextStyle(
//                                       color: Colors.blue[600],
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.info_outline),
//                             onPressed: () =>
//                                 _showProjectDetails(context, project),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _showProjectDetails(BuildContext context, ProjectModel project) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(project.name ?? 'تفاصيل المشروع'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (project.description != null) ...[
//                 const Text('الوصف:',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(project.description!),
//                 const SizedBox(height: 12),
//               ],
//               if (project.model != null) ...[
//                 const Text('النموذج:',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(project.model!),
//                 const SizedBox(height: 12),
//               ],
//               if (project.dataset != null) ...[
//                 const Text('البيانات:',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(project.dataset!),
//                 const SizedBox(height: 12),
//               ],
//               if (project.createdAt != null) ...[
//                 const Text('تاريخ الإنشاء:',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(project.createdAt!.toString().split('.')[0]),
//               ],
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('إغلاق'),
//           ),
//         ],
//       ),
//     );
//   }
// }


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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Datasets',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Discover and use high-quality datasets for training and fine-tuning machine learning models.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    Icon(Icons.clear, color: Colors.grey[500]),
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
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
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
                        childAspectRatio: 0.8,
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
    );
  }
}

class DatasetCard extends StatelessWidget {
  final String datasetName;
  final List<ProjectModel> projects;

  const DatasetCard({
    Key? key,
    required this.datasetName,
    required this.projects,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Dataset Type/Category
                Text(
                  'Dataset Collection',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),

                // Project count and variation info
                Text(
                  '${projects.length} Projects • ${_getUniqueModelsCount(projects)} Models',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),

                // Description (using first project's info or general description)
                Text(
                  projects.isNotEmpty && projects.first.description != null
                      ? projects.first.description!
                      : 'A comprehensive dataset for training and evaluation',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
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
                      Icon(Icons.analytics_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${projects.length * 15}', // Mock usage count
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
                          _showProjectsDialog(context, datasetName, projects),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          size: 16,
                          color: Colors.grey[600],
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

  // Helper method to count unique models in projects
  int _getUniqueModelsCount(List<ProjectModel> projects) {
    final Set<String> uniqueModels = {};
    for (final project in projects) {
      if (project.model != null && project.model!.isNotEmpty) {
        uniqueModels.add(project.model!);
      }
    }
    return uniqueModels.length;
  }

  void _showProjectsDialog(
      BuildContext context, String datasetName, List<ProjectModel> projects) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
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
                '${projects.length} Projects • ${_getUniqueModelsCount(projects)} Models',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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
                    return _buildProjectItem(context, project);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, ProjectModel project) {
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
            const SizedBox(height: 8),
            Row(
              children: [
                if (project.model != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.model_training,
                            size: 12, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Text(
                          project.model!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (project.createdAt != null)
                  Text(
                    'Created: ${project.createdAt!.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
