import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    Map<String, Color> inputTypes = {
      "String": VSStringInputData(type: "legend").interfaceColor,
      "Int": VSIntInputData(type: "legend").interfaceColor,
      "Double": VSDoubleInputData(type: "legend").interfaceColor,
      "Num": VSNumInputData(type: "legend").interfaceColor,
      "Bool": VSBoolInputData(type: "legend").interfaceColor,
      "Dynamic": VSDynamicInputData(type: "legend").interfaceColor,
    };

    final Iterable<MapEntry<String, Color>> entries = inputTypes.entries;

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
