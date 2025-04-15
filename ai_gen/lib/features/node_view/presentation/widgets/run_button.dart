import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RunButton extends StatelessWidget {
  const RunButton({super.key});

  @override
  Widget build(BuildContext context) {
    final GridNodeViewCubit gridNodeViewCubit =
        context.watch<GridNodeViewCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _runButton(context),
        if (gridNodeViewCubit.results != null)
          ...gridNodeViewCubit.results!.map(
            (scopeOutput) {
              return outputCard(context, scopeOutput);
            },
          ),
      ],
    );
  }

  Card outputCard(BuildContext context, String scopeOutput) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(0),
                minimumSize: const Size(0, 0),
              ),
              onPressed: () {
                context.read<GridNodeViewCubit>().closeRunMenu();
              },
              icon: const Icon(Icons.close),
            ),
            Text(scopeOutput),
          ],
        ),
      ),
    );
  }

  ElevatedButton _runButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF4F),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        context.read<GridNodeViewCubit>().runNodes();
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.play_arrow, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Run",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
