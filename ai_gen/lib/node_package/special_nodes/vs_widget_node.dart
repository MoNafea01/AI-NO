import 'package:ai_gen/node_package/data/vs_node_data.dart';
import 'package:flutter/material.dart';

class VSWidgetNode extends VSNodeData {
  ///Widget Node
  ///
  ///Can be used to add a custom UI component to a node
  VSWidgetNode({
    super.id,
    required super.type,
    required super.widgetOffset,
    required super.outputData,
    super.inputData = const [],
    required this.setValue,
    required this.getValue,
    this.child,
    super.nodeWidth,
    super.title,
    super.toolTip,
    super.onUpdatedConnection,
  }) : super(

        ///ELDemy:: Commented out the following lines and added them to above
        // inputData: const [],
        // outputData: [outputData],
        );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    return json..["value"] = getValue();
  }

  final Widget? child;

  ///Used to set the value of the supplied widget during deserialization
  final Function(dynamic) setValue;

  ///Used to get the value of the supplied widget during serialization
  final dynamic Function() getValue;
}
