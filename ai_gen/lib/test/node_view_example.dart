import 'package:flutter/material.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_bool_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_double_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_dynamic_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_int_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_num_interface.dart';
import 'package:vs_node_view/data/standard_interfaces/vs_string_interface.dart';
import 'package:vs_node_view/data/vs_interface.dart';
import 'package:vs_node_view/data/vs_node_data.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';
import 'package:vs_node_view/data/vs_node_manager.dart';
import 'package:vs_node_view/data/vs_subgroup.dart';
import 'package:vs_node_view/special_nodes/vs_output_node.dart';
import 'package:vs_node_view/special_nodes/vs_widget_node.dart';
import 'package:vs_node_view/widgets/interactive_vs_node_view.dart';

class PackageExample extends StatelessWidget {
  const PackageExample({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: VSNodeExample());
  }
}

class VSNodeExample extends StatefulWidget {
  const VSNodeExample({super.key});

  @override
  State<VSNodeExample> createState() => _VSNodeExampleState();
}

class _VSNodeExampleState extends State<VSNodeExample> {
  Iterable<String>? results;

  late VSNodeDataProvider nodeDataProvider;

  @override
  void initState() {
    super.initState();

    final nodeBuilders = [
      VSSubgroup(
        name: "Numbers",
        subgroup: [
          (Offset offset, VSOutputData? ref) => VSNodeData(
                type: "Parse int",
                widgetOffset: offset,
                inputData: [
                  VSStringInputData(
                    type: "Input",
                    initialConnection: ref,
                  )
                ],
                outputData: [
                  VSIntOutputData(
                    type: "Output",
                    outputFunction: (data) => int.parse(data["Input"]),
                  ),
                ],
              ),
          (Offset offset, VSOutputData? ref) => VSNodeData(
                type: "Sum",
                widgetOffset: offset,
                inputData: [
                  VSNumInputData(
                    type: "Input 1",
                    initialConnection: ref,
                  ),
                  VSNumInputData(
                    type: "Input 2",
                    initialConnection: ref,
                  )
                ],
                outputData: [
                  VSNumOutputData(
                    type: "output",
                    outputFunction: (data) {
                      return (data["Input 1"] ?? 0) + (data["Input 2"] ?? 0);
                    },
                  ),
                ],
              ),
        ],
      ),
      VSSubgroup(
        name: "Logik",
        subgroup: [
          (Offset offset, VSOutputData? ref) => VSNodeData(
                type: "Bigger then",
                widgetOffset: offset,
                inputData: [
                  VSNumInputData(
                    type: "First",
                    initialConnection: ref,
                  ),
                  VSNumInputData(
                    type: "Second",
                    initialConnection: ref,
                  ),
                ],
                outputData: [
                  VSBoolOutputData(
                    type: "Output",
                    outputFunction: (data) => data["First"] > data["Second"],
                  ),
                ],
              ),
          (Offset offset, VSOutputData? ref) => VSNodeData(
                type: "If",
                widgetOffset: offset,
                inputData: [
                  VSBoolInputData(
                    type: "Input",
                    initialConnection: ref,
                  ),
                  VSDynamicInputData(
                    type: "True",
                    initialConnection: ref,
                  ),
                  VSDynamicInputData(
                    type: "False",
                    initialConnection: ref,
                  ),
                ],
                outputData: [
                  VSDynamicOutputData(
                    type: "Output",
                    outputFunction: (data) =>
                        data["Input"] ? data["True"] : data["False"],
                  ),
                ],
              ),
        ],
      ),
      (Offset offset, VSOutputData? ref) {
        final controller = TextEditingController();
        final input = TextField(
          controller: controller,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          ),
        );

        return VSWidgetNode(
          type: "Input",
          widgetOffset: offset,
          outputData: VSStringOutputData(
            type: "Output",
            outputFunction: (data) => controller.text,
          ),
          child: Expanded(child: input),
          setValue: (value) => controller.text = value,
          getValue: () => controller.text,
        );
      },
      (Offset offset, VSOutputData? ref) => VSOutputNode(
            type: "Output",
            widgetOffset: offset,
            ref: ref,
          ),
    ];

    nodeDataProvider = VSNodeDataProvider(
      nodeManager: VSNodeManager(nodeBuilders: nodeBuilders),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveVSNodeView(
          width: 5000,
          height: 5000,
          nodeDataProvider: nodeDataProvider,
        ),
        const Positioned(
          bottom: 0,
          right: 0,
          child: Legend(),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => setState(() {
                  final entries =
                      nodeDataProvider.nodeManager.getOutputNodes.map(
                    (e) => e.evaluate(
                      onError: (_, __) => Future.delayed(Duration.zero, () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.deepOrange,
                            content: Text('An error occured'),
                          ),
                        );
                      }),
                    ),
                  );

                  results = entries.map((e) => "${e.key}: ${e.value}");
                }),
                child: const Text("Evaluate"),
              ),
              if (results != null)
                ...results!.map(
                  (e) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Map<String, Color> inputTypes = {
  "String": VSStringInputData(type: "legend").interfaceColor,
  "Int": VSIntInputData(type: "legend").interfaceColor,
  "Double": VSDoubleInputData(type: "legend").interfaceColor,
  "Num": VSNumInputData(type: "legend").interfaceColor,
  "Bool": VSBoolInputData(type: "legend").interfaceColor,
  "Dynamic": VSDynamicInputData(type: "legend").interfaceColor,
};

class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    final entries = inputTypes.entries;

    for (final entry in entries) {
      widgets.add(
        Row(
          children: [
            Text(entry.key),
            Icon(
              Icons.circle,
              color: entry.value,
            ),
            if (entry != entries.last) const Divider(),
          ],
        ),
      );
    }

    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widgets,
      ),
    ));
  }
}
