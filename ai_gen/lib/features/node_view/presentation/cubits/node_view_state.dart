part of 'node_view_cubit.dart';

@immutable
sealed class BlockLoaderState {}

final class NodeViewInitial extends BlockLoaderState {}

final class NodeViewLoading extends BlockLoaderState {}

final class NodeViewSuccess extends BlockLoaderState {
  final List<Object> nodeBuilder;
  NodeViewSuccess(this.nodeBuilder);
}

final class NodeViewFailure extends BlockLoaderState {
  final String errMessage;

  NodeViewFailure(this.errMessage);
}
