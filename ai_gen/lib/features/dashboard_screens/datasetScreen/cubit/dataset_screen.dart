


import 'package:ai_gen/core/models/project_model.dart';

abstract class DatasetsState {}

class DatasetsInitial extends DatasetsState {}

class DatasetsLoading extends DatasetsState {}

class DatasetsSuccess extends DatasetsState {
  final Map<String, List<ProjectModel>> datasetsWithProjects;

  DatasetsSuccess({required this.datasetsWithProjects});
}

class DatasetsSearchEmpty extends DatasetsState {
  final String query;

  DatasetsSearchEmpty({required this.query});
}

class DatasetsFailure extends DatasetsState {
  final String errMsg;

  DatasetsFailure({required this.errMsg});
}
