import 'dart:developer';

import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/network/services/interfaces/project_services_interface.dart';
import 'package:ai_gen/features/dashboard_screens/datasetScreen/cubit/dataset_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';




class DatasetsCubit extends Cubit<DatasetsState> {
  DatasetsCubit() : super(DatasetsInitial());

  final IProjectServices _appServices = GetIt.I.get<IProjectServices>();

  static DatasetsCubit get(context) => BlocProvider.of(context);

  // Store all projects and extracted datasets data
  List<ProjectModel> _allProjects = [];
  Map<String, List<ProjectModel>> _datasetsWithProjects = {};
  Map<String, List<ProjectModel>> _filteredDatasetsWithProjects = {};
  String _currentSearchQuery = '';

  // Load all datasets with their associated projects
  loadDatasets() async {
    try {
      emit(DatasetsLoading());

      final List<ProjectModel> projects = await _appServices.getAllProjects();
      _allProjects = projects;

      // Extract unique datasets and group projects by dataset
      _datasetsWithProjects = _extractDatasetsWithProjects(projects);
      _filteredDatasetsWithProjects = Map.from(_datasetsWithProjects);

      emit(
          DatasetsSuccess(datasetsWithProjects: _filteredDatasetsWithProjects));
    } catch (e) {
      log(e.toString());
      emit(DatasetsFailure(errMsg: e.toString()));
    }
  }

  // Extract datasets and group projects by dataset
  Map<String, List<ProjectModel>> _extractDatasetsWithProjects(
      List<ProjectModel> projects) {
    final Map<String, List<ProjectModel>> datasetsMap = {};

    for (final project in projects) {
      final datasetName = project.dataset?.trim();
      if (datasetName != null && datasetName.isNotEmpty) {
        if (!datasetsMap.containsKey(datasetName)) {
          datasetsMap[datasetName] = [];
        }
        datasetsMap[datasetName]!.add(project);
      }
    }

    return datasetsMap;
  }

  // Search functionality for datasets
  void searchDatasets(String query) {
    _currentSearchQuery = query.toLowerCase().trim();

    if (_currentSearchQuery.isEmpty) {
      // Show all datasets when search is empty
      _filteredDatasetsWithProjects = Map.from(_datasetsWithProjects);
    } else {
      // Filter datasets based on search query
      _filteredDatasetsWithProjects = {};

      _datasetsWithProjects.forEach((datasetName, projects) {
        final datasetNameLower = datasetName.toLowerCase();

        // Search in dataset name or project names
        bool matchesDataset = datasetNameLower.contains(_currentSearchQuery);
        bool matchesProject = projects.any((project) =>
            (project.name ?? '').toLowerCase().contains(_currentSearchQuery) ||
            (project.description ?? '')
                .toLowerCase()
                .contains(_currentSearchQuery));

        if (matchesDataset || matchesProject) {
          _filteredDatasetsWithProjects[datasetName] = projects;
        }
      });
    }

    // Emit new state
    if (_filteredDatasetsWithProjects.isEmpty &&
        _currentSearchQuery.isNotEmpty) {
      emit(DatasetsSearchEmpty(query: _currentSearchQuery));
    } else {
      emit(
          DatasetsSuccess(datasetsWithProjects: _filteredDatasetsWithProjects));
    }
  }

  // Get projects for a specific dataset
  List<ProjectModel> getProjectsForDataset(String datasetName) {
    return _datasetsWithProjects[datasetName] ?? [];
  }

  // Search projects by both model and dataset
  List<ProjectModel> searchProjectsByModelAndDataset(
      String? modelName, String? datasetName) {
    if (modelName == null && datasetName == null) {
      return _allProjects;
    }

    return _allProjects.where((project) {
      bool matchesModel = modelName == null || project.model == modelName;
      bool matchesDataset =
          datasetName == null || project.dataset == datasetName;
      return matchesModel && matchesDataset;
    }).toList();
  }

  // Getters
  Map<String, List<ProjectModel>> get datasetsWithProjects =>
      _datasetsWithProjects;
  Map<String, List<ProjectModel>> get filteredDatasetsWithProjects =>
      _filteredDatasetsWithProjects;
  String get currentSearchQuery => _currentSearchQuery;
  List<String> get availableDatasets => _datasetsWithProjects.keys.toList();
}
