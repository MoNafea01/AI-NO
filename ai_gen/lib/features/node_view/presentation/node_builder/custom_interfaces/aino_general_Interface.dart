import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/base/base_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/multi_output_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/network_interface.dart';
import 'package:flutter/material.dart';

import 'interface_colors.dart';

Color _interfaceColor = NodeTypes.general.color;

class VSAINOGeneralInputData extends BaseInputData {
  ///Basic List input interface
  VSAINOGeneralInputData({
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.inputIcon,
    super.connectedInputIcon,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [
        VSAINOGeneralOutputData,
        MultiOutputOutputData,
        VSNetworkOutputData,
      ];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSAINOGeneralOutputData extends BaseOutputData {
  ///Basic List output interface
  VSAINOGeneralOutputData({
    required super.type,
    required super.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });

  @override
  Color get interfaceColor => node.color;
}
