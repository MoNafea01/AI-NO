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

class VSNodeSerializationManager {
  ///Builds maps based on supplied nodeBuilders
  ///
  ///Makes sure supplied nodeBuilders follow guidlines
  ///
  ///Handles serialization and deserialization
  VSNodeSerializationManager({
    required List<dynamic> nodeBuilders,
    this.onBuilderMissing,

    ///These nodes will not be part of [contextNodeBuilders]
    ///
    ///They will only be used for deserialization
    List<VSNodeDataBuilder>? additionalNodes,
  }) {
    if (additionalNodes != null) {
      for (final node in additionalNodes) {
        _addNodeBuilder(node);
      }
    }

    _findNodes(nodeBuilders, contextNodeBuilders);
  }

  ///This function gets called when a node failed to deserialize due to a missing builder
  ///
  ///The nodeJSON in question is given as a parameter
  final Function(Map nodeJSON)? onBuilderMissing;

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
            "There are 2 or more subgroups with the name ${builder.name}. There can only be one on the same level",
          );
        }
      } else {
        VSNodeData instance = _addNodeBuilder(builder);

        builderMap[instance.type] = builder;
      }
    }
  }

  VSNodeData _addNodeBuilder(VSNodeDataBuilder builder) {
    final instance = builder(Offset.zero, null);
    if (!_nodeBuilders.containsKey(instance.type)) {
      final inputNames = instance.inputData.map((e) => e.type);
      if (inputNames.length != inputNames.toSet().length) {
        throw FormatException(
          "There are 2 or more Inputs in the node ${instance.type} with the same type. There can only be one",
        );
      }
      final outputNames = instance.outputData.map((e) => e.type);
      if (outputNames.length != outputNames.toSet().length) {
        throw FormatException(
          "There are 2 or more Outputs in the node ${instance.type} with the same type. There can only be one",
        );
      }
      _nodeBuilders[instance.type] = builder;
    } else {
      throw FormatException(
        "There are 2 or more nodes with the type ${instance.type}. There can only be one",
      );
    }
    return instance;
  }

  final Map<String, VSNodeDataBuilder> _nodeBuilders = {};
  final Map<String, dynamic> contextNodeBuilders = {};

  ///Calls jsonEncode on data
  String localSerializeNodes(Map<String, VSNodeData> data) {
    return jsonEncode(data);
  }

  ///Deserializes data in two steps:
  ///1. builds new nodes with position and id from saved data
  ///2. reconstruct connections between the nodes
  ///
  ///Returns a Map<NodeId,VSNodeData>
  Map<String, VSNodeData> localDeserializeNodes(String dataString) {
    final data = jsonDecode(dataString) as Map<String, dynamic>;

    final Map<String, VSNodeData> decoded = {};

    data.forEach((key, value) {
      print("key: $key");
      print("value: $value");
      final node = _nodeBuilders[value["type"]]?.call(Offset.zero, null);

      if (node == null) {
        //ignore: avoid_print
        print(
          "A node was serialized but the builder for its type is missing.\nIt will be remove from the current node tree.\n$value",
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

    data.forEach(
      (key, value) {
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
      },
    );

    return decoded;
  }

  List<Map<String, dynamic>> mySerializeNodes(Map<String, VSNodeData> data) {
    return data.values
        .where((e) => e.node != null)
        .map((e) => e.toJson())
        .toList();
  }

  ///Deserializes data in two steps:
  ///1. builds new nodes with position and id from saved data
  ///2. reconstruct connections between the nodes
  ///
  ///Returns a Map<NodeId,VSNodeData>
  Map<String, VSNodeData> myDeserializeNodes(Response response) {
    dynamic responseData = response.data;

    Map<String, dynamic> data = {};
    responseData.forEach((e) => data[e["node_id"].toString()] = e);

    final Map<String, VSNodeData> decoded = {};

    data.forEach(
      (key, value) {
        final VSNodeData? nodeData =
            _nodeBuilders[value["node_name"]]?.call(Offset.zero, null);

        if (nodeData == null ||
            (value["location_x"] == 0 && value["location_y"] == 0)) {
          //ignore: avoid_print
          print(
            "A node ${value["node_id"]} was serialized but the builder for its type is missing.",
          );
          onBuilderMissing?.call(value);
          return;
        }

        NodeModel? nodeModel = nodeData.node;
        if (nodeModel == null) return;

        nodeModel = _createNewNodeInstance(nodeModel, value);

        nodeData.setBaseData(
          nodeModel.nodeId.toString(),
          nodeModel.displayName ?? nodeModel.name,
          nodeModel.offset!,
          nodeModel: nodeModel,
        );

        decoded[key] = nodeData;
      },
    );

    print("decoded: $decoded");
    data.forEach(
      (key, value) {
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
      },
    );

    return decoded;
  }

  NodeModel _createNewNodeInstance(NodeModel nodeModel, value) {
    return nodeModel.copyWith(
      projectId: value["project"],
      nodeId: value["node_id"],
      offset: Offset(value["location_x"] ?? 350, value["location_y"] ?? 350),
      params: nodeModel.params.map(
        (param) {
          if (value["params"] is List && value["params"].isNotEmpty) {
            var matchingParam = value["params"].firstWhere(
              (p) => p[param.name] != null,
              orElse: () => null,
            );

            if (matchingParam != null) {
              return param.copyWith(value: matchingParam[param.name]);
            }
          }
          return param.copyWith();
        },
      ).toList(),
    );
  }
}
