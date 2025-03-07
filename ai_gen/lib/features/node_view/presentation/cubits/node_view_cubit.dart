import 'package:ai_gen/features/node_view/presentation/node_builder/node_builder.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'node_view_state.dart';

class NodeLoaderCubit extends Cubit<NodeLoaderState> {
  NodeLoaderCubit() : super(NodeViewInitial()) {
    buildNodes();
  }

  Future buildNodes() async {
    try {
      emit(NodeViewLoading());

      final List<Object> nodeBuilder = await NodeBuilder().buildNodesMenu();

      emit(NodeViewSuccess(nodeBuilder));
    } catch (e) {
      emit(NodeViewFailure(e.toString()));
    }
  }
}
