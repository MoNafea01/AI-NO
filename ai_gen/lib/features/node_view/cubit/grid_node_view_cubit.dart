import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/node_builder.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'node_view_state.dart';

class GridNodeViewCubit extends Cubit<GridNodeViewState> {
  GridNodeViewCubit()
      : showGrid = true,
        super(GridNodeViewInitial());

  late VSNodeDataProvider nodeDataProvider;
  Iterable<String>? results;
  late bool showGrid;

  NodeModel? activePropertiesNode;
  void toggleGrid() {
    showGrid = !showGrid;
    emit(NodeViewSuccess());
  }

  Future buildNodes() async {
    try {
      emit(GridNodeViewLoading());

      final List<Object> nodeBuilder = await NodeBuilder().buildNodesMenu();
      nodeDataProvider = VSNodeDataProvider(
        nodeManager: VSNodeManager(nodeBuilders: nodeBuilder),
        withAppbar: true,
      );
      emit(NodeViewSuccess());
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }

  Future clearNodes() async {
    try {
      emit(GridNodeViewLoading());

      final List<Object> nodeBuilder = await NodeBuilder().buildNodesMenu();

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
    List<MapEntry<String, dynamic>> entries = nodeDataProvider
        .nodeManager.getOutputNodes
        .map((e) => e.evaluate())
        .toList();

    for (var i = 0; i < entries.length; i++) {
      dynamic asyncOutput = await entries[i].value;
      entries[i] = MapEntry(entries[i].key, asyncOutput);
    }

    results = entries.map(
      (output) => "${output.key}: ${output.value}".replaceAll(",", ",\n"),
    );

    emit(NodeViewSuccess());
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
