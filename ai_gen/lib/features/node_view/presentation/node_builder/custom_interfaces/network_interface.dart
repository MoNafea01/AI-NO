import 'package:ai_gen/test/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';

import 'base/base_interface.dart';
import 'base/universal_accepted_types.dart';
import 'multi_output_interface.dart';
import 'node_loader_interface.dart';

/// Input data interface for network nodes.
/// Handles connections to network outputs and other compatible data types.
class VSNetworkInputData extends BaseInputData {
  ///Basic List input interface
  VSNetworkInputData({
    required super.type,
    required super.node,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.inputIcon,
    super.connectedInputIcon,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [
        ...universalAcceptedTypes,
        VSAINOGeneralOutputData,
        VSNetworkOutputData,
        MultiOutputOutputData,
        VSNodeLoaderOutputData
      ];
}

/// Output data interface for network nodes.
/// Handles network execution and provides network-specific functionality.
class VSNetworkOutputData extends BaseOutputData {
  ///Basic List output interface
  VSNetworkOutputData({
    required super.type,
    required super.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });
}
