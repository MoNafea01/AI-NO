import 'base/base_interface.dart';
import 'base/universal_accepted_types.dart';
import 'multi_output_interface.dart';
import 'network_interface.dart';

/// Input data interface for general AINO nodes.
class VSAINOGeneralInputData extends BaseInputData {
  ///Basic List input interface
  VSAINOGeneralInputData({
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
        MultiOutputOutputData,
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
