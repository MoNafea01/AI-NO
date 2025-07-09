import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';

import '../../../data/node_builder/custom_interfaces/custom_interfaces.dart';

/// Input data interface for general AINO nodes.
class VSAINOGeneralInputData extends BaseInputData {
  ///Basic List input interface
  VSAINOGeneralInputData({
    required super.type,
    required super.node,
    this.acceptAll = false,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.inputIcon,
    super.connectedInputIcon,
    super.interfaceIconBuilder,
  });

  final bool acceptAll;

  @override
  bool acceptInput(VSOutputData? data) {
    return acceptAll ? true : super.acceptInput(data);
  }

  @override
  List<Type> get acceptedTypes => [
        ...universalAcceptedTypes,
        VSAINOGeneralOutputData,
        VSNetworkOutputData,
      ];
}

/// Output data interface for general AINO nodes.
class VSAINOGeneralOutputData extends BaseOutputData {
  ///Basic List output interface
  VSAINOGeneralOutputData({
    required super.type,
    required super.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });
}
