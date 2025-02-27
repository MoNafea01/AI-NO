import 'package:ai_gen/node_package/data/vs_node_data_provider.dart';
import 'package:flutter/material.dart';

class InheritedNodeDataProvider extends InheritedWidget {
  const InheritedNodeDataProvider({
    super.key,
    required this.provider,
    required super.child,
  });

  final VSNodeDataProvider provider;

  @override
  bool updateShouldNotify(InheritedNodeDataProvider oldWidget) =>
      provider.nodeManager.nodes != provider.nodeManager.nodes;
}
