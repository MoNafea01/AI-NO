import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:ai_gen/node_package/widgets/GridCubit/grid_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NodeView extends StatefulWidget {
  const NodeView({required this.nodeBuilder, super.key});

  final List<dynamic> nodeBuilder;
  @override
  State<NodeView> createState() => _NodeViewState();
}

class _NodeViewState extends State<NodeView> {
  Iterable<String>? results;
  late final VSNodeDataProvider nodeDataProvider;

  @override
  void initState() {
    // TODO: implement initState
    nodeDataProvider = VSNodeDataProvider(
      nodeManager: VSNodeManager(nodeBuilders: widget.nodeBuilder),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GridCubit(),
      child: Stack(
        children: [
          InteractiveVSNodeView(
            width: 5000,
            height: 5000,
            nodeDataProvider: nodeDataProvider,
          ),
          // const Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: Legend(),
          // ),
          Positioned(
            top: 230,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _evaluateButton(),
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
          _testButton(),
        ],
      ),
    );
  }

  Positioned _testButton() {
    return Positioned(
      bottom: 50,
      left: 10,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text("Test"),
      ),
    );
  }

  ElevatedButton _evaluateButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: const BorderSide(
                color: Colors.black, width: 2), // Set border color to black
            borderRadius: BorderRadius.circular(20), // Optional: border radius
          ),
        ),
      ),
      onPressed: () async {
        List<MapEntry<String, dynamic>> entries = nodeDataProvider
            .nodeManager.getOutputNodes
            .map((e) => e.evaluate())
            .toList();

        for (var i = 0; i < entries.length; i++) {
          var asyncOutput = await entries[i].value;
          entries[i] = MapEntry(entries[i].key, asyncOutput);
        }

        setState(() => results = entries.map((e) => "${e.key}: ${e.value}"));
      },
      child: const Text(
        "Evaluate",
        style: TextStyle(color: Colors.black, fontSize: 17),
      ),
    );
  }
}
