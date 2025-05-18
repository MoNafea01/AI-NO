import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/interface_colors.dart';
import 'package:flutter/material.dart';

import 'parameter_model.dart';

class NodeModel {
  int id;
  dynamic nodeId;
  int? projectId;
  int? index;
  int? order;
  String name;
  String? displayName;
  String? description;
  String category;
  String type;
  String task;
  List<ParameterModel> params;
  List<String>? inputDots;
  List<String>? outputDots;
  String? endPoint;
  Offset? offset;

  NodeModel({
    required this.id,
    this.index,
    this.order,
    this.name = "Node",
    this.displayName,
    this.description,
    this.category = "others",
    this.type = "others",
    this.task = "others",
    this.params = const [],
    this.inputDots,
    this.outputDots,
    this.endPoint,
    this.projectId,
    this.nodeId,
    this.offset,
  });

  NodeModel copyWith({
    required int projectId,
    int? id,
    dynamic nodeId,
    int? order,
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
    String? description,
    Offset? offset,
  }) {
    return NodeModel(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      projectId: projectId,
      index: index ?? this.index,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      task: task ?? this.task,
      params: params ??
          this.params.map((parameter) => parameter.copyWith()).toList(),
      inputDots: inputDots ?? this.inputDots,
      outputDots: outputDots ?? this.outputDots,
      endPoint: endPoint ?? this.endPoint,
      offset: offset ?? this.offset,
      order: order ?? this.order,
    );
  }

  factory NodeModel.fromJson(json) {
    String name = json['node_name'] ?? "Node";

    List<ParameterModel> params = [];
    if (json['params'] != null && json['params'] is List) {
      params = (json['params'] as List)
          .map((e) => ParameterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['params'] is Map) {
      params
          .add(ParameterModel.fromJson(json['params'] as Map<String, dynamic>));
    }

    List<String>? inputDots = json['input_channels'] != null
        ? json['input_channels'].cast<String>()
        : [];
    List<String>? outputDots = json['output_channels'] != null
        ? json['output_channels'].cast<String>()
        : [];

    Offset? offset;
    if (json['location_x'] != null && json['location_y'] != null) {
      offset = Offset(
        json['location_x'].toDouble(),
        json['location_y'].toDouble(),
      );
    }

    return NodeModel(
      id: json['uid'],
      nodeId: json['node_id'],
      projectId: json['project'],
      index: json['idx'] != null ? int.parse(json['idx'].toString()) : 6,
      name: name,
      displayName: json['displayed_name'] ?? name,
      description: json['description'],
      category: json['category'] ?? "cat ${json['uid']}",
      type: json['node_type'] ?? "type ${json['uid']}",
      task: json['task'] ?? "task ${json['uid']}",
      endPoint: json['api_call'],
      inputDots: inputDots,
      outputDots: outputDots,
      params: params,
      offset: offset,
    );
  }

  // used in serialization
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['uid'] = id;
    json['idx'] = index;
    json['node_name'] = name;
    json['displayed_name'] = displayName;
    json['description'] = description;
    json['category'] = category;
    json['node_type'] = type;
    json['task'] = task;
    json['params'] = params.map((param) => param.toJson()).toList();
    json['input_channels'] = inputDots;
    json['output_channels'] = outputDots;
    json['api_call'] = endPoint;
    json['location_x'] = offset?.dx;
    json['location_y'] = offset?.dy;
    json['project'] = projectId;
    json['node_id'] = nodeId;
    json['order'] = order;
    return json;
  }

  // to be used in the API call as the api data
  Map<String, dynamic> get paramsToJson {
    Map<String, dynamic> paramsMap = {};
    params.forEach((param) => paramsMap.addAll(param.toJson()));

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
