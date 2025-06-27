import 'package:ai_gen/features/node_view/presentation/node_builder/builder/node_builder.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';
import 'package:vs_node_view/data/vs_node_manager.dart';

part 'node_view_state.dart';

class GridNodeViewCubit extends Cubit<GridNodeViewState> {
  GridNodeViewCubit() : super(GridNodeViewInitial());

  late final VSNodeDataProvider nodeDataProvider;
  Iterable<String>? results;
  Future buildNodes() async {
    try {
      emit(GridNodeViewLoading());

      final List<Object> nodeBuilder =
          await NodeMenuBuilder(projectId: 1).buildNodesMenu();

      nodeDataProvider = VSNodeDataProvider(
        nodeManager: VSNodeManager(nodeBuilders: nodeBuilder),
      );
      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  void runNodes() async {
    List<MapEntry<String, dynamic>> entries = nodeDataProvider
        .nodeManager.getOutputNodes
        .map((e) => e.evaluate())
        .toList();

    for (var i = 0; i < entries.length; i++) {
      var asyncOutput = await entries[i].value;
      entries[i] = MapEntry(entries[i].key, asyncOutput);
    }

    results = entries.map((e) => "${e.key}: ${e.value}");
    emit(NodeViewSuccess());
    // setState(() => results = entries.map((e) => "${e.key}: ${e.value}"));
  }
}
