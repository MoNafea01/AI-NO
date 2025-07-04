
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';

import 'package:ai_gen/features/dashboard_screens/datasetScreen/cubit/dataset_screen.dart';
import 'package:ai_gen/features/dashboard_screens/datasetScreen/cubit/dataset_screen_cubit.dart';

import 'package:ai_gen/features/dashboard_screens/datasetScreen/widgets/dataset_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get/get.dart';

class DatasetsScreen extends StatelessWidget {
  const DatasetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DatasetsCubit()..loadDatasets(),
      child: const DatasetsView(),
    );
  }
}

class DatasetsView extends StatefulWidget {
  const DatasetsView({super.key});

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
            
            Text(
              TranslationKeys.datasets.tr,
              style: const TextStyle(
                 fontSize: 48,
                fontWeight: FontWeight.w700,
                fontFamily: AppConstants.appFontName,
                color: Colors.black,
              ),
            ),
            // Header Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                TranslationKeys.datasetsDescription.tr,
                style: const TextStyle(
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
                          hintText: TranslationKeys.search.tr,
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
                        Text(
                          TranslationKeys.filter.tr,
                          style: const TextStyle(
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
                  Text(
                    TranslationKeys.yourDatasets.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConstants.appFontName,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      TranslationKeys.seeAll.tr,
                      style: const TextStyle(
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )),
                            child: Text(TranslationKeys.retry.tr),
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
                          Text(
                              '{"${TranslationKeys.noResultsFoundFor.tr}"${state.query}"'),
                        ],
                      ),
                    );
                  } else if (state is DatasetsSuccess) {
                    final datasetsWithProjects = state.datasetsWithProjects;

                    if (datasetsWithProjects.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.dataset,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(TranslationKeys.noDatasetsAvailable.tr),
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
                          childAspectRatio: 4 / 1.8,
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
