// ignore_for_file: file_names

import 'dart:developer';

import 'package:ai_gen/core/models/project_model.dart';


import 'package:ai_gen/features/dashboard_screens/docsScreen/cubit/docsScreen_state.dart';

import 'package:ai_gen/core/data/network/services/interfaces/project_services_interface.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class AdvancedSearchCubit extends Cubit<AdvancedSearchState> {
  AdvancedSearchCubit() : super(AdvancedSearchInitial());

  final IProjectServices _appServices = GetIt.I.get<IProjectServices>();

  static AdvancedSearchCubit get(context) => BlocProvider.of(context);

  // Store all projects and extracted data
  List<ProjectModel> _allProjects = [];
  List<ProjectModel> _filteredProjects = [];
  List<String> _availableModels = [];
  List<String> _availableDatasets = [];

  String _currentSearchQuery = '';
  String? _selectedModel;
  String? _selectedDataset;

  // Load all projects and extract models/datasets
  loadProjects() async {
    try {
      emit(AdvancedSearchLoading());

      final List<ProjectModel> projects = await _appServices.getAllProjects();
      _allProjects = projects;
      _filteredProjects = projects;

      // Extract unique models and datasets
      _availableModels = _extractUniqueModels(projects);
      _availableDatasets = _extractUniqueDatasets(projects);

      emit(AdvancedSearchSuccess(
        projects: _filteredProjects,
        availableModels: _availableModels,
        availableDatasets: _availableDatasets,
      ));
    } catch (e) {
      log(e.toString());
      emit(AdvancedSearchFailure(errMsg: e.toString()));
    }
  }

  // Extract unique models from projects
  List<String> _extractUniqueModels(List<ProjectModel> projects) {
    final Set<String> uniqueModels = {};

    for (final project in projects) {
      final modelName = project.model?.trim();
      if (modelName != null && modelName.isNotEmpty) {
        uniqueModels.add(modelName);
      }
    }

    return uniqueModels.toList()..sort();
  }

  // Extract unique datasets from projects
  List<String> _extractUniqueDatasets(List<ProjectModel> projects) {
    final Set<String> uniqueDatasets = {};

    for (final project in projects) {
      final datasetName = project.dataset?.trim();
      if (datasetName != null && datasetName.isNotEmpty) {
        uniqueDatasets.add(datasetName);
      }
    }

    return uniqueDatasets.toList()..sort();
  }

  // Advanced search with multiple filters
  void searchProjects({
    String? query,
    String? modelName,
    String? datasetName,
  }) {
    _currentSearchQuery = query?.toLowerCase().trim() ?? '';
    _selectedModel = modelName;
    _selectedDataset = datasetName;

    _filteredProjects = _allProjects.where((project) {
      // Text search in project name, description, model, and dataset
      bool matchesText = true;
      if (_currentSearchQuery.isNotEmpty) {
        final searchTerms = _currentSearchQuery
            .split(' ')
            .where((term) => term.isNotEmpty)
            .toList();

        matchesText = searchTerms.every((term) =>
            (project.name ?? '').toLowerCase().contains(term) ||
            (project.description ?? '').toLowerCase().contains(term) ||
            (project.model ?? '').toLowerCase().contains(term) ||
            (project.dataset ?? '').toLowerCase().contains(term));
      }

      // Model filter
      bool matchesModel = _selectedModel == null ||
          _selectedModel == 'all' ||
          project.model == _selectedModel;

      // Dataset filter
      bool matchesDataset = _selectedDataset == null ||
          _selectedDataset == 'all' ||
          project.dataset == _selectedDataset;

      return matchesText && matchesModel && matchesDataset;
    }).toList();

    // Emit new state
    if (_filteredProjects.isEmpty &&
        (_currentSearchQuery.isNotEmpty ||
            _selectedModel != null ||
            _selectedDataset != null)) {
      emit(AdvancedSearchEmpty(
        query: _currentSearchQuery,
        selectedModel: _selectedModel,
        selectedDataset: _selectedDataset,
      ));
    } else {
      emit(AdvancedSearchSuccess(
        projects: _filteredProjects,
        availableModels: _availableModels,
        availableDatasets: _availableDatasets,
      ));
    }
  }

  // Clear all filters
  void clearFilters() {
    _currentSearchQuery = '';
    _selectedModel = null;
    _selectedDataset = null;
    _filteredProjects = _allProjects;

    emit(AdvancedSearchSuccess(
      projects: _filteredProjects,
      availableModels: _availableModels,
      availableDatasets: _availableDatasets,
    ));
  }

  // Getters
  List<ProjectModel> get filteredProjects => _filteredProjects;
  List<String> get availableModels => _availableModels;
  List<String> get availableDatasets => _availableDatasets;
  String get currentSearchQuery => _currentSearchQuery;
  String? get selectedModel => _selectedModel;
  String? get selectedDataset => _selectedDataset;
}
