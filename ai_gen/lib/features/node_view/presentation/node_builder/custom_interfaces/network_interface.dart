import 'package:ai_gen/test/presentation/node_builder/custom_interfaces/aino_general_Interface.dart';

import 'base/base_interface.dart';
import 'multi_output_interface.dart';

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
  List<Type> get acceptedTypes =>
      [VSAINOGeneralOutputData, VSNetworkOutputData, MultiOutputOutputData];
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
}
