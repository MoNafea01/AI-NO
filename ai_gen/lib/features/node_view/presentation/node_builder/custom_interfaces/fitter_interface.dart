import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/aino_general_interface.dart';

import 'base/base_interface.dart';
import 'multi_output_interface.dart';
import 'network_interface.dart';

class VSFitterInputData extends BaseInputData {
  ///Basic List input interface
  VSFitterInputData({
    required super.type,
    super.node,
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
}

class VSFitterOutputData extends BaseOutputData {
  ///Basic List output interface
  VSFitterOutputData({
    required super.type,
    required super.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });
}
