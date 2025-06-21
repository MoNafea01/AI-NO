import 'dart:convert';

import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../common.dart';
import '../data/vs_subgroup.dart';
import '../special_nodes/vs_widget_node.dart';
import 'offset_extension.dart';
import 'vs_interface.dart';
import 'vs_node_data.dart';

/// Manages the serialization and deserialization of nodes in the visual scripting interface.
///
/// This class handles converting nodes to and from various formats (JSON, API responses)
/// and maintains a registry of node builders for different node types.
class VSNodeSerializationManager {
  /// Creates a new [VSNodeSerializationManager] instance.
  ///
  /// [nodeBuilders] is a list of node builders that define available node types.
  /// [onBuilderMissing] is called when a node fails to deserialize due to missing builder.
  /// [additionalNodes] are nodes used only for deserialization, not part of context builders.
  VSNodeSerializationManager({
    required List<dynamic> nodeBuilders,
    this.onBuilderMissing,
    List<VSNodeDataBuilder>? additionalNodes,
  }) {
    if (additionalNodes != null) {
      for (final node in additionalNodes) {
        _addNodeBuilder(node);
      }
    }

    _findNodes(nodeBuilders, contextNodeBuilders);
  }

  /// Callback triggered when a node fails to deserialize due to missing builder
  final Function(Map nodeJSON)? onBuilderMissing;

  /// Internal registry of node builders by type
  final Map<String, VSNodeDataBuilder> _nodeBuilders = {};

  /// Map of node builders available in the context menu
  final Map<String, dynamic> contextNodeBuilders = {};

  /// Recursively processes node builders and organizes them into the builder map
  void _findNodes(
    List<dynamic> builders,
    Map<String, dynamic> builderMap,
  ) {
    for (final builder in builders) {
      if (builder is VSSubgroup) {
        final Map<String, dynamic> subMap = {};
        _findNodes(builder.subgroup, subMap);
        if (!builderMap.containsKey(builder.name)) {
          builderMap[builder.name] = subMap;
        } else {
          throw FormatException(
            "Duplicate subgroup name '${builder.name}' found. Subgroup names must be unique at the same level.",
          );
        }
      } else {
        final instance = _addNodeBuilder(builder);
        builderMap[instance.type] = builder;
      }
    }
  }

  /// Adds a node builder to the registry after validating its structure
  VSNodeData _addNodeBuilder(VSNodeDataBuilder builder) {
    final instance = builder(Offset.zero, null);

    if (!_nodeBuilders.containsKey(instance.type)) {
      // Validate input port types
      final inputNames = instance.inputData.map((e) => e.type);
      if (inputNames.length != inputNames.toSet().length) {
        throw FormatException(
          "Node '${instance.type}' has duplicate input port types. Each input port must have a unique type.",
        );
      }

      // Validate output port types
      final outputNames = instance.outputData.map((e) => e.type);
      if (outputNames.length != outputNames.toSet().length) {
        throw FormatException(
          "Node '${instance.type}' has duplicate output port types. Each output port must have a unique type.",
        );
      }

      _nodeBuilders[instance.type] = builder;
    } else {
      throw FormatException(
        "Duplicate node type '${instance.type}' found. Node types must be unique.",
      );
    }
    return instance;
  }

  /// Serializes node data to a JSON string
  String localSerializeNodes(Map<String, VSNodeData> data) {
    return jsonEncode(data);
  }

