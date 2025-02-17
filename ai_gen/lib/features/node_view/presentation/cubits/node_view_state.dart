part of 'node_view_cubit.dart';

@immutable
sealed class NodeLoaderState {}

final class NodeViewInitial extends NodeLoaderState {}

final class NodeViewLoading extends NodeLoaderState {}

final class NodeViewSuccess extends NodeLoaderState {
  final List<VSSubgroup> nodeBuilder;
  NodeViewSuccess(this.nodeBuilder);
}

final class NodeViewFailure extends NodeLoaderState {
  final String errMessage;

  NodeViewFailure(this.errMessage);
}
