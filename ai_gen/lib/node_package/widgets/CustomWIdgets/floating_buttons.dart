// import 'package:ai_gen/node_package/widgets/GridCubit/grid_cubit.dart';
// import 'package:ai_gen/node_package/widgets/Resuable%20Widgets/custom_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'mouse_mode_cubit.dart'; // Import Cubit

// class FloatingWidgets extends StatelessWidget {
//   const FloatingWidgets({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => MouseModeCubit(), // Provide MouseModeCubit
//       child: Column(
//         children: [
//           Container(
//             width: 220,
//             height: 75,
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xffE6E6E6),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 CustomButton(
//                     onTap: () {},
//                     width: 40,
//                     height: 40,
//                     backgroundColor: const Color(0xffE6E6E6),
//                     icon: Icons.add,
//                     borderRadius: 8,
//                     iconColor: Colors.black,
//                     iconSize: 25),
//                 const SizedBox(width: 15),
//                 BlocBuilder<GridCubit, GridState>(
//                   buildWhen: (previous, current) =>
//                       previous.showGrid != current.showGrid,
//                   builder: (context, state) {
//                     return CustomButton(
//                         onTap: () {
//                           context.read<GridCubit>().toggleGrid();
//                         },
//                         width: 40,
//                         height: 40,
//                         backgroundColor: const Color(0xff349CFE),
//                         icon: state.showGrid
//                             ? Icons.grid_4x4_sharp
//                             : Icons.grid_off_rounded,
//                         borderRadius: 8,
//                         iconColor: Colors.white,
//                         iconSize: 28);
//                   },
//                 ),
//                 const SizedBox(width: 20),

//                 // **CustomIconButton - Changes when selection is made**
//                 BlocBuilder<MouseModeCubit, MouseModeState>(
//                   builder: (context, state) {
//                     return CustomIconButton(
//                       onTap: () =>
//                           context.read<MouseModeCubit>().toggleDropdown(),
//                       width: 40,
//                       height: 40,
//                       backgroundColor: const Color(0xff349CFE),
//                       iconPath: state.iconPath,
//                       borderRadius: 8,
//                       iconColor: Colors.white,
//                       iconSize: 29,
//                     );
//                   },
//                 ),

//                 CustomButton(
//                   onTap: () => context.read<MouseModeCubit>().toggleDropdown(),
//                   width: 40,
//                   height: 40,
//                   backgroundColor: const Color(0xffE6E6E6),
//                   icon: Icons.keyboard_arrow_down_sharp,
//                   borderRadius: 8,
//                   iconColor: Colors.black,
//                   iconSize: 25,
//                 ),
//               ],
//             ),
//           ),

//           // **Dropdown Menu (Using Bloc)**
//           BlocBuilder<MouseModeCubit, MouseModeState>(
//             builder: (context, state) {
//               if (!state.isDropdownVisible) return const SizedBox.shrink();
//               return Container(
//                 width: 160,
//                 margin: const EdgeInsets.only(top: 5),
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xff349CFE),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildDropdownItem(context, "Mouse Pointer",
//                         "assets/images/arrow_Selector_Tool.png"),
//                     const Divider(color: Colors.black), // **Separator Line**
//                     _buildDropdownItem(context, "Mouse Hold",
//                         "assets/images/hand_Selector_Tool.jpeg"),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // **Dropdown item builder**
//   Widget _buildDropdownItem(
//       BuildContext context, String mode, String iconPath) {
//     return GestureDetector(
//       onTap: () =>
//           context.read<MouseModeCubit>().changeMouseMode(mode, iconPath),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         child: Row(
//           children: [
//             Image.asset(iconPath, width: 20, height: 20),
//             const SizedBox(width: 10),
//             Text(mode, style: const TextStyle(fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:ai_gen/node_package/widgets/CustomWIdgets/mouse_mode_cubit.dart';
import 'package:ai_gen/node_package/widgets/GridCubit/grid_cubit.dart';
import 'package:ai_gen/node_package/widgets/Resuable%20Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FloatingWidgets extends StatelessWidget {
  const FloatingWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MouseModeCubit(), // Provide the Cubit
      child: const FloatingWidgetsBody(),
    );
  }
}


class FloatingWidgetsBody extends StatelessWidget {
  const FloatingWidgetsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
              const SizedBox(width: 15),
              BlocBuilder<GridCubit, GridState>(
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
              const SizedBox(width: 20),

              // Custom Icon Button (Changes on selection)
              BlocBuilder<MouseModeCubit, MouseModeState>(
                builder: (context, state) {
                  return CustomIconButton(
                    onTap: () =>
                        context.read<MouseModeCubit>().toggleDropdown(),
                    width: 40,
                    height: 40,
                    backgroundColor: const Color(0xff349CFE),
                    iconPath: state.iconPath,
                    borderRadius: 8,
                    iconColor: Colors.white,
                    iconSize: 29,
                  );
                },
              ),

              CustomButton(
                onTap: () => context.read<MouseModeCubit>().toggleDropdown(),
                width: 40,
                height: 40,
                backgroundColor: const Color(0xffE6E6E6),
                icon: Icons.keyboard_arrow_down_sharp,
                borderRadius: 8,
                iconColor: Colors.black,
                iconSize: 25,
              ),
            ],
          ),
        ),

        // Dropdown Menu
        BlocBuilder<MouseModeCubit, MouseModeState>(
          builder: (context, state) {
            if (!state.isDropdownVisible) return const SizedBox.shrink();
            return Container(
              width: 160,
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff349CFE),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownItem(context, "Mouse Pointer",
                      "assets/images/arrow_Selector_Tool.png"),
                  const Divider(color: Colors.black), // Separator Line
                  _buildDropdownItem(context, "Mouse Hold",
                      "assets/images/hand_Selector_Tool.jpeg"),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Dropdown item builder
  Widget _buildDropdownItem(
      BuildContext context, String mode, String iconPath) {
    return GestureDetector(
      onTap: () =>
          context.read<MouseModeCubit>().changeMouseMode(mode, iconPath),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Image.asset(iconPath, width: 20, height: 20),
            const SizedBox(width: 10),
            Text(mode, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
