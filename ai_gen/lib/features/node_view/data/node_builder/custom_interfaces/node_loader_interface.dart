import 'package:ai_gen/local_pcakages/vs_node_view/data/vs_interface.dart';

import 'base/base_interface.dart';
import 'base/universal_accepted_types.dart';

/// Input data interface for node loader nodes.
/// Handles connections to various data types and provides flexible input acceptance.
class VSNodeLoaderInputData extends BaseInputData {
  ///Basic List input interface
  VSNodeLoaderInputData({
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
      ];
  @override
  bool acceptInput(VSOutputData? data) {
    return true; // Accepts any input type
  }
}

/// Output data interface for node loader nodes.
/// Handles node loading execution and provides loader-specific functionality.
class VSNodeLoaderOutputData extends BaseOutputData {
  ///Basic List output interface
  VSNodeLoaderOutputData({
    required super.type,
    required super.node,
    super.outputFunction,
    super.interfaceIconBuilder,
    super.outputIcon,
  });
}
