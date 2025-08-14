import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/presentation/cubit/grid_node_view_cubit.dart';
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

  Widget outputCard(BuildContext context, Map<String, dynamic>? scopeOutput) {
    if (scopeOutput == null) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: _decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${scopeOutput.keys.first.toString()}:",
                style: AppTextStyles.black14Bold
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  minimumSize: const Size(0, 0),
                ),
                onPressed: () {
                  context.read<GridNodeViewCubit>().closeRunMenu();
                },
                icon: const Icon(
                  Icons.close,
                  color: AppColors.blackText2,
                ),
              ),
            ],
          ),
          Text(
            "${scopeOutput.values.firstOrNull}",
            style: AppTextStyles.black14w400,
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.8),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
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
