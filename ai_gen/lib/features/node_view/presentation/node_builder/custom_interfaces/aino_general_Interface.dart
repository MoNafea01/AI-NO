import 'base/base_interface.dart';
import 'multi_output_interface.dart';
import 'network_interface.dart';

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
        VSAINOGeneralOutputData,
        MultiOutputOutputData,
        VSNetworkOutputData,
      ];
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
}
