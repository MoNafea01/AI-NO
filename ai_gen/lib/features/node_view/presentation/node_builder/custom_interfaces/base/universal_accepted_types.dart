import '../multi_output_interface.dart';
import '../node_loader_interface.dart';

/// Universal types that are accepted by all input interfaces.
/// These types represent the most basic and commonly used output data types
/// that can be connected to any input interface.
final List<Type> universalAcceptedTypes = [
  VSNodeLoaderOutputData,
  MultiOutputOutputData,
];
