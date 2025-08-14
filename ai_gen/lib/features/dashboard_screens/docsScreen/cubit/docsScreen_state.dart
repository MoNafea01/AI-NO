// ignore: file_names
import 'package:ai_gen/core/models/project_model.dart';



abstract class AdvancedSearchState {}

class AdvancedSearchInitial extends AdvancedSearchState {}

class AdvancedSearchLoading extends AdvancedSearchState {}

class AdvancedSearchSuccess extends AdvancedSearchState {
  final List<ProjectModel> projects;
  final List<String> availableModels;
  final List<String> availableDatasets;

  AdvancedSearchSuccess({
    required this.projects,
    required this.availableModels,
    required this.availableDatasets,
  });
}

class AdvancedSearchEmpty extends AdvancedSearchState {
  final String query;
  final String? selectedModel;
  final String? selectedDataset;

  AdvancedSearchEmpty({
    required this.query,
    this.selectedModel,
    this.selectedDataset,
  });
}

class AdvancedSearchFailure extends AdvancedSearchState {
  final String errMsg;

  AdvancedSearchFailure({required this.errMsg});
}
