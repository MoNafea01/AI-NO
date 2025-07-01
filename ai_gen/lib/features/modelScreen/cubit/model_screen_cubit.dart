import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/network/services/interfaces/project_services_interface.dart';
import 'package:ai_gen/features/modelScreen/cubit/model_screen_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';



class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit() : super(ModelsInitial());

  final IProjectServices _appServices = GetIt.I.get<IProjectServices>();

  static ModelsCubit get(context) => BlocProvider.of(context);

  // Store all projects and extracted models data
  List<ProjectModel> _allProjects = [];
  Map<String, List<ProjectModel>> _modelsWithProjects = {};
  Map<String, List<ProjectModel>> _filteredModelsWithProjects = {};
  String _currentSearchQuery = '';

  // Load all models with their associated projects
  loadModels() async {
    try {
      emit(ModelsLoading());

      final List<ProjectModel> projects = await _appServices.getAllProjects();
      _allProjects = projects;

      // Extract unique models and group projects by model
      _modelsWithProjects = _extractModelsWithProjects(projects);
      _filteredModelsWithProjects = Map.from(_modelsWithProjects);

      emit(ModelsSuccess(modelsWithProjects: _filteredModelsWithProjects));
    } catch (e) {
      print(e);
      emit(ModelsFailure(errMsg: e.toString()));
    }
  }

  // Extract models and group projects by model
  Map<String, List<ProjectModel>> _extractModelsWithProjects(
      List<ProjectModel> projects) {
    final Map<String, List<ProjectModel>> modelsMap = {};

    for (final project in projects) {
      final modelName = project.model?.trim();
      if (modelName != null && modelName.isNotEmpty) {
        if (!modelsMap.containsKey(modelName)) {
          modelsMap[modelName] = [];
        }
        modelsMap[modelName]!.add(project);
      }
    }

    return modelsMap;
  }

  // Search functionality for models
  void searchModels(String query) {
    _currentSearchQuery = query.toLowerCase().trim();

    if (_currentSearchQuery.isEmpty) {
      // Show all models when search is empty
      _filteredModelsWithProjects = Map.from(_modelsWithProjects);
    } else {
      // Filter models based on search query
      _filteredModelsWithProjects = {};

      _modelsWithProjects.forEach((modelName, projects) {
        final modelNameLower = modelName.toLowerCase();

        // Search in model name or project names
        bool matchesModel = modelNameLower.contains(_currentSearchQuery);
        bool matchesProject = projects.any((project) =>
            (project.name ?? '').toLowerCase().contains(_currentSearchQuery) ||
            (project.description ?? '')
                .toLowerCase()
                .contains(_currentSearchQuery));

        if (matchesModel || matchesProject) {
          _filteredModelsWithProjects[modelName] = projects;
        }
      });
    }

    // Emit new state
    if (_filteredModelsWithProjects.isEmpty && _currentSearchQuery.isNotEmpty) {
      emit(ModelsSearchEmpty(query: _currentSearchQuery));
    } else {
      emit(ModelsSuccess(modelsWithProjects: _filteredModelsWithProjects));
    }
  }

  // Get projects for a specific model
  List<ProjectModel> getProjectsForModel(String modelName) {
    return _modelsWithProjects[modelName] ?? [];
  }

  // Getters
  Map<String, List<ProjectModel>> get modelsWithProjects => _modelsWithProjects;
  Map<String, List<ProjectModel>> get filteredModelsWithProjects =>
      _filteredModelsWithProjects;
  String get currentSearchQuery => _currentSearchQuery;
  List<String> get availableModels => _modelsWithProjects.keys.toList();
}
