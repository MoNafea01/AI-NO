import 'custom_interfaces.dart';

/// Input data interface for fitter nodes.
/// Handles connections to fitter outputs and other compatible data types.
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
  List<Type> get acceptedTypes => [
        ...universalAcceptedTypes,
        VSAINOGeneralOutputData,
        VSNetworkOutputData,
        VSNodeLoaderOutputData,
        VSFitterOutputData,
      ];
}

/// Output data interface for fitter nodes.
/// Handles fitter execution and provides fitter-specific functionality.
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
