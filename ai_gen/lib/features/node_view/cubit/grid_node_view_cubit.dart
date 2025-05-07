import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/node_view/data/api_services/node_server_calls.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/node_builder.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/src/response.dart';
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
  late VSNodeManager nodeManager;

  final NodeServerCalls _nodeServerCalls = GetIt.I.get<NodeServerCalls>();
  void toggleGrid() {
    showGrid = !showGrid;
    emit(NodeViewSuccess());
  }

  Future loadNodeView() async {
    try {
      emit(GridNodeViewLoading());
      await _loadOrCreateProject();

      final List<Object> nodeBuilder =
          await NodeBuilder(projectId: projectModel.id!).buildNodesMenu();
      nodeManager = VSNodeManager(nodeBuilders: nodeBuilder);

      await _loadProjectNodes();

      nodeDataProvider = VSNodeDataProvider(
        nodeManager: nodeManager,
        withAppbar: true,
      );

      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  Future<void> _loadOrCreateProject() async {
    if (projectModel.id == null) {
      projectModel = await _nodeServerCalls.createProject(
        projectModel.name ?? "project Name",
        projectModel.description ?? "project Description",
      );
    } else {
      projectModel = await _nodeServerCalls.getProject(projectModel.id!);
    }
  }

  Future<void> _loadProjectNodes() async {
    Response responseProjectNodes =
        await _nodeServerCalls.loadProjectNodes(projectModel.id!);

    nodeManager.myDeSerializedNodes(responseProjectNodes);
  }

  Future clearNodes() async {
    try {
      emit(GridNodeViewLoading());
      _closeActiveNodePropertiesCard();
      _closeRunMenu();

      nodeManager.clearNodes();

      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  void runNodes() async {
    try {
      _closeActiveNodePropertiesCard();
      results = ("Running nodes...").split(",");
      emit(NodeViewSuccess());

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

      saveProjectNodes();
      emit(NodeViewSuccess());
    } catch (e) {
      results = ("Wrong parameter type").split(",");
      emit(NodeViewSuccess());
    }
  }

  Future saveProjectNodes() async {
    List<Map<String, dynamic>> nodes = nodeManager.mySerializeNodes();
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