  /// Deserializes node data from a JSON string
  ///
  /// The process happens in two steps:
  /// 1. Builds new nodes with position and ID from saved data
  /// 2. Reconstructs connections between the nodes
  Map<String, VSNodeData> localDeserializeNodes(String dataString) {
    final data = jsonDecode(dataString) as Map<String, dynamic>;
    final Map<String, VSNodeData> decoded = {};

    // First pass: Create nodes
    data.forEach((key, value) {
      final node = _nodeBuilders[value["type"]]?.call(Offset.zero, null);

      if (node == null) {
        print(
          "Node deserialization failed: Builder missing for type '${value["type"]}'.\n"
          "Node will be removed from the tree.\n"
          "Node data: $value",
        );
        onBuilderMissing?.call(value);
        return;
      }

      node.setBaseData(
        value["id"],
        value["title"],
        offsetFromJson(value["widgetOffset"]),
      );

      if (value["value"] != null) {
        (node as VSWidgetNode).setValue(value["value"]);
      }

      decoded[key] = node;
    });

    // Second pass: Reconstruct connections
    data.forEach((key, value) {
      final inputData = value["input_ports"] as List<dynamic>;
      final Map<String, VSOutputData?> inputRefs = {};

      for (final element in inputData) {
        final serializedOutput = element["connectedNode"];

        if (serializedOutput != null) {
          final refOutput =
              decoded[serializedOutput["nodeData"]]?.outputData.firstWhere(
                    (element) => element.type == serializedOutput["name"],
                  );
          inputRefs[element["name"]] = refOutput;
        }
      }

      decoded[key]?.setRefData(inputRefs);
    });

    return decoded;
  }

  /// Serializes nodes to a list of maps for API communication
  List<Map<String, dynamic>> mySerializeNodes(Map<String, VSNodeData> data) {
    return data.values
        .where((e) => e.node != null)
        .map((e) => e.toJson())
        .toList();
  }

  /// Deserializes nodes from an API response
  ///
  /// The process happens in two steps:
  /// 1. Builds new nodes with position and ID from saved data
  /// 2. Reconstructs connections between the nodes
  Map<String, VSNodeData> myDeserializeNodes(Response response) {
    final responseData = response.data as List<dynamic>;
    final Map<String, dynamic> data = {
      for (var e in responseData) e["node_id"].toString(): e
    };

    final Map<String, VSNodeData> decoded = {};

    // First pass: Create nodes
    data.forEach((key, value) {
      final nodeData =
          _nodeBuilders[value["node_name"]]?.call(Offset.zero, null);

      if (nodeData == null) {
        print(
          "Node deserialization failed: Builder missing for node ${value["node_id"]}.",
        );
        onBuilderMissing?.call(value);
        return;
      }

      if (value["location_x"] == 0 && value["location_y"] == 0) {
        print(
          "Node deserialization warning: Node ${value["node_id"]} has invalid position (0,0).",
        );
        onBuilderMissing?.call(value);
        return;
      }

      final nodeModel = nodeData.node;
      if (nodeModel == null) return;

      updateNode(nodeModel, value);

      nodeData.setBaseData(
        nodeModel.nodeId.toString(),
        nodeModel.displayName ?? nodeModel.name,
        nodeModel.offset!,
        nodeModel: nodeModel,
      );

      decoded[key] = nodeData;
    });

    // Second pass: Reconstruct connections
    data.forEach((key, value) {
      final inputData = value["input_ports"] as List<dynamic>;
      final Map<String, VSOutputData?> inputRefs = {};

      for (final element in inputData) {
        final serializedOutput = element["connectedNode"];

        if (serializedOutput != null) {
          final refOutput = decoded[serializedOutput["nodeData"].toString()]
              ?.outputData
              .firstWhere(
                (element) => element.type == serializedOutput["name"],
              );
          inputRefs[element["name"]] = refOutput;
        }
      }

      decoded[key]?.setRefData(inputRefs);
    });

    return decoded;
  }

  /// Updates a node model with data from the API response
  void updateNode(NodeModel nodeModel, Map<String, dynamic> value) {
    nodeModel.projectId = value["project"];
    nodeModel.nodeId = value["node_id"];
    nodeModel.offset = Offset(
      value["location_x"] ?? 350,
      value["location_y"] ?? 350,
    );

    if (value["params"] is List && value["params"].isNotEmpty) {
      nodeModel.params = nodeModel.params.map((param) {
        final matchingParam = value["params"].firstWhere(
          (p) => p[param.name] != null,
          orElse: () => null,
        );
        if (matchingParam != null) {
          param.value = matchingParam[param.name];
        }
        return param;
      }).toList();
    }
  }
}
