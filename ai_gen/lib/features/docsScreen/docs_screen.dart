import 'package:ai_gen/features/docsScreen/cubit/docsScreen_cubit.dart';
import 'package:ai_gen/features/docsScreen/cubit/docsScreen_state.dart';
import 'package:ai_gen/features/docsScreen/widgets/build_empty_state.dart';
import 'package:ai_gen/features/docsScreen/widgets/build_filter_dropdown.dart';
import 'package:ai_gen/features/docsScreen/widgets/build_successful_state.dart';
import 'package:ai_gen/features/docsScreen/widgets/copy_to_clip_board.dart';
import 'package:flutter/material.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class DocsScreen extends StatelessWidget {
  const DocsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvancedSearchCubit()..loadProjects(),
      child: const AdvancedSearchView(),
    );
  }
}

class AdvancedSearchView extends StatefulWidget {
  const AdvancedSearchView({super.key});

  @override
  State<AdvancedSearchView> createState() => _AdvancedSearchViewState();
}

class _AdvancedSearchViewState extends State<AdvancedSearchView> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedModel;
  String? _selectedDataset;

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
            // Title
            Text(
              TranslationKeys.advancedSearch.tr,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                fontFamily: AppConstants.appFontName,
                color: Colors.black,
              ),
            ),
            // Description
            Text(
              TranslationKeys.advancedSearchDescription.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14,
                color: Color(0xff666666),
              ),
            ),
            const SizedBox(height: 20),

            // Search and Filter Section
            _buildSearchAndFilterSection(),
            const SizedBox(height: 24),

            // Results Section
            Expanded(
              child: BlocBuilder<AdvancedSearchCubit, AdvancedSearchState>(
                builder: (context, state) {
                  if (state is AdvancedSearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AdvancedSearchFailure) {
                    return _buildErrorState(state.errMsg);
                  } else if (state is AdvancedSearchEmpty) {
                    return buildEmptyState(state);
                  } else if (state is AdvancedSearchSuccess) {
                    return buildSuccessState(state);
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

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xffF2F2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xff999999), width: 1.4),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: TranslationKeys.searchProjectsModelsDatasetsHint.tr,
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: AppConstants.appFontName,
                  fontSize: 14,
                  color: Color(0xff666666),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xff666666)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xff666666)),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
                _performSearch();
              },
            ),
          ),
          const SizedBox(height: 16),

          // Filter Row
          BlocBuilder<AdvancedSearchCubit, AdvancedSearchState>(
            builder: (context, state) {
              if (state is AdvancedSearchSuccess) {
                return Row(
                  children: [
                    // Model Dropdown
                    Expanded(
                      child: buildFilterDropdown(
                        title: TranslationKeys.selectModel.tr,
                        value: _selectedModel,
                        items: ['all', ...state.availableModels],
                        onChanged: (value) {
                          setState(() {
                            _selectedModel = value == 'all' ? null : value;
                          });
                          _performSearch();
                        },
                        onCopy: (value) => copyToClipboard(
                            value, TranslationKeys.modelCopied.tr, context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Dataset Dropdown
                    Expanded(
                      child: buildFilterDropdown(
                        title: TranslationKeys.selectDataset.tr,
                        value: _selectedDataset,
                        items: ['all', ...state.availableDatasets],
                        onChanged: (value) {
                          setState(() {
                            _selectedDataset = value == 'all' ? null : value;
                          });
                          _performSearch();
                        },
                        onCopy: (value) => copyToClipboard(
                            value, TranslationKeys.datasetCopied.tr, context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Clear Filters Button
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _selectedModel = null;
                          _selectedDataset = null;
                        });
                        context.read<AdvancedSearchCubit>().clearFilters();
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: Text(
                        TranslationKeys.clearFilters.tr,
                        style: const TextStyle(
                          fontFamily: AppConstants.appFontName,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                        elevation: 0,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildProjectCard(ProjectModel project) {
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: InkWell(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => NodeView(projectModel: project),
  //           ),
  //         );
  //       },
  //       borderRadius: BorderRadius.circular(12),
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Project Name
  //             Text(
  //               project.name ?? TranslationKeys.unnamedProject.tr,
  //               style: const TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w600,
  //                 fontFamily: AppConstants.appFontName,
  //               ),
  //             ),

  //             // Description
  //             if (project.description != null &&
  //                 project.description!.isNotEmpty) ...[
  //               const SizedBox(height: 8),
  //               Text(
  //                 project.description!,
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   color: Colors.grey[600],
  //                   fontFamily: AppConstants.appFontName,
  //                 ),
  //                 maxLines: 2,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ],

  //             const SizedBox(height: 12),

  //             // Model and Dataset Tags
  //             Row(
  //               children: [
  //                 if (project.model != null && project.model!.isNotEmpty) ...[
  //                   _buildTag(
  //                     icon: Icons.model_training,
  //                     label: project.model!,
  //                     color: Colors.blue,
  //                     onCopy: () => _copyToClipboard(
  //                         project.model!, TranslationKeys.modelCopied.tr),
  //                   ),
  //                   const SizedBox(width: 8),
  //                 ],
  //                 if (project.dataset != null &&
  //                     project.dataset!.isNotEmpty) ...[
  //                   _buildTag(
  //                     icon: Icons.dataset_outlined,
  //                     label: project.dataset!,
  //                     color: Colors.green,
  //                     onCopy: () => _copyToClipboard(
  //                         project.dataset!, TranslationKeys.datasetCopied.tr),
  //                   ),
  //                 ],
  //               ],
  //             ),

  //             // Created Date
  //             if (project.createdAt != null) ...[
  //               const SizedBox(height: 8),
  //               Text(
  //                 '${TranslationKeys.created.tr}: ${project.createdAt!.toString().split(' ')[0]}',
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Colors.grey[500],
  //                   fontFamily: AppConstants.appFontName,
  //                 ),
  //               ),
  //             ],
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTag({
  //   required IconData icon,
  //   required String label,
  //   required Color color,
  //   required VoidCallback onCopy,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: color.withOpacity(0.3)),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(icon, size: 14, color: color),
  //         const SizedBox(width: 4),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: color,
  //             fontWeight: FontWeight.w500,
  //             fontFamily: AppConstants.appFontName,
  //           ),
  //         ),
  //         const SizedBox(width: 4),
  //         InkWell(
  //           onTap: onCopy,
  //           child: Icon(Icons.copy, size: 12, color: color),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildEmptyProjectsList() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
  //         const SizedBox(height: 16),
  //         Text(
  //           TranslationKeys.noProjectsFound.tr,
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Colors.grey[600],
  //             fontFamily: AppConstants.appFontName,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildEmptyState(AdvancedSearchEmpty state) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
  //         const SizedBox(height: 16),
  //         Text(
  //           TranslationKeys.NoResultsFound.tr,
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Colors.grey[600],
  //             fontFamily: AppConstants.appFontName,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('${TranslationKeys.error.tr}: $errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AdvancedSearchCubit>().loadProjects(),
            child: Text(TranslationKeys.retry.tr),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    context.read<AdvancedSearchCubit>().searchProjects(
          query: _searchController.text,
          modelName: _selectedModel,
          datasetName: _selectedDataset,
        );
  }

  // void _copyToClipboard(String text, String message) {
  //   Clipboard.setData(ClipboardData(text: text));
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       duration: const Duration(seconds: 2),
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  // }
}
