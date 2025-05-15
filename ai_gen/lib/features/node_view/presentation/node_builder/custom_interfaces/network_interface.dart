import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';
import 'package:ai_gen/test/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';
import 'package:flutter/material.dart';

import 'base/base_interface.dart';
import 'interface_colors.dart';
import 'multi_output_interface.dart';

Color _interfaceColor = NodeTypes.general.color;

class VSNetworkInputData extends VSInputData {
  ///Basic List input interface
  VSNetworkInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.inputIcon,
    super.connectedInputIcon,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes =>
      [VSAINOGeneralOutputData, VSNetworkOutputData, MultiOutputOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSNetworkOutputData extends BaseOutputData {
  ///Basic List output interface
  VSNetworkOutputData({
    required super.type,
    required super.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });

  @override
  Color get interfaceColor => node.color;
}
