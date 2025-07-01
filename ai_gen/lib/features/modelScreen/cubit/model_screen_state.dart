




import 'package:flutter/material.dart';

import '../../../core/models/project_model.dart';

@immutable

abstract class ModelsState {}

class ModelsInitial extends ModelsState {}

class ModelsLoading extends ModelsState {}

class ModelsSuccess extends ModelsState {
  final Map<String, List<ProjectModel>> modelsWithProjects;

  ModelsSuccess({required this.modelsWithProjects});
}

class ModelsSearchEmpty extends ModelsState {
  final String query;

  ModelsSearchEmpty({required this.query});
}

class ModelsFailure extends ModelsState {
  final String errMsg;

  ModelsFailure({required this.errMsg});
}
