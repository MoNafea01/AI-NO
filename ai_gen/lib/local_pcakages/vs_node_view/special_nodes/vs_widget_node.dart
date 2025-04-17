import 'package:flutter/material.dart';

import '../data/vs_interface.dart';
import '../data/vs_node_data.dart';

class VSWidgetNode extends VSNodeData {
  ///Widget Node
  ///
  ///Can be used to add a custom UI component to a node
  VSWidgetNode({
    String? id,
    required String type,
    required Offset widgetOffset,
    required VSOutputData outputData,
    required this.setValue,
    required this.getValue,
    required this.child,
    double? nodeWidth,
    String? title,
    String? toolTip,
    Function(VSInputData interfaceData)? onUpdatedConnection,
  }) : super(
          id: id,
          type: type,
          widgetOffset: widgetOffset,
          inputData: const [],
          outputData: [outputData],
          nodeWidth: nodeWidth,
          title: title,
          toolTip: toolTip,
          onUpdatedConnection: onUpdatedConnection,
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    return json..["value"] = getValue();
  }

  final Widget child;

  ///Used to set the value of the supplied widget during deserialization
  final Function(dynamic) setValue;

  ///Used to get the value of the supplied widget during serialization
  final dynamic Function() getValue;
}
