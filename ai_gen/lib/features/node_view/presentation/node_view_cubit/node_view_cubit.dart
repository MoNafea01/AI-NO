import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'node_view_state.dart';

class NodeViewCubit extends Cubit<NodeViewState> {
  NodeViewCubit() : super(NodeViewInitial());
}
