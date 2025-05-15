import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_interface.dart';
import 'package:flutter/material.dart';

import 'interface_colors.dart';
import 'multi_output_interface.dart';
import 'network_interface.dart';

Color _interfaceColor = NodeTypes.general.color;

class VSFitterInputData extends VSAINOGeneralInputData {
  ///Basic List input interface
  VSFitterInputData({
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
      [VSAINOGeneralOutputData, MultiOutputOutputData, VSNetworkOutputData];

  @override
  Color get interfaceColor => _interfaceColor;
}

class VSFitterOutputData extends VSAINOGeneralOutputData {
  ///Basic List output interface
  VSFitterOutputData({
    required super.type,
    required super.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });
}
