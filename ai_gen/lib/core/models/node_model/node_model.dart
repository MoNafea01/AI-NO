import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:flutter/material.dart';

import 'parameter_model.dart';

class NodeModel {
  num? id;
  dynamic nodeId;
  String? projectId;
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
    this.projectId,
    this.nodeId,
  });

  NodeModel copyWith({
    num? id,
    dynamic nodeId,
    String? projectId,
    int? index,
    String? name,
    String? displayName,
    String? category,
    String? type,
    String? task,
    List<ParameterModel>? params,
    List<String>? inputDots,
    List<String>? outputDots,
    String? endPoint,
  }) {
    return NodeModel(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      projectId: projectId ?? this.projectId,
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
      endPoint: endPoint ?? this.endPoint,
    );
  }

  factory NodeModel.fromJson(json) {
    String name = json['node_name'] ?? "Node";

    List<ParameterModel> params = [];
    if (json['params'] != null) {
      params = (json['params'] as List)
          .map((e) => ParameterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<String>? inputDots = json['input_channels'] != null
        ? json['input_channels'].cast<String>()
        : [];
    List<String>? outputDots = json['output_channels'] != null
        ? json['output_channels'].cast<String>()
        : [];

    return NodeModel(
      id: num.parse(json['id'].toString()),
      index: json['idx'] != null ? int.parse(json['idx'].toString()) : 6,
      name: name,
      displayName: json['displayed_name'] ?? name,
      description: json['description'],
      category: json['category'] ?? "cat ${json['id']}",
      type: json['node_type'] ?? "type ${json['id']}",
      task: json['task'] ?? "task ${json['id']}",
      endPoint: json['api_call'],
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
    json['params'] = params?.map((param) => param.toJson()).toList();
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
