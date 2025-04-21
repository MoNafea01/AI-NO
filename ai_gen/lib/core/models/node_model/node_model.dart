import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:flutter/material.dart';

import 'parameter_model.dart';

class NodeModel {
  num? id;
  dynamic nodeId;
  int? index;
  String name;
  String? displayName;
  String? description;
  String category;
  String type;
  String task;
  List<ParameterModel>? params;
  List<String>? inputDots;
  List<String>? outputDots;
  String? endPoint;

  NodeModel({
    this.id,
    this.index,
    this.name = "Node",
    this.displayName,
    this.description,
    this.category = "others",
    this.type = "others",
    this.task = "others",
    this.params,
    this.inputDots,
    this.outputDots,
    this.endPoint,
  });

  NodeModel copyWith({
    num? id,
    dynamic nodeId,
    int? index,
    String? name,
    String? displayName,
    String? category,
    String? type,
    String? task,
    List<ParameterModel>? params,
    List<String>? inputDots,
    List<String>? outputDots,
    String? apiCall,
  }) {
    return NodeModel(
      id: id ?? this.id,
      index: index ?? this.index,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description,
      category: category ?? this.category,
      type: type ?? this.type,
      task: task ?? this.task,
      params: params ??
          this.params?.map((parameter) => parameter.copyWith()).toList(),
      inputDots: inputDots ?? this.inputDots,
      outputDots: outputDots ?? this.outputDots,
      endPoint: apiCall ?? this.endPoint,
    );
  }

  factory NodeModel.fromJson(dynamic json) {
    String name = json['node_name'] ?? "Node";
    String category = json['category'] ?? "cat ${json['id']}";
    String type = json['node_type'] ?? "type ${json['id']}";
    String task = json['task'] ?? "task ${json['id']}";
    num id = num.parse(json['id'].toString());
    int index = json['idx'] != null ? int.parse(json['idx'].toString()) : 6;
    String displayName = json['displayed_name'] ?? name;
    String description = json['description'];

    List<ParameterModel> params = [];
    if (json['params'] != null) {
      params = (json['params'] as List)
          .map((e) => ParameterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<String>? inputDots = json['input_channels'] != null
        ? json['input_channels'].cast<String>()
        : [];
    List<String> outputDots = json['output_channels'] != null
        ? json['output_channels'].cast<String>()
        : [];
    String? apiCall = json['api_call'];

    return NodeModel(
      id: id,
      index: index,
      name: name,
      category: category,
      type: type,
      task: task,
      endPoint: apiCall,
      displayName: displayName,
      description: description,
      inputDots: inputDots,
      outputDots: outputDots,
      params: params,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['idx'] = index;
    json['node_name'] = name;
    json['displayed_name'] = displayName;
    json['description'] = description;
    json['category'] = category;
    json['node_type'] = type;
    json['task'] = task;
    json['params'] = params?.map((e) => e.toJson()).toList();
    json['input_channels'] = inputDots;
    json['output_channels'] = outputDots;
    json['api_call'] = endPoint;
    return json;
  }

  // to be used in the API call as the api data
  Map<String, dynamic> get paramsToJson {
    Map<String, dynamic> paramsMap = {};
    params?.forEach((param) => paramsMap.addAll(param.toJson()));

    return paramsMap;
  }

  Color get color {
    // if (name == "model_fitter") {
    //   return NodeTypes.models.color;
    // }
    // if (name == "preprocessor_fitter") {
    //   return NodeTypes.preprocessors.color;
    // }

    switch (category) {
      case "Models":
        return NodeTypes.models.color;
      case "Preprocessors":
        return NodeTypes.preprocessors.color;
      case "Core":
        return NodeTypes.core.color;
      case "Custom":
        return NodeTypes.custom.color;
      case "Input":
        return NodeTypes.input.color;
      case "Output":
        return NodeTypes.output.color;
      case "Network":
        return NodeTypes.network.color;
      default:
        return NodeTypes.general.color;
    }
  }
}
