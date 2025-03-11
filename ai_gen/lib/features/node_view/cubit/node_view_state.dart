part of 'grid_node_view_cubit.dart';

@immutable
sealed class GridNodeViewState {}

final class GridNodeViewInitial extends GridNodeViewState {}

final class GridNodeViewLoading extends GridNodeViewState {}

final class NodeViewSuccess extends GridNodeViewState {}

final class NodeViewFailure extends GridNodeViewState {
  final String errMessage;

  NodeViewFailure(this.errMessage);
}
