import 'package:ai_gen/features/node_view/presentation/node_builder/node_builder.dart';
import 'package:ai_gen/node_package/data/vs_subgroup.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'node_view_state.dart';

class BlockLoaderCubit extends Cubit<BlockLoaderState> {
  BlockLoaderCubit() : super(NodeViewInitial()) {
    buildBlocks();
  }

  Future buildBlocks() async {
    try {
      emit(NodeViewLoading());

      final List<VSSubgroup> nodeBuilder = await NodeBuilder().buildBlocks();

      emit(NodeViewSuccess(nodeBuilder));
    } catch (e) {
      emit(NodeViewFailure("Failed to load blocks"));
    }
  }
}
