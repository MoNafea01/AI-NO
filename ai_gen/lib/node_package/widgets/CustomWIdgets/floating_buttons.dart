import 'package:ai_gen/node_package/widgets/GridCubit/grid_cubit.dart';
import 'package:ai_gen/node_package/widgets/Resuable%20Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FLoatingWIdgets extends StatelessWidget {
  const FLoatingWIdgets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 75,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffE6E6E6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomButton(
              onTap: () {},
              width: 40,
              height: 40,
              backgroundColor: const Color(0xffE6E6E6),
              icon: Icons.add,
              borderRadius: 8,
              iconColor: Colors.black,
              iconSize: 25),
          const SizedBox(
            width: 15,
          ),
          BlocBuilder<GridCubit, GridState>(
            buildWhen: (previous, current) =>
                previous.showGrid != current.showGrid,
            builder: (context, state) {
              return CustomButton(
                  onTap: () {
                    context.read<GridCubit>().toggleGrid();
                  },
                  width: 40,
                  height: 40,
                  backgroundColor: const Color(0xff349CFE),
                  icon: state.showGrid
                      ? Icons.grid_4x4_sharp
                      : Icons.grid_off_rounded,
                  borderRadius: 8,
                  iconColor: Colors.white,
                  iconSize: 28);
            },
          ),
          const SizedBox(
            width: 20,
          ),
          CustomIconButton(
              onTap: () {},
              width: 40,
              height: 40,
              backgroundColor: const Color(0xff349CFE),
              iconPath: "assets/images/arrow_Selector_Tool.png",
              borderRadius: 8,
              iconColor: Colors.white,
              iconSize: 29),
          CustomButton(
              onTap: () {},
              width: 40,
              height: 40,
              backgroundColor: const Color(0xffE6E6E6),
              icon: Icons.keyboard_arrow_down_sharp,
              borderRadius: 8,
              iconColor: Colors.black,
              iconSize: 25),
        ],
      ),
    );
  }
}
