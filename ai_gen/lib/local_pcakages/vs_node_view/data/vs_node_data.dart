import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:flutter/material.dart';

import '../common.dart';
import 'offset_extension.dart';
import 'vs_interface.dart';

/// Represents the data model for a node in the visual scripting interface.
///
/// This class holds all the necessary data for rendering and managing a node,
/// including its position, connections, and visual properties.
class VSNodeData {
  /// Creates a new [VSNodeData] instance.
  ///
  /// [type] is the type identifier for the node.
  /// [widgetOffset] is the position of the node in the viewport.
  /// [inputData] and [outputData] are the input and output interfaces.
  /// [node] is an optional model representing the node's data.
  /// [deleteNode] is an optional callback for node deletion.
  /// [id] is an optional unique identifier (generated if not provided).
  /// [nodeWidth] is the optional width of the node.
  /// [onUpdatedConnection] is called when input connections are updated.
  /// [nodeColor] is the color of the node (defaults to light blue).
  /// [toolTip] is an optional tooltip text.
  /// [title] is an optional display title.
  VSNodeData({
    required this.type,
    required this.widgetOffset,
    required List<VSInputData> inputData,
    required this.outputData,
    this.node,
    this.deleteNode,
    String? id,
    this.nodeWidth,
    this.onUpdatedConnection,
    this.nodeColor = Colors.lightBlue,
    this.toolTip,
    String? title,
    this.isRenaming = false,
  })  : _id = id ?? getRandomString(10),
        _title = title ?? "",
        _inputData = inputData {
    // Initialize node references for all interfaces
    for (final input in inputData) {
      input.nodeData = this;
    }
    for (final output in outputData) {
      output.nodeData = this;
    }
  }

  /// The underlying node model
  NodeModel? node;

  /// Unique identifier for the node
  String get id => _id;
  String _id;

  /// Callback for node deletion
  final VoidCallback? deleteNode;

  /// Whether the node is currently being renamed
  bool isRenaming;

  /// The type identifier of the node
  final String type;

  /// The current position of the node in the viewport
  Offset widgetOffset;

  /// The width of the node in the UI
  final double? nodeWidth;

  /// The list of input data for this node.
  List<VSInputData> get inputData => _inputData;
  set inputData(List<VSInputData> value) {
    _inputData = value;
  }

  List<VSInputData> _inputData;

  /// The output interfaces of the node
  final Iterable<VSOutputData> outputData;

  /// The color of the node
  final Color nodeColor;

  /// The display title of the node
  ///
  /// If empty, falls back to the node type
  String get title => _title.isNotEmpty ? _title : type;
  set title(String data) => _title = data;
  String _title;

  /// Optional tooltip text for the node
  final String? toolTip;

  /// Callback triggered when input connections are updated
  final Function(VSInputData interfaceData)? onUpdatedConnection;

  /// Converts the node data to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      ...node?.toJson() ?? {},
      'type': type,
      'title': _title,
      'widgetOffset': widgetOffset.toJson(),
      'input_ports': inputData,
      'output_ports': outputData,
    };
  }

  /// Sets the base data for the node during deserialization
  ///
  /// [id] is the unique identifier
  /// [title] is the display title
  /// [widgetOffset] is the position in the viewport
  /// [nodeModel] is an optional node model
  void setBaseData(
    String id,
    String title,
    Offset widgetOffset, {
    NodeModel? nodeModel,
  }) {
    _id = id;
    _title = title;
    this.widgetOffset = widgetOffset;
    if (nodeModel != null) {
      node = nodeModel;
    }
  }

  /// Reconstructs node connections during deserialization
  ///
  /// [inputRefs] maps input types to their corresponding output connections
  void setRefData(Map<String, VSOutputData?> inputRefs) {
    final inputMap = {for (final element in inputData) element.type: element};

    for (final ref in inputRefs.entries) {
      inputMap[ref.key]?.connectedInterface = ref.value;
    }
  }

  /// Creates a copy of this node data with optional modifications
  VSNodeData copyWith({
    String? type,
    Offset? widgetOffset,
    List<VSInputData>? inputData,
    Iterable<VSOutputData>? outputData,
    NodeModel? node,
    VoidCallback? deleteNode,
    String? id,
    double? nodeWidth,
    Function(VSInputData)? onUpdatedConnection,
    Color? nodeColor,
    String? toolTip,
    String? title,
    bool? isRenaming,
  }) {
    return VSNodeData(
      type: type ?? this.type,
      widgetOffset: widgetOffset ?? this.widgetOffset,
      inputData: inputData ?? this.inputData,
      outputData: outputData ?? this.outputData,
      node: node ?? this.node,
      deleteNode: deleteNode ?? this.deleteNode,
      id: id ?? this.id,
      nodeWidth: nodeWidth ?? this.nodeWidth,
      onUpdatedConnection: onUpdatedConnection ?? this.onUpdatedConnection,
      nodeColor: nodeColor ?? this.nodeColor,
      toolTip: toolTip ?? this.toolTip,
      title: title ?? this.title,
      isRenaming: isRenaming ?? this.isRenaming,
    );
  }
}
