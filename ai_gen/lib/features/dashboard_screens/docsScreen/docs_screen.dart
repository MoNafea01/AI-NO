import 'package:ai_gen/features/dashboard_screens/docsScreen/cubit/docsScreen_cubit.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/cubit/docsScreen_state.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/widgets/build_empty_state.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/widgets/build_filter_dropdown.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/widgets/build_successful_state.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/widgets/copy_to_clip_board.dart';
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
                 fontSize: 48,
                fontWeight: FontWeight.w700,
                fontFamily: AppConstants.appFontName,
                color: Colors.black,
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
            // ignore: deprecated_member_use
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
}
