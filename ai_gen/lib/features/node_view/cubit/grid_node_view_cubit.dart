import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/node_view/data/api_services/node_server_calls.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/node_builder.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

part 'node_view_state.dart';

class GridNodeViewCubit extends Cubit<GridNodeViewState> {
  GridNodeViewCubit({required this.projectModel})
      : showGrid = true,
        super(GridNodeViewInitial());

  ProjectModel projectModel;

  late VSNodeDataProvider nodeDataProvider;
  Iterable<String?>? results;
  late bool showGrid;
  NodeModel? activePropertiesNode;

  final NodeServerCalls _nodeServerCalls = GetIt.I.get<NodeServerCalls>();
  void toggleGrid() {
    showGrid = !showGrid;
    emit(NodeViewSuccess());
  }

  Future buildNodes() async {
    try {
      emit(GridNodeViewLoading());
      await _loadOrCreateProject();

      final NodeBuilder nodeBuilderInstance =
          NodeBuilder(projectId: projectModel.id!);
      final List<Object> nodeBuilder =
          await nodeBuilderInstance.buildNodesMenu();

      List<NodeModel> projectNodes = await _loadProjectNodes();

      nodeDataProvider = VSNodeDataProvider(
        nodeManager: VSNodeManager(nodeBuilders: nodeBuilder),
        withAppbar: true,
      );

      List nodeBuilders = projectNodes.map(
        (node) {
          return nodeBuilderInstance.buildNode(node)(
            node.offset ?? const Offset(350, 350),
            null,
          );
        },
      ).toList();
      nodeDataProvider.updateOrCreateNodes([...nodeBuilders]);

      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  Future<List<NodeModel>> _loadProjectNodes() async {
    List<NodeModel> projectNodes =
        await _nodeServerCalls.getProjectNodes(projectModel.id!);

    for (var nodeModel in projectNodes) {
      print("Project Node: ${nodeModel.toJson()}");
    }
    return projectNodes;
  }

  Future<void> _loadOrCreateProject() async {
    if (projectModel.id == null) {
      projectModel = await _nodeServerCalls.createProject(
        projectModel.name ?? "project Name",
        projectModel.description ?? "project Description",
      );
      print("Project Created: ${projectModel.toJson().toString()}");
    } else {
      projectModel = await _nodeServerCalls.getProject(projectModel.id!);
      print("Project get Data: ${projectModel.toJson().toString()}");
    }
  }

  Future clearNodes() async {
    try {
      emit(GridNodeViewLoading());
      _closeActiveNodePropertiesCard();
      _closeRunMenu();

      final List<Object> nodeBuilder =
          await NodeBuilder(projectId: 1).buildNodesMenu();

      nodeDataProvider = VSNodeDataProvider(
        nodeManager: VSNodeManager(nodeBuilders: nodeBuilder),
        withAppbar: true,
      );

      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  void runNodes() async {
    _closeActiveNodePropertiesCard();
    closeRunMenu();

    List<MapEntry<String, dynamic>> entries = [];

    for (VSOutputNode vsOutputNode
        in nodeDataProvider.nodeManager.getOutputNodes) {
      MapEntry<String, dynamic> nodeOutput = await vsOutputNode.evaluate();
      dynamic asyncOutput = await nodeOutput.value;
      nodeOutput = MapEntry(nodeOutput.key, asyncOutput);
      entries.add(nodeOutput);
    }

    results = entries.map(
      (output) {
        if (output.value != null) {
          return "${output.key}: ${output.value}".replaceAll(",", ",\n");
        }
        return null;
      },
    );
    _updateProjectNodes();
    emit(NodeViewSuccess());
  }

  Future _updateProjectNodes() async {
    List<Map<String, dynamic>> nodes = nodeDataProvider.nodes.values
        .where((e) => e.node != null)
        .map((e) => e.node!.toJson())
        .toList();

    await _nodeServerCalls.updateProjectNodes(nodes, projectModel.id!);
  }

  void _closeRunMenu() {
    results = null;
  }

  void closeRunMenu() async {
    _closeRunMenu();
    emit(NodeViewSuccess());
  }

  void updateActiveNodePropertiesCard(NodeModel? node) {
    _closeRunMenu();
    activePropertiesNode = node;
    emit(NodeViewSuccess());
  }

  void _closeActiveNodePropertiesCard() {
    activePropertiesNode = null;
  }

  void closeActiveNodePropertiesCard() {
    _closeActiveNodePropertiesCard();
    emit(NodeViewSuccess());
  }
}
