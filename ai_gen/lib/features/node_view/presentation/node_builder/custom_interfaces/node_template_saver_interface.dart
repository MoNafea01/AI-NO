import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/fitter_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'base/base_interface.dart';
import 'model_interface.dart';
import 'multi_output_interface.dart';
import 'network_interface.dart';
import 'preprocessor_interface.dart';

class VSNodeTemplateSaverInputData extends BaseInputData {
  ///Basic List input interface
  VSNodeTemplateSaverInputData({
    required super.type,
    required super.node,
    super.title,
    super.toolTip,
    super.initialConnection,
  });

  @override
  IconData get connectedInputIcon => Icons.square_rounded;
  @override
  IconData get inputIcon => Icons.square_outlined;

  @override
  List<Type> get acceptedTypes => [
        BaseOutputData,
        VSModelOutputData,
        VSNetworkOutputData,
        VSFitterOutputData,
        VSNodeTemplateSaverOutputData,
        MultiOutputOutputData,
        VSPreprocessorInputData,
      ];
}

class VSNodeTemplateSaverOutputData extends BaseOutputData {
  ///Basic List output interface
  VSNodeTemplateSaverOutputData({required super.type, required super.node});

  @override
  IconData get outputIcon => Icons.square_rounded;

  Future<void> Function(Map<String, dynamic> data) get _outputFunction {
    return (Map<String, dynamic> data) async {
      await runNodeWithData(data);

      GetIt.I.get<GridNodeViewCubit>().loadNodeView();
    };
  }

  @override
  Future<dynamic> Function(Map<String, dynamic> data) get outputFunction =>
      _outputFunction;
}
