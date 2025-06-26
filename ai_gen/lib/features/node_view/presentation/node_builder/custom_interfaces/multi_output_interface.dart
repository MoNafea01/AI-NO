import 'package:ai_gen/core/network/services/interfaces/node_services_interface.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/base/base_interface.dart';
import 'package:get_it/get_it.dart';

import 'base/universal_accepted_types.dart';

/// A class to hold shared state for output data
class OutputState {
  bool isRunning = false;
}

class MultiOutputInputInterface extends BaseInputData {
  MultiOutputInputInterface({
    required super.node,
    required super.type,
    super.title,
    super.toolTip,
    super.initialConnection,
    super.interfaceIconBuilder,
  });

  @override
  List<Type> get acceptedTypes => [
        ...universalAcceptedTypes,
      ];
}

class MultiOutputOutputData extends BaseOutputData {
  MultiOutputOutputData({
    required this.index,
    required super.type,
    required super.node,
    required this.outputState,
    super.outputFunction,
  });

  final int index;
  final OutputState outputState;

  @override
  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)
      get outputFunction {
    return (inputData) async {
      final nodeServices = GetIt.I.get<INodeServices>();
      if (index == 0) {
        outputState.isRunning = true;
        await runNodeWithData(inputData);
        outputState.isRunning = false;
      } else {
        int x = 0;
        while (node.nodeId == null) {
          await Future.delayed(const Duration(milliseconds: 100));
          x++;
          if (x == 20 && !outputState.isRunning) {
            await runNodeWithData(inputData);
            break;
          }
        }
      }

      return await nodeServices.getNode(node, index + 1);
    };
  }
}
