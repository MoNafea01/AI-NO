import 'dart:developer';

import 'package:ai_gen/core/data/network/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/core/data/network/services/interfaces/project_services_interface.dart';
import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/builder/node_builder.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

part 'node_view_state.dart';

class GridNodeViewCubit extends Cubit<GridNodeViewState> {
  GridNodeViewCubit({required this.projectModel})
      : showGrid = true,
        isSidebarVisible = true,
        super(GridNodeViewInitial());

  // Models and Data
  ProjectModel projectModel;
  NodeModel? activePropertiesNode;

  // Node Management
  late VSNodeDataProvider nodeDataProvider;
  late VSNodeManager nodeManager;
  // Iterable<String?>? results;
  Iterable<Map<String, dynamic>?>? results;

  // UI State
  late bool showGrid;
  bool isSidebarVisible;

  // Services
  final IProjectServices _projectServices = GetIt.I.get<IProjectServices>();
  final INodeServices _nodeServices = GetIt.I.get<INodeServices>();

  // UI State Management
  void toggleGrid() {
    showGrid = !showGrid;
    emit(NodeViewSuccess());
  }

  Future<void> exportProject() async {
    // await _nodeServerCalls.exportProject(projectModel.id!);
  }

  void toggleSidebar() {
    isSidebarVisible = !isSidebarVisible;
    emit(NodeViewSuccess());
  }

  // Node View Initialization
  Future<void> loadNodeView() async {
    try {
      emit(GridNodeViewLoading());
      await _initializeProject();
      await _initializeNodeManager();
      await _loadOrUpdateProjectNodes();
      _initializeNodeDataProvider();
      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  Future<void> _initializeProject() async {
    if (projectModel.id == null) {
      projectModel = await _projectServices.createProject(
        projectModel.name ?? "project Name",
        projectModel.description ?? "project Description",
      );
    } else {
      projectModel = await _projectServices.getProject(projectModel.id!);
    }
  }

  Future<void> _initializeNodeManager() async {
    try {
      final List<Object> nodeBuilder =
          await NodeMenuBuilder(projectId: projectModel.id!).buildNodesMenu();
      nodeManager = VSNodeManager(nodeBuilders: nodeBuilder);
    } catch (e) {
      log(e.toString());
      throw ("Error initializing node manager. Please Update the app");
    }
  }

  void _initializeNodeDataProvider() {
    nodeDataProvider = VSNodeDataProvider(
      nodeManager: nodeManager,
      withAppbar: true,
    );
  }

  // Node Operations
  Future<void> _loadOrUpdateProjectNodes() async {
    Response responseProjectNodes =
        await _nodeServices.loadProjectNodes(projectModel.id!);

    nodeManager.myDeSerializedNodes(responseProjectNodes);
  }

  // used in importing other files
  Future<void> updateNodes() async {
    try {
      emit(NodeViewUpdating());
      nodeManager.clearNodes();
      log("update nodes");
      await _loadOrUpdateProjectNodes();
      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  Future<void> clearNodes() async {
    try {
      emit(GridNodeViewLoading());
      _resetUIState();
      nodeManager.clearNodes();
      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  void _resetUIState() {
    _closeActiveNodePropertiesCard();
    _closeRunMenu();
  }

  Future<void> runNodes() async {
    try {
      _closeActiveNodePropertiesCard();
      _updateRunningStatus();

      final entries = await _evaluateOutputNodes();
      _processNodeResults(entries);

      await saveProjectNodes();
      emit(NodeViewSuccess());
    } catch (e) {
      _handleRunError();
    }
  }

  void _updateRunningStatus() {
    results = [
      {"RUN": "Running nodes..."}
    ];
    emit(NodeViewSuccess());
  }

  Future<List<MapEntry<String, dynamic>>> _evaluateOutputNodes() async {
    List<MapEntry<String, dynamic>> entries = [];
    for (VSOutputNode vsOutputNode
        in nodeDataProvider.nodeManager.getOutputNodes) {
      MapEntry<String, dynamic> nodeOutput = await vsOutputNode.evaluate();
      dynamic asyncOutput = await nodeOutput.value;
      entries.add(MapEntry(nodeOutput.key, asyncOutput));
    }
    return entries;
  }

  void _processNodeResults(List<MapEntry<String, dynamic>> entries) {
    results = entries.map(
      (output) {
        if (output.value != null) {
          if (output.value['node_data'] is String) {
            return {output.key: output.value['message']};
          } else {
            return {output.key: output.value['node_data']};
          }
          // return "${output.key}: ${output.value}".replaceAll(",", ",\n");
        }
        return null;
      },
    );
  }

  void _handleRunError() {
    results = [
      {"Run": "Wrong parameter type"}
    ];
    emit(NodeViewSuccess());
  }

  Future<void> saveProjectNodes() async {
    List<Map<String, dynamic>> nodes = nodeManager.mySerializeNodes();
    await _nodeServices.saveProjectNodes(nodes, projectModel.id!);
  }

  // UI State Management
  void _closeRunMenu() {
    results = null;
  }

  void closeRunMenu() {
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
