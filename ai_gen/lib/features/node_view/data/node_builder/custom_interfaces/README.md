# Custom Interfaces

This folder contains all the custom input and output data interfaces for the node system.

## Structure

### Base Classes
- `base/base_interface.dart` - Abstract base classes for input and output data
- `base/universal_accepted_types.dart` - Types accepted by all interfaces
- `interface_colors.dart` - Color coding for different node types

### Core Interfaces
- `aino_general_Interface.dart` - General purpose input/output interfaces
- `model_interface.dart` - Model-specific interfaces
- `preprocessor_interface.dart` - Preprocessor-specific interfaces
- `network_interface.dart` - Network-specific interfaces
- `fitter_interface.dart` - Fitter-specific interfaces
- `multi_output_interface.dart` - Multi-output node interfaces

### Specialized Interfaces
- `node_loader_interface.dart` - Node loading interfaces
- `node_template_saver_interface.dart` - Template saving interfaces
- `vs_text_input_data.dart` - Text input interfaces

### Factory
- `../builder/interface_factory.dart` - Factory for creating interfaces based on node properties

## Usage

### Importing
```dart
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/custom_interfaces.dart';
```

### Using the InterfaceFactory (Recommended)

The `InterfaceFactory` provides a centralized way to create interfaces:

```dart
import 'package:ai_gen/features/node_view/presentation/node_builder/builder/interface_factory.dart';

// Creating input interfaces
VSInputData modelInput = InterfaceFactory.createInputData(
  node,
  "model",
  initialConnection,
);

// Creating output interfaces
List<VSOutputData> outputs = InterfaceFactory.createOutputData(node);
```

### Direct Instantiation
```dart
// Direct instantiation (less recommended)
final modelInput = VSModelInputData(type: "model", node: node);
final modelOutput = VSModelOutputData(type: "model", node: node);
```

### Integration with NodeFactory

The `NodeFactory` now uses the `InterfaceFactory` internally:

```dart
class NodeFactory {
  // ...
  
  List<VSInputData> _buildInputData(NodeModel node, VSOutputData? ref) {
    return [
      ...node.inputDots?.map((inputDot) => 
        InterfaceFactory.createInputData(node, inputDot, ref)
      ) ?? [],
    ];
  }

  List<VSOutputData> _buildOutputData(NodeModel node) {
    return InterfaceFactory.createOutputData(node);
  }
}
```

### Extending Base Classes
```dart
class CustomInputData extends BaseInputData {
  CustomInputData({required super.type, required super.node});
  
  @override
  List<Type> get acceptedTypes => [CustomOutputData];
}

class CustomOutputData extends BaseOutputData {
  CustomOutputData({required super.type, required super.node});
  
  @override
  Map<String, dynamic> buildApiBody(Map<String, dynamic> inputData) {
    final apiBody = super.buildApiBody(inputData);
    // Add custom fields
    return apiBody;
  }
}
```

## Design Principles

1. **Single Responsibility**: Each interface handles one specific type of data
2. **Inheritance**: All interfaces extend base classes for common functionality
3. **Factory Pattern**: Use InterfaceFactory for creating appropriate interfaces
4. **Type Safety**: Strong typing for accepted connection types
5. **Error Handling**: Proper error handling in base classes
6. **Documentation**: Comprehensive documentation for all public APIs

## Benefits of Using InterfaceFactory

1. **Centralized Logic**: All interface creation logic is in one place
2. **Easy Maintenance**: Adding new interface types only requires updating the factory
3. **Consistency**: Ensures consistent interface creation across the application
4. **Reduced Duplication**: Eliminates code duplication in node building logic
5. **Type Safety**: Factory handles all type checking and validation 