import 'package:flutter/material.dart';

import '../data/vs_node_data_provider.dart';

class InheritedNodeDataProvider extends InheritedWidget {
  final VSNodeDataProvider provider;

  const InheritedNodeDataProvider({
    required this.provider,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant InheritedNodeDataProvider oldWidget) {
    return oldWidget.provider != provider;
  }
}
