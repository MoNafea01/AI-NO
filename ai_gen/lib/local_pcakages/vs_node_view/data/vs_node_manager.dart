import 'package:dio/dio.dart';

import '../common.dart';
import '../special_nodes/vs_output_node.dart';
import 'vs_node_data.dart';
import 'vs_node_serialization_manager.dart';

/// Manages the state and operations of nodes in the visual scripting interface.
///
/// This class handles node creation, updates, serialization, and maintains
/// the relationships between nodes. It works in conjunction with
/// [VSNodeSerializationManager] for serialization operations.
class VSNodeManager {
  /// Creates a new [VSNodeManager] instance.
  ///
  /// [nodeBuilders] is a list of node builders that define available node types.
  /// [serializedNodes] is an optional string containing serialized node data.
  /// [onNodesUpdate] is called when nodes are updated.
  /// [onBuilderMissing] is called when a node fails to deserialize due to missing builder.
  /// [additionalNodes] are nodes used only for deserialization, not part of context builders.
  VSNodeManager({
    required List<dynamic> nodeBuilders,
    String? serializedNodes,
    this.onNodesUpdate,
    Function(Map nodeJSON)? onBuilderMissing,
    List<VSNodeDataBuilder>? additionalNodes,
  }) {
    serializationManager = VSNodeSerializationManager(
      nodeBuilders: nodeBuilders,
      onBuilderMissing: onBuilderMissing,
      additionalNodes: additionalNodes,
    );

    if (serializedNodes != null) {
      _nodes = serializationManager.localDeserializeNodes(serializedNodes);
    }
  }

  /// The serialization manager instance
  late final VSNodeSerializationManager serializationManager;

  /// Map of all available node builders
  Map<String, dynamic> get nodeBuildersMap =>
      serializationManager.contextNodeBuilders;

  /// Callback triggered when nodes are updated
  ///
  /// Provides both old and new node data for comparison
  late final void Function(
    Map<String, VSNodeData> oldData,
    Map<String, VSNodeData> newData,
  )? onNodesUpdate;

  /// Internal storage for node data
  Map<String, VSNodeData> _nodes = {};

  /// Gets a copy of the current node data
  Map<String, VSNodeData> get nodes => Map.from(_nodes);

  set nodes(Map<String, VSNodeData> value) {
    onNodesUpdate?.call(_nodes, value);
    _nodes = value;
  }

  /// Gets all output nodes in the current node data
  Iterable<VSOutputNode> get getOutputNodes =>
      _nodes.values.whereType<VSOutputNode>();

  /// Serializes the current node data to a string
  String localSerializeNodes() {
    return serializationManager.localSerializeNodes(_nodes);
  }

  /// Loads nodes from a serialized string and replaces current nodes
  void loadLocalSerializedNodes(String serializedNodes) {
    nodes = serializationManager.localDeserializeNodes(serializedNodes);
  }

  /// Serializes nodes to a list of maps for API communication
  List<Map<String, dynamic>> mySerializeNodes() {
    return serializationManager.mySerializeNodes(_nodes);
  }

  /// Deserializes nodes from an API response
  void myDeSerializedNodes(Response response) {
    nodes = serializationManager.myDeserializeNodes(response);
  }

  /// Updates existing nodes or creates new ones
  ///
  /// [nodeDatas] is a list of nodes to update or create
  Future<void> updateOrCreateNodes(List<VSNodeData> nodeDatas) async {
    for (final node in nodeDatas) {
      _nodes[node.id] = node;
    }
    nodes = Map.from(_nodes);
  }

  /// Removes multiple nodes and clears their references
  ///
  /// [nodeDatas] is a list of nodes to remove
  Future<void> removeNodes(List<VSNodeData> nodeDatas) async {
    // Remove nodes from the map
    for (final node in nodeDatas) {
      _nodes.remove(node.id);
    }
    nodes = Map.from(_nodes);

    // Clear references to removed nodes
    for (final node in _nodes.values) {
      for (final input in node.inputData) {
        if (nodeDatas.contains(input.connectedInterface?.nodeData)) {
          input.connectedInterface = null;
        }
      }
    }
  }

  /// Clears all nodes from the manager
  Future<void> clearNodes() async {
    nodes = {};
  }

  /// Gets a node by its ID
  VSNodeData? getNodeById(String id) => _nodes[id];

  /// Checks if a node exists
  bool hasNode(String id) => _nodes.containsKey(id);

  /// Gets all nodes of a specific type
  Iterable<T> getNodesOfType<T>() => _nodes.values.whereType<T>();
}
